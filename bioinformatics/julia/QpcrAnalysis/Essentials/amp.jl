# amplification analysis


#
function process_amp(
    db_conn::MySQL.MySQLHandle,
    exp_id::Integer,
    sr_vec::AbstractVector, # format: [("step", 21), ("ramp", 22)] # 21 is the step_id, 11 is the ramp_id. Elements are Tuples instead of Vectors to simplify manual input (`[[1,2],[3,4]]` will be parsed as concatenation of `[1,2]` and `[3,4]` instead of a vector whose elements are [1,2]` and `[3,4]`.)
    calib_info::Union{Integer,OrderedDict};
    # start: arguments that might be passed by upstream code
    well_nums::AbstractVector=[],
    min_reliable_cyc::Real=5,
    # end: arguments that might be passed by upstream code
    max_cycle::Integer=1000, # maximum temperature to analyze
    dcv::Bool=true, # logical, whether to perform multi-channel deconvolution
    dye_in::AbstractString="FAM", dyes_2bfild::AbstractVector=[],
    qt_prob_rc::Real=0.9, # quantile probablity for fluo values per well
    kwdict_mbq::Associative=OrderedDict(), # keyword arguments passed onto `mod_bl_q`
    kwdict_rc::Associative=OrderedDict(), # keyword arguments passed onto `report_cq`
    out_sr_dict::Bool=true, # output an OrderedDict keyed by `sr_str`s
    out_format::AbstractString="json", # "full", "pre_json", "json"
    json_digits::Integer=JSON_DIGITS,
    verbose::Bool=false
    )

    print_v(println, verbose,
        "db_conn: ", db_conn, "\n",
        "experiment_id: $exp_id\n",
        "sr_vec: $sr_vec\n",
        "calib_info: $calib_info\n",
        "max_cycle: $max_cycle"
    )

    calib_info = ensure_ci(db_conn, calib_info, exp_id)

    if length(sr_vec) == 0
        sr_qry = "SELECT steps.id, steps.collect_data, ramps.id, ramps.collect_data
            FROM experiments
            LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
            LEFT JOIN stages ON protocols.id = stages.protocol_id
            LEFT JOIN steps ON stages.id = steps.stage_id
            LEFT JOIN ramps ON steps.id = ramps.next_step_id
            WHERE experiments.id = $exp_id
        "
        sr = mysql_execute(db_conn, sr_qry)

        step_ids = unique(sr[find(val -> val==1, sr[:collect_data]), :id])
        ramp_ids = unique(sr[find(val -> val==1, sr[:collect_data_1]), :id_1])

        sr_vec = vcat(
            map(step_id -> ("step", step_id), step_ids),
            map(ramp_id -> ("ramp", ramp_id), ramp_ids)
        )
    end # length(sr_str_vec)

    # find the latest step or ramp
    if out_sr_dict
        sr_ids = map(sr -> sr[2], sr_vec)
        max_step_id = maximum(sr_ids)
        msi_idc = find(sr_id -> sr_id==max_step_id, sr_ids) # msi = max_step_id
        if length(msi_idc) == 1
            latest_idx = msi_idc[1]
        else # length(max_idc) == 2
            latest_idx = find(sr_vec) do sr
                sr[1] == "step" && sr[2] == max_step_id
            end[1] # do sr
        end # if length(min_idc) == 1
        sr_latest = sr_vec[latest_idx]
    else # implying `sr_vec` has only one element
        sr_latest = sr_vec[1]
    end

    print_v(println, verbose, sr_latest)

    fd_qry_2b = "
        SELECT cycle_num, well_num, channel
            FROM fluorescence_data
            WHERE
                experiment_id = $exp_id AND
                $(sr_latest[1])_id = $(sr_latest[2]) AND
                cycle_num <= $max_cycle
                well_constraint
            ORDER BY cycle_num, well_num, channel
    "
    fd_df, fluo_well_nums = get_mysql_data_well(
        well_nums, fd_qry_2b, db_conn, verbose
    )

    cycle_nums, channels = map([:cycle_num, :channel]) do symb
        unique(fd_df[symb])
    end

    num_cycles, num_fluo_wells, num_channels = map(
        length,
        (cycle_nums, fluo_well_nums, channels)
    )

    # pre-deconvolution, process all available channels
    if num_channels == 1
        dcv = false
    end

    out_format_1sr = out_format == "json" ? "pre_json" : out_format

    sr_dict = OrderedDict(map(sr_vec) do sr_ele
        process_amp_1sr(
            db_conn, exp_id, sr_ele, calib_info,
            cycle_nums, fluo_well_nums, well_nums, channels,
            dcv,
            dye_in, dyes_2bfild,
            min_reliable_cyc, kwdict_mbq,
            qt_prob_rc, kwdict_rc,
            out_format_1sr, json_digits, verbose
        )
    end) # do sr_ele

    final_out = out_sr_dict ? sr_dict : sr_dict[join(sr_vec[1], "_")]

    return out_format == "json" ? json(final_out) : final_out

end # process_amp


function get_amp_data(
    db_conn::MySQL.MySQLHandle,
    col_name::AbstractString, # "fluorescence_value" or "baseline_value"
    exp_id::Integer,
    sr_ele::Tuple,
    cycle_nums::AbstractVector,
    fluo_well_nums::AbstractVector, # not `[]`, all elements are expected to be found
    channels::AbstractVector,
    )

    # get fluorescence data for amplification
    fluo_qry = "SELECT $col_name
        FROM fluorescence_data
        WHERE
            fluorescence_data.experiment_id= $exp_id AND
            $(sr_ele[1])_id = $(sr_ele[2]) AND
            cycle_num <= $(maximum(cycle_nums)) AND
            well_num in ($(join(fluo_well_nums, ","))) AND
            channel in ($(join(channels, ",")))
        ORDER BY channel, well_num, cycle_num
    "
    fluo_sel = mysql_execute(db_conn, fluo_qry)

    fluo_raw = reshape(
        fluo_sel[parse(col_name)],
        map(length, (cycle_nums, fluo_well_nums, channels))...
    )

    return fluo_raw

end # get_amp_data


#
function mod_bl_q( # for amplification data per well per channel, fit sigmoid model, extract important information for Cq, subtract baseline.
    fluos::AbstractVector;

    min_reliable_cyc::Real=5, # >= 1

    sig_m_prebl::AbstractString="l4_enl",
    bl_fallback_func::Function=median,
    sig_m_postbl::AbstractString="l4_enl",

    denser_factor::Real=100,

    cq_method::AbstractString="Cy0",

    verbose::Bool=false,

    kwargs_jmp_model::OrderedDict=OrderedDict(
        :solver=>IpoptSolver(print_level=0, max_iter=35)
    )
    )

    num_cycles = length(fluos)
    cycs = 1.0 * (1:num_cycles)
    cycs_denser = Array(colon(1, (num_cycles - 1) / denser_factor, num_cycles))

    last_cyc_wt0 = round(min_reliable_cyc, RoundDown) - 1 # to determine weights (`wts`) for sigmoid fitting per `min_reliable_cyc`

    if last_cyc_wt0 <= 1 || num_cycles < min_reliable_cyc
        wts = ones(num_cycles)
        fitted_prebl = EMPTY_fitted
        baseline = bl_fallback_func(fluos)
        bl_notes = ["last_cyc_wt0 <= 1 || num_cycles < min_reliable_cyc, fallback"]

    else

        wts = vcat(zeros(last_cyc_wt0), ones(num_cycles - last_cyc_wt0))

        fitted_prebl = MDs[sig_m_prebl].func_fit(cycs, fluos, wts; kwargs_jmp_model...)

        prebl_status = string(fitted_prebl["status"])
        bl_notes = ["prebl_status $prebl_status"]

        baseline_fitted = MDs[sig_m_prebl].funcs_pred["bl"](cycs, fitted_prebl["coefs"]...)

        if prebl_status in ["Optimal", "UserLimit"]
            push!(bl_notes, "sig")
            blsub_fluos_draft = fluos .- baseline_fitted
            min_bfd, max_bfd = extrema(blsub_fluos_draft) # bfd = blsub_fluos_draft
            if max_bfd - min_bfd <= abs(min_bfd)
                bl_notes[2] = "fallback"
                push!(bl_notes, "max_bfd ($max_bfd) - min_bfd ($min_bfd) == $(max_bfd - min_bfd) <= abs(min_bfd)")
            end # if max_bfd
        elseif prebl_status == "Error"
            push!(bl_notes, "fallback")
        end # if prebl_status

        # different baseline subtraction methods
        if bl_notes[2] == "sig"
            baseline = baseline_fitted

        elseif bl_notes[2] == "fallback"

            min_fluo, min_fluo_cyc = findmin(fluos)
            d2_cfd = finite_diff(cycs, fluos; nu=2) # `Dierckx.Spline1D` resulted in all `NaN` in some cases

            d2_cfd_left = d2_cfd[1:min_fluo_cyc]
            d2_cfd_right = d2_cfd[min_fluo_cyc:end]
            max_d2_left_cyc, max_d2_right_cyc = map((d2_cfd_left, d2_cfd_right)) do d2_vec
                findmax(d2_vec)[2]
            end # do d2_vec

            if max_d2_right_cyc <= last_cyc_wt0 # fluo on fitted spline may not be close to raw fluo at `cyc_m2l` and `cyc_m2r`
                push!(bl_notes, "max_d2_right_cyc ($max_d2_right_cyc) <= last_cyc_wt0 ($last_cyc_wt0), bl_cycs = $(last_cyc_wt0+1):$num_cycles")
                bl_cycs = last_cyc_wt0+1:num_cycles
            else
                bl_cyc_start = max(last_cyc_wt0+1, max_d2_left_cyc)
                push!(bl_notes, "max_d2_right_cyc ($max_d2_right_cyc) > last_cyc_wt0 ($last_cyc_wt0), bl_cyc_start = $bl_cyc_start (max(last_cyc_wt0+1, max_d2_left_cyc), i.e. max($(last_cyc_wt0+1), $max_d2_left_cyc))")

                if max_d2_right_cyc - bl_cyc_start <= 1
                    push!(bl_notes, "max_d2_right_cyc ($max_d2_right_cyc) - bl_cyc_start ($bl_cyc_start) <= 1")
                    max_d2_right_2, max_d2_right_cyc_2_shifted = findmax(d2_cfd[max_d2_right_cyc+1:end])
                    max_d2_right_cyc_2 = max_d2_right_cyc_2_shifted + max_d2_right_cyc
                    if max_d2_right_cyc_2 - max_d2_right_cyc == 1
                        bl_cyc_end = num_cycles
                        push!(bl_notes, "max_d2_right_cyc_2 ($max_d2_right_cyc_2) - max_d2_right_cyc ($max_d2_right_cyc) == 1")
                    else
                        push!(bl_notes, "max_d2_right_cyc_2 ($max_d2_right_cyc_2) - max_d2_right_cyc ($max_d2_right_cyc) != 1")
                        bl_cyc_end = max_d2_right_cyc_2
                    end # if m2r2_idx
                else
                    push!(bl_notes, "max_d2_right_cyc ($max_d2_right_cyc) - bl_cyc_start ($bl_cyc_start) > 1")
                    bl_cyc_end = max_d2_right_cyc
                end # if cyc_m2r - bl_cyc_start <= 1
                push!(bl_notes, "bl_cyc_end = $bl_cyc_end")

                bl_cycs = bl_cyc_start:bl_cyc_end
                push!(bl_notes, "bl_cycs = $bl_cyc_start:$bl_cyc_end")
            end # cyc_m2r <= last_cyc_wt0

            baseline = bl_fallback_func(fluos[bl_cycs])

        end # if bl_notes = ["sig"]

    end # if last_cyc_wt0 <= 1


    blsub_fluos = fluos .- baseline

    fitted_postbl = MDs[sig_m_postbl].func_fit(
        cycs, blsub_fluos, wts;
        kwargs_jmp_model...
    )

    coefs_pb = fitted_postbl["coefs"]

    len_denser = length(cycs_denser)

    d1_pred = MDs[sig_m_postbl].funcs_pred["d1"](cycs_denser, coefs_pb...)
    max_d1, idx_max_d1 = findmax(d1_pred)
    cyc_max_d1 = cycs_denser[idx_max_d1]

    d2_pred = MDs[sig_m_postbl].funcs_pred["d2"](cycs_denser, coefs_pb...)
    max_d2, idx_max_d2 = findmax(d2_pred)
    cyc_max_d2 = cycs_denser[idx_max_d2]

    func_pred_f = MDs[sig_m_postbl].funcs_pred["f"]
    Cy0 = cyc_max_d1 - func_pred_f(cyc_max_d1, coefs_pb...) / max_d1

    cyc_dict = OrderedDict(
        "cp_d1"=>cyc_max_d1,
        "cp_d2"=>cyc_max_d2,
        "Cy0"=>Cy0
    )

    func_pred_eff = function (cyc)
        try
            log(2, /(map([0.5, -0.5]) do epsilon
                func_pred_f(cyc + epsilon, coefs_pb...)
            end...))
        catch err
            if isa(err, DomainError)
                NaN
            end # if
        end # try
    end # function. needed because `Cy0` may not be in `cycs_denser`

    eff_dict = OrderedDict(map(keys(cyc_dict)) do key
        key => func_pred_eff(cyc_dict[key])
    end)

    eff_pred = map(func_pred_eff, cycs_denser)
    eff_dict["max_eff"], idx_max_eff = findmax(eff_pred)
    cyc_dict["max_eff"] = cycs_denser[idx_max_eff]

    cq_raw = cyc_dict[cq_method]
    eff = eff_dict[cq_method]

    return OrderedDict(
        "fitted_prebl"=>fitted_prebl,
        "bl_notes"=>bl_notes,
        "blsub_fluos"=>blsub_fluos,
        "fitted_postbl"=>fitted_postbl,
        "postbl_status"=>fitted_postbl["status"],
        "coefs"=>fitted_postbl["coefs"],
        "max_d1"=>max_d1,
        "max_d2"=>max_d2,
        "cyc_dict"=>cyc_dict,
        "eff_dict"=>eff_dict,
        "cq_raw"=>cq_raw,
        "cq"=>copy(cq_raw),
        "eff"=>eff,
    )
#

end # mod_bl_q


function report_cq!(
    full_dict::OrderedDict,
    well_i::Integer,
    channel_i::Integer;
    before_128x::Bool=false,
    min_max_d1=472,
    min_max_d2=41,
    min_max_bsf=4356,
    min_n_max_d1=0.0089, # look like real amplification, n_max_d1 0.00894855, ip223, exp. 75, well A7, channel 2.
    min_n_max_d2=0.000689,
    min_n_max_bsf=0.086
    )

    if before_128x
        min_max_d1, min_max_d2, min_max_bsf = [min_max_d1, min_max_d2, min_max_bsf] / 128
    end

    num_cycles = size(full_dict["fr_ary3"])[1]

    postbl_status,    coefs,   cq_raw,   max_d1,   max_d2 = map([
    "postbl_status", "coefs", "cq_raw", "max_d1", "max_d2"
    ]) do key
        getindex(full_dict[key], well_i, channel_i)
    end # do key

    max_bsf = maximum(full_dict["blsub_fluos"][:, well_i, channel_i])

    b_ = coefs[1]

    n_max_d1, n_max_d2, n_max_bsf = [max_d1, max_d2, max_bsf] / full_dict["max_qt_fluo"]
    why_NaN = ""

    if postbl_status == :Error
        why_NaN = "postbl_status == :Error"
    elseif b_ > 0
        why_NaN = "b > 0"
    elseif cq_raw <= 0.1 || cq_raw >= num_cycles
        why_NaN = "cq_raw <= 0.1 || cq_raw >= num_cycles"
    elseif max_d1 < min_max_d1
        why_NaN = "max_d1 $max_d1 < min_max_d1 $min_max_d1"
    elseif max_d2 < min_max_d2
        why_NaN = "max_d2 $max_d2 < min_max_d2 $min_max_d2"
    elseif max_bsf < min_max_bsf
        why_NaN = "max_bsf $max_bsf < min_max_bsf $min_max_bsf"
    elseif n_max_d1 < min_n_max_d1
        why_NaN = "n_max_d1 $n_max_d1 < min_n_max_d1 $min_n_max_d1"
    elseif n_max_d2 < min_n_max_d2
        why_NaN = "n_max_d2 $n_max_d2 < min_n_max_d2 $min_n_max_d2"
    elseif n_max_bsf < min_n_max_bsf
        why_NaN = "n_max_bsf $n_max_bsf < min_n_max_bsf $min_n_max_bsf"
    end

    if why_NaN != ""
        full_dict["cq"][well_i, channel_i] = NaN
    end

    for tup in (
        ("max_bsf", max_bsf),
        ("n_max_d1", n_max_d1),
        ("n_max_d2", n_max_d2),
        ("n_max_bsf", n_max_bsf),
        ("why_NaN", why_NaN)
    )
        full_dict[tup[1]][well_i, channel_i] = tup[2]
    end

    return nothing

end # report_cq!


# process amplification per step
function process_amp_1sr(
    db_conn::MySQL.MySQLHandle,
    exp_id::Integer,
    sr_ele::Tuple,
    calib_info::Union{Integer,OrderedDict},
    cycle_nums::AbstractVector,
    fluo_well_nums::AbstractVector, well_nums::AbstractVector,
    channels::AbstractVector,
    dcv::Bool, # logical, whether to perform multi-channel deconvolution
    dye_in::AbstractString, dyes_2bfild::AbstractVector,
    min_reliable_cyc::Real,
    kwdict_mbq::Associative, # keyword arguments passed onto `mod_bl_q`
    qt_prob_rc::Real, # quantile probablity for fluo values per well
    kwdict_rc::Associative, # keyword arguments passed onto `report_cq`
    out_format::AbstractString, # "full", "pre_json", "json"
    json_digits::Integer,
    verbose::Bool
    )

    fr_ary3 = get_amp_data(
        db_conn,
        "fluorescence_value", # "fluorescence_value" or "baseline_value"
        exp_id, sr_ele,
        cycle_nums, fluo_well_nums, channels
    )

    num_cycles, num_fluo_wells, num_channels = size(fr_ary3)

    mw_ary3, k_dict, dcvd_ary3, wva_data, wva_well_nums, rbbs_ary3 = dcv_aw(
        fr_ary3, dcv, channels,
        db_conn, calib_info, fluo_well_nums, well_nums, dye_in, dyes_2bfild;
        aw_out_format="array"
    )

    full_dict = OrderedDict(
        "fr_ary3"=>fr_ary3,
        "mw_ary3"=>mw_ary3,
        "k_dict"=>k_dict,
        "dcvd_ary3"=>dcvd_ary3,
        "wva_data"=>wva_data,
        "rbbs_ary3"=>rbbs_ary3,
        "fluo_well_nums"=>fluo_well_nums,
        "channels"=>channels
    )

    NaN_ary2 = fill(NaN, num_fluo_wells, num_channels)

    if num_cycles <= 2
        print_v(println, verbose, "Number of cycles $num_cycles <= 2, baseline subtraction and Cq calculation will not be performed.")
        full_dict["blsub_fluos"] = rbbs_ary3
        full_dict["cq"] = NaN_ary2
    else
        mbq_ary2 = [
            mod_bl_q(
                rbbs_ary3[:, well_i, channel_i];
                min_reliable_cyc=min_reliable_cyc,
                kwdict_mbq...,
                verbose=verbose
            )
            for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
        ]

        for key in keys(mbq_ary2[1,1])
            full_dict[key] = [mbq_ary2[well_i, channel_i][key]
                for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
            ]
        end

        full_dict["blsub_fluos"] = reshape(
            cat(2, full_dict["blsub_fluos"]...), # 2-dim array of size (`num_cycles`, `num_wells * num_channels`)
            size(fr_ary3)...
        )

        full_dict["qt_fluos"] = [
            quantile(full_dict["blsub_fluos"][:, well_i, channel_i], qt_prob_rc)
            for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
        ]
        full_dict["max_qt_fluo"] = maximum(full_dict["qt_fluos"])

        FloatT = eltype(rbbs_ary3)
        StrT = typeof("")
        for key_type in [
            ("max_bsf", FloatT), # bsf = blsub_fluo
            ("n_max_bsf", FloatT),
            ("n_max_d1", FloatT),
            ("n_max_d2", FloatT),
            ("why_NaN", StrT),
        ]
            full_dict[key_type[1]] = similar(full_dict["cq_raw"], key_type[2])
        end # for

        for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
            report_cq!(full_dict, well_i, channel_i; kwdict_rc...)
        end

    end # if

    if endswith(out_format, "json")
        out_dict = OrderedDict(map(["rbbs_ary3", "blsub_fluos", "cq"]) do key
            key => round(full_dict[key], json_digits)
        end) # do key
    elseif out_format == "full"
        out_dict = full_dict
    end

    return join(sr_ele, "_") => out_dict

end # process_amp_ps


#
