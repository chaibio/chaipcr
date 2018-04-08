# amplification analysis

const Ct_VAL_DomainError = -100 # should be a value that cannot be obtained by normal calculation of Ct

type AmpStepRampProperties
    step_or_ramp::String
    id::Int
    cyc_nums::Vector{Int} # accomodating non-continuous sequences of cycles
end
const DEFAULT_cyc_nums = Vector{Int}()

# `mod_bl_q` output
type MbqOutput
    fitted_prebl::AbstractAmpFitted
    bl_notes::Vector{String}
    blsub_fluos::Vector{AbstractFloat}
    fitted_postbl::AbstractAmpFitted
    postbl_status::Symbol
    coefs::Vector{AbstractFloat}
    d0::AbstractFloat
    blsub_fitted::Vector{AbstractFloat}
    max_d1::AbstractFloat
    max_d2::AbstractFloat
    cyc_vals_4cq::OrderedDict{String,AbstractFloat}
    eff_vals_4cq::OrderedDict{String,AbstractFloat}
    cq_raw::AbstractFloat
    cq::AbstractFloat
    eff::AbstractFloat
    cq_fluo::AbstractFloat
end

# amplification output format per step or ramp
type AmpStepRampOutput
    # computed in `process_amp_1sr`
    fr_ary3::Array{AbstractFloat,3}
    mw_ary3::Array{AbstractFloat,3}
    k4dcv::K4Deconv
    dcvd_ary3::Array{AbstractFloat,3}
    wva_data::OrderedDict{String,OrderedDict{Int,Vector{AbstractFloat}}}
    rbbs_ary3::Array{AbstractFloat,3}
    fluo_well_nums::Vector{Int}
    channel_nums::Vector{Int}
    cq_method::String
    # computed by `mod_bl_q` as part of `MbqOutput` and arranged in arrays in `process_amp_1sr`
    fitted_prebl::Array{AbstractAmpFitted,2}
    bl_notes::Array{Array{String,1},2}
    blsub_fluos::Array{AbstractFloat,3}
    fitted_postbl::Array{AbstractAmpFitted,2}
    postbl_status::Array{Symbol,2}
    coefs::Array{AbstractFloat,3}
    d0::Array{AbstractFloat,2}
    blsub_fitted::Array{AbstractFloat,3}
    max_d1::Array{AbstractFloat,2}
    max_d2::Array{AbstractFloat,2}
    cyc_vals_4cq::Array{OrderedDict{String,AbstractFloat},2}
    eff_vals_4cq::Array{OrderedDict{String,AbstractFloat},2}
    cq_raw::Array{AbstractFloat,2}
    cq::Array{AbstractFloat,2}
    eff::Array{AbstractFloat,2}
    cq_fluo::Array{AbstractFloat,2}
    # computed in `process_amp_1sr` from `MbqOutput`
    qt_fluos::Array{AbstractFloat,2}
    max_qt_fluo::AbstractFloat
    # computed by `report_cq!` and arranged in arrays in `process_amp_1sr`
    max_bsf::Array{AbstractFloat,2}
    n_max_bsf::Array{AbstractFloat,2}
    n_max_d1::Array{AbstractFloat,2}
    n_max_d2::Array{AbstractFloat,2}
    why_NaN::Array{String,2}
    # for ct method
    ct_fluos::Vector{AbstractFloat}
    # allelic discrimination
    assignments_adj_labels_dict::OrderedDict{String,Vector{String}}
    agr_dict::OrderedDict{String,AssignGenosResult}
end # type AmpStepRampOutput

type AmpStepRampOutput2Bjson
    rbbs_ary3::Array{AbstractFloat,3} # fluorescence after deconvolution and adjusting well-to-well variation
    blsub_fluos::Array{AbstractFloat,3} # fluorescence after baseline subtraction
    cq::Array{AbstractFloat,2} # cq values, applicable to sigmoid models but not to MAK models
    d0::Array{AbstractFloat,2} # starting quantity from absolute quanitification
    ct_fluos::Vector{AbstractFloat} # fluorescence thresholds (one value per channel) for Ct method
    assignments_adj_labels_dict::OrderedDict{String,Vector{String}} # assigned genotypes from allelic discrimination, keyed by type of data (see `AD_DATA_CATEG` in "allelic_discrimination.jl")
end


#
function process_amp(
    db_conn::MySQL.MySQLHandle,
    exp_id::Integer,
    asrp_vec::AbstractVector,
    calib_info::Union{Integer,OrderedDict};

    # arguments that might be passed by upstream code
    well_nums::AbstractVector=[],
    min_reliable_cyc::Real=5,
    baseline_cyc_bounds::AbstractArray=[],
    cq_method::String="Cy0",
    ct_fluos::AbstractVector=[],

    max_cycle::Integer=1000, # maximum temperature to analyze
    dcv::Bool=true, # logical, whether to perform multi-channel deconvolution
    dye_in::String="FAM", dyes_2bfild::AbstractVector=[],
    qt_prob_rc::Real=0.9, # quantile probablity for fluo values per well
    af_key::String="sfc",

    kwdict_mbq::Associative=OrderedDict(), # keyword arguments passed onto `mod_bl_q`
    ipopt_print2file_prefix::String="", # file prefix for Ipopt print for `mod_bl_q`

    kwdict_rc::Associative=OrderedDict(), # keyword arguments passed onto `report_cq!`,

    # allelic discrimination
    ad_cycs::Union{Integer,AbstractVector}=0, # allelic discrimination: cycles of fluorescence to be used, 0 means the last cycle
    ctrl_well_dict::OrderedDict=CTRL_WELL_DICT,
    cluster_method::String="k-means", # allelic discrimination: "k-means", "k-medoids"
    expected_ncg_raw::AbstractMatrix=DEFAULT_encgr, # each column is a vector of binary genotype whose length is number of channels (0 => no signal, 1 => yes signal)
    categ_well_vec::AbstractVector=CATEG_WELL_VEC,

    out_sr_dict::Bool=true, # output an OrderedDict keyed by `sr_str`s
    out_format::String="json", # "full", "pre_json", "json"
    json_digits::Integer=JSON_DIGITS,
    verbose::Bool=false
    )

    print_v(println, verbose,
        "db_conn: ", db_conn, "\n",
        "experiment_id: $exp_id\n",
        "asrp_vec: $asrp_vec\n",
        "calib_info: $calib_info\n",
        "max_cycle: $max_cycle"
    )

    calib_info = ensure_ci(db_conn, calib_info, exp_id)

    if length(asrp_vec) == 0
        sr_qry = "SELECT steps.id, steps.collect_data, ramps.id, ramps.collect_data
            FROM experiments
            LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
            LEFT JOIN stages ON protocols.id = stages.protocol_id
            LEFT JOIN steps ON stages.id = steps.stage_id
            LEFT JOIN ramps ON steps.id = ramps.next_step_id
            WHERE
                experiments.id = $exp_id AND
                stages.stage_type <> \'meltcurve\'
        "
        sr = MySQL.query(db_conn, sr_qry) # fieldnames: [1] steps.id, [2] steps.collect_data, [3] ramps.id, [4] ramps.collect_data

        step_ids = unique(sr[1][sr[2] .== 1])
        ramp_ids = unique(sr[3][sr[4] .== 1])

        asrp_vec = vcat(
            map(step_ids) do step_id
                AmpStepRampProperties("step", step_id, DEFAULT_cyc_nums)
            end,
            map(ramp_ids) do ramp_id
                AmpStepRampProperties("ramp", ramp_id, DEFAULT_cyc_nums)
            end
        )
    end # if length(sr_str_vec)

    # # find the latest step or ramp
    # if out_sr_dict
    #     sr_ids = map(asrp -> asrp.id, asrp_vec)
    #     max_step_id = maximum(sr_ids)
    #     msi_idc = find(sr_id -> sr_id == max_step_id, sr_ids) # msi = max_step_id
    #     if length(msi_idc) == 1
    #         latest_idx = msi_idc[1]
    #     else # length(max_idc) == 2
    #         latest_idx = find(asrp_vec) do asrp
    #             asrp.step_or_ramp == "step" && aspr.id == max_step_id
    #         end[1] # do asrp
    #     end # if length(min_idc) == 1
    #     asrp_latest = asrp_vec[latest_idx]
    # else # implying `sr_vec` has only one element
    #     asrp_latest = asrp_vec[1]
    # end

    # print_v(println, verbose, asrp_latest)

    # find `asrp`
    for asrp in asrp_vec
        fd_qry_2b = "
            SELECT well_num, cycle_num
                FROM fluorescence_data
                WHERE
                    experiment_id = $exp_id AND
                    $(asrp.step_or_ramp)_id = $(asrp.id) AND
                    cycle_num <= $max_cycle AND
                    step_id is not NULL
                    well_constraint
                ORDER BY cycle_num
        " # must "SELECT well_num" for `get_mysql_data_well`
        fd_nt, fluo_well_nums = get_mysql_data_well(
            well_nums, fd_qry_2b, db_conn, verbose
        )
        asrp.cyc_nums = unique(fd_nt[:cycle_num])
     end # for asrp

     # find `fluo_well_nums` and `channel_nums`. literal i.e. non-pointer variables created in a Julia for-loop is local, i.e. not accessible outside of the for-loop.
     asrp_1 = asrp_vec[1]
     fd_qry_2b = "
         SELECT well_num, channel
             FROM fluorescence_data
             WHERE
                 experiment_id = $exp_id AND
                 $(asrp_1.step_or_ramp)_id = $(asrp_1.id) AND
                 step_id is not NULL
                 well_constraint
             ORDER BY well_num
     " # must "SELECT well_num" and "ORDER BY well_num" for `get_mysql_data_well`
     fd_nt, fluo_well_nums = get_mysql_data_well(
         well_nums, fd_qry_2b, db_conn, verbose
     )
    channel_nums = unique(fd_nt[:channel])

    # pre-deconvolution, process all available channel_nums
    if length(channel_nums) == 1
        dcv = false
    end

    out_format_1sr = (out_format == "json" ? "pre_json" : out_format)

    sr_dict = OrderedDict(map(asrp_vec) do asrp
        process_amp_1sr(
            db_conn, exp_id, asrp, calib_info,
            fluo_well_nums, well_nums, channel_nums,
            dcv,
            dye_in, dyes_2bfild,
            min_reliable_cyc, baseline_cyc_bounds, cq_method, ct_fluos, af_key, kwdict_mbq, ipopt_print2file_prefix,
            qt_prob_rc, kwdict_rc,
            ad_cycs, ctrl_well_dict, cluster_method, expected_ncg_raw, categ_well_vec,
            out_format_1sr, json_digits, verbose
        )
    end) # do sr_ele

    final_out = out_sr_dict ? sr_dict : collect(values(sr_dict))[1]

    return out_format == "json" ? json(final_out) : final_out

end # process_amp


function get_amp_data(
    db_conn::MySQL.MySQLHandle,
    col_name::String, # "fluorescence_value" or "baseline_value"
    exp_id::Integer,
    asrp::AmpStepRampProperties,
    fluo_well_nums::AbstractVector, # not `[]`, all elements are expected to be found
    channel_nums::AbstractVector,
    )

    cyc_nums = asrp.cyc_nums

    # get fluorescence data for amplification
    fluo_qry = "SELECT $col_name
        FROM fluorescence_data
        WHERE
            experiment_id= $exp_id AND
            $(asrp.step_or_ramp)_id = $(asrp.id) AND
            cycle_num in ($(join(cyc_nums, ","))) AND
            well_num in ($(join(fluo_well_nums, ","))) AND
            channel in ($(join(channel_nums, ","))) AND
            step_id is not NULL
        ORDER BY channel, well_num, cycle_num
    "
    fluo_sel = MySQL.query(db_conn, fluo_qry)

    fluo_raw = reshape(
        fluo_sel[parse(col_name)],
        map(length, (cyc_nums, fluo_well_nums, channel_nums))...
    )

    return fluo_raw

end # get_amp_data


#
function mod_bl_q( # for amplification data per well per channel, fit sigmoid model, extract important information for Cq, subtract baseline.
    fluos::AbstractVector;

    min_reliable_cyc::Real=5, # >= 1
    baseline_cyc_bounds::AbstractVector=[],
    bl_fallback_func::Function=median,

    af_key::String="sfc", # a string representation of amplification curve model, used for finding the right model `DataType` in `dfc_DICT` and the right empty model instance in `AF_EMPTY_DICT`

    m_prebl::String="l4_enl",
    m_postbl::String="l4_enl",

    denser_factor::Real=100,

    cq_method::String="Cy0",
    ct_fluo::Real=NaN,

    verbose::Bool=false,

    kwargs_jmp_model::OrderedDict=OrderedDict(
        :solver=>IpoptSolver(print_level=0, max_iter=35) # `ReadOnlyMemoryError()` for v0.5.1
        # :solver=>IpoptSolver(print_level=0, max_iter=100) # increase allowed number of iterations for MAK-based methods, due to possible numerical difficulties during search for fitting directions (step size becomes too small to be precisely represented by the precision allowed by the system's capacity)
        # :solver=>NLoptSolver(algorithm=:LN_COBYLA)
    ),
    ipopt_print2file::String="",
    )

    num_cycs = length(fluos)
    cycs = 1.0 * (1:num_cycs)
    cycs_denser = Array(colon(1, (num_cycs - 1) / denser_factor, num_cycs))

    len_bcb = length(baseline_cyc_bounds)

    last_cyc_wt0 = round(min_reliable_cyc, RoundDown) - 1 # to determine weights (`wts`) for sigmoid fitting per `min_reliable_cyc`

    # will remain the same `if len_bcb == 0 && (last_cyc_wt0 <= 1 || num_cycs < min_reliable_cyc)`
    wts = ones(num_cycs)
    fitted_prebl = AF_EMPTY_DICT[af_key]
    baseline = bl_fallback_func(fluos)
    bl_notes = ["last_cyc_wt0 <= 1 || num_cycs < min_reliable_cyc, fallback"]

    solver = kwargs_jmp_model[:solver]
    if isa(solver, IpoptSolver)
        push!(solver.options, (:output_file, ipopt_print2file))
    end

    if af_key != "sfc" # no fallback for baseline, because: (1) curve may fit well though :Error or :UserLimit (search step becomes very small but has not converge); (2) the guessed basedline (`start` of `fb`) is usually quite close to a sensible baseline.

        dfc_inst = dfc_DICT[af_key]()

        fitted_prebl = fit(dfc_inst, cycs, fluos, wts; kwargs_jmp_model...)
        baseline = fitted_prebl.coefs[1] # "fb"
        if af_key in ["MAK3", "MAKERGAUL4"]
            baseline += fitted_prebl.coefs[2] .* cycs # `.+=` caused "ERROR: MethodError: no method matching broadcast!(::QpcrAnalysis.##278#283, ::Float64, ::Float64, ::Float64, ::StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}})"
        end # if af_key

        fitted_postbl = fitted_prebl
        coefs_pob = fitted_postbl.coefs

        d0_i_vec = find(fitted_postbl.coef_strs) do coef_str
            coef_str == "d0"
        end
        d0 = coefs_pob[d0_i_vec[1]] # * 1. # without `* 1.`, MethodError: no method matching kmeans!(::Array{AbstractFloat,2}, ::Array{Float64,2}); Closest candidates are: kmeans!(::Array{T<:AbstractFloat,2}, ::Array{T<:AbstractFloat,2}; weights, maxiter, tol, display) where T<:AbstractFloat at E:\for_programs\julia_pkgs\v0.6\Clustering\src\kmeans.jl:27

        # for `Sfc`-style output
        bl_notes = [af_key]
        blsub_fluos = fluos .- baseline
        blsub_fitted = pred_from_cycs(dfc_inst, cycs, coefs_pob...)
        max_d1 = max_d2 = Inf
        cyc_vals_4cq = eff_vals_4cq = OrderedDict()
        eff = NaN
        cq_raw = NaN
        cq_fluo = NaN

    else # af_key == "sfc"

        if len_bcb == 0 && last_cyc_wt0 > 1 && num_cycs >= min_reliable_cyc

            wts = vcat(zeros(last_cyc_wt0), ones(num_cycs - last_cyc_wt0))

            fitted_prebl = MDs[m_prebl].func_fit(cycs, fluos, wts; kwargs_jmp_model...)

            prebl_status = string(fitted_prebl.status)
            bl_notes = ["prebl_status $prebl_status"]

            baseline_fitted = MDs[m_prebl].funcs_pred["bl"](cycs, fitted_prebl.coefs...)

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
                    push!(bl_notes, "max_d2_right_cyc ($max_d2_right_cyc) <= last_cyc_wt0 ($last_cyc_wt0), bl_cycs = $(last_cyc_wt0+1):$num_cycs")
                    bl_cycs = last_cyc_wt0+1:num_cycs
                else
                    bl_cyc_start = max(last_cyc_wt0+1, max_d2_left_cyc)
                    push!(bl_notes, "max_d2_right_cyc ($max_d2_right_cyc) > last_cyc_wt0 ($last_cyc_wt0), bl_cyc_start = $bl_cyc_start (max(last_cyc_wt0+1, max_d2_left_cyc), i.e. max($(last_cyc_wt0+1), $max_d2_left_cyc))")

                    if max_d2_right_cyc - bl_cyc_start <= 1
                        push!(bl_notes, "max_d2_right_cyc ($max_d2_right_cyc) - bl_cyc_start ($bl_cyc_start) <= 1")
                        max_d2_right_2, max_d2_right_cyc_2_shifted = findmax(d2_cfd[max_d2_right_cyc+1:end])
                        max_d2_right_cyc_2 = max_d2_right_cyc_2_shifted + max_d2_right_cyc
                        if max_d2_right_cyc_2 - max_d2_right_cyc == 1
                            bl_cyc_end = num_cycs
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

        elseif len_bcb == 2
            baseline = bl_fallback_func(fluos[colon(baseline_cyc_bounds...)])
            bl_notes = ["User-defined"]

        elseif !(len_bcb in [0, 2])
            error("Length of `baseline_cyc_bounds` must be 0 or 2.")

        end # if len_bcb


        blsub_fluos = fluos .- baseline

        fitted_postbl = MDs[m_postbl].func_fit(
            cycs, blsub_fluos, wts;
            kwargs_jmp_model...
        )

        coefs_pob = fitted_postbl.coefs

        d0 = NaN

        func_pred_f = MDs[m_postbl].funcs_pred["f"]
        blsub_fitted = func_pred_f(cycs, coefs_pob...)

        len_denser = length(cycs_denser)

        d1_pred = MDs[m_postbl].funcs_pred["d1"](cycs_denser, coefs_pob...)
        max_d1, idx_max_d1 = findmax(d1_pred)
        cyc_max_d1 = cycs_denser[idx_max_d1]

        d2_pred = MDs[m_postbl].funcs_pred["d2"](cycs_denser, coefs_pob...)
        max_d2, idx_max_d2 = findmax(d2_pred)
        cyc_max_d2 = cycs_denser[idx_max_d2]

        Cy0 = cyc_max_d1 - func_pred_f(cyc_max_d1, coefs_pob...) / max_d1

        ct = try
            MDs[m_postbl].funcs_pred["inv"](ct_fluo, coefs_pob...)
        catch err
            isa(err, DomainError) ? Ct_VAL_DomainError : "unhandled error"
        end # try

        cyc_vals_4cq = OrderedDict(
            "cp_d1"=>cyc_max_d1,
            "cp_d2"=>cyc_max_d2,
            "Cy0"=>Cy0,
            "ct"=>ct
        )

        func_pred_eff = function (cyc)
            try
                log(2, /(map([0.5, -0.5]) do epsilon
                    func_pred_f(cyc + epsilon, coefs_pob...)
                end...))
            catch err
                isa(err, DomainError) ? NaN : "unhandled error"
            end # try
        end # function. needed because `Cy0` may not be in `cycs_denser`

        eff_vals_4cq = OrderedDict(map(keys(cyc_vals_4cq)) do key
            key => func_pred_eff(cyc_vals_4cq[key])
        end)

        eff_pred = map(func_pred_eff, cycs_denser)
        eff_vals_4cq["max_eff"], idx_max_eff = findmax(eff_pred)
        cyc_vals_4cq["max_eff"] = cycs_denser[idx_max_eff]

        cq_raw = cyc_vals_4cq[cq_method]
        eff = eff_vals_4cq[cq_method]

        cq_fluo = func_pred_f(cq_raw <= 0 ? NaN : cq_raw, coefs_pob...)


    end # if af_key


    return MbqOutput(
        fitted_prebl,
        bl_notes,
        blsub_fluos,
        fitted_postbl,
        fitted_postbl.status,
        coefs_pob,
        d0,
        blsub_fitted,
        max_d1,
        max_d2,
        cyc_vals_4cq,
        eff_vals_4cq,
        cq_raw,
        copy(cq_raw),
        eff,
        cq_fluo
    )
#

end # mod_bl_q


function report_cq!(
    full_amp_out::AmpStepRampOutput,
    well_i::Integer,
    channel_i::Integer;
    before_128x::Bool=false,
    max_d1_lb=472,
    max_d2_lb=41,
    max_bsf_lb=4356,
    n_max_d1_lb=0.0089, # look like real amplification, n_max_d1 0.00894855, ip223, exp. 75, well A7, channel 2.
    n_max_d2_lb=0.000689,
    n_max_bsf_lb=0.086
    )

    if before_128x
        max_d1_lb, max_d2_lb, max_bsf_lb = [max_d1_lb, max_d2_lb, max_bsf_lb] / 128
    end

    num_cycs = size(full_amp_out.fr_ary3)[1]

    postbl_status,   cq_raw,  max_d1,  max_d2 = map([
    :postbl_status, :cq_raw, :max_d1, :max_d2
    ]) do fn
        getindex(getfield(full_amp_out, fn), well_i, channel_i)
    end # do fn

    max_bsf = maximum(full_amp_out.blsub_fluos[:, well_i, channel_i])

    b_ = full_amp_out.coefs[1, well_i, channel_i]

    n_max_d1, n_max_d2, n_max_bsf = [max_d1, max_d2, max_bsf] / full_amp_out.max_qt_fluo
    why_NaN = ""

    if postbl_status == :Error
        why_NaN = "postbl_status == :Error"
    elseif b_ > 0
        why_NaN = "b > 0"
    elseif full_amp_out.cq_method == "ct" && cq_raw == Ct_VAL_DomainError
        why_NaN = "DomainError when calculating Ct"
    elseif cq_raw <= 0.1 || cq_raw >= num_cycs
        why_NaN = "cq_raw <= 0.1 || cq_raw >= num_cycs"
    elseif max_d1 < max_d1_lb
        why_NaN = "max_d1 $max_d1 < max_d1_lb $max_d1_lb"
    elseif max_d2 < max_d2_lb
        why_NaN = "max_d2 $max_d2 < max_d2_lb $max_d2_lb"
    elseif max_bsf < max_bsf_lb
        why_NaN = "max_bsf $max_bsf < max_bsf_lb $max_bsf_lb"
    elseif n_max_d1 < n_max_d1_lb
        why_NaN = "n_max_d1 $n_max_d1 < n_max_d1_lb $n_max_d1_lb"
    elseif n_max_d2 < n_max_d2_lb
        why_NaN = "n_max_d2 $n_max_d2 < n_max_d2_lb $n_max_d2_lb"
    elseif n_max_bsf < n_max_bsf_lb
        why_NaN = "n_max_bsf $n_max_bsf < n_max_bsf_lb $n_max_bsf_lb"
    end

    if why_NaN != ""
        full_amp_out.cq[well_i, channel_i] = NaN
    end

    for tup in (
        (:max_bsf, max_bsf),
        (:n_max_d1, n_max_d1),
        (:n_max_d2, n_max_d2),
        (:n_max_bsf, n_max_bsf),
        (:why_NaN, why_NaN)
    )
        getfield(full_amp_out, tup[1])[well_i, channel_i] = tup[2]
    end

    return nothing

end # report_cq!



# process amplification per step
function process_amp_1sr(
    db_conn::MySQL.MySQLHandle,
    exp_id::Integer,
    asrp::AmpStepRampProperties,
    calib_info::Union{Integer,OrderedDict},
    fluo_well_nums::AbstractVector, well_nums::AbstractVector,
    channel_nums::AbstractVector,
    dcv::Bool, # logical, whether to perform multi-channel deconvolution
    dye_in::String, dyes_2bfild::AbstractVector,
    min_reliable_cyc::Real,
    baseline_cyc_bounds::AbstractArray,
    cq_method::String,
    ct_fluos::AbstractVector,
    af_key::String,
    kwdict_mbq::Associative, # keyword arguments passed onto `mod_bl_q`
    ipopt_print2file_prefix::String,
    qt_prob_rc::Real, # quantile probablity for fluo values per well
    kwdict_rc::Associative, # keyword arguments passed onto `report_cq`
    ad_cycs::Union{Integer,AbstractVector},
    ctrl_well_dict::OrderedDict,
    cluster_method::String,
    expected_ncg_raw::AbstractMatrix,
    categ_well_vec::AbstractVector,
    out_format::String, # "full", "pre_json", "json"
    json_digits::Integer,
    verbose::Bool
    )

    fr_ary3 = get_amp_data(
        db_conn,
        "fluorescence_value", # "fluorescence_value" or "baseline_value"
        exp_id, asrp,
        fluo_well_nums, channel_nums
    )

    num_cycs, num_fluo_wells, num_channels = size(fr_ary3)

    mw_ary3, k4dcv, dcvd_ary3, wva_data, wva_well_nums, rbbs_ary3 = dcv_aw(
        fr_ary3, dcv, channel_nums,
        db_conn, calib_info, fluo_well_nums, well_nums, dye_in, dyes_2bfild;
        aw_out_format="array"
    )

    size_bcb = size(baseline_cyc_bounds)
    if size_bcb == (0,) || (size_bcb == (2,) && size(baseline_cyc_bounds[1]) == ()) # can't use `eltype(baseline_cyc_bounds) <: Integer` because `JSON.parse("[1,2]")` results in `Any[1,2]` instead of `Int[1,2]`
        baseline_cyc_bounds = fill(baseline_cyc_bounds, num_fluo_wells, num_channels)
    elseif size_bcb == (num_fluo_wells, num_channels) && eltype(baseline_cyc_bounds) <: AbstractVector # final format of `baseline_cyc_bounds`
        nothing
    else
        error("`baseline_cyc_bounds` is not in the right format.")
    end # if ndims

    NaN_ary2 = fill(NaN, num_fluo_wells, num_channels)
    fitted_prebl = fitted_postbl = fill(AF_EMPTY_DICT[af_key], num_fluo_wells, num_channels) # once `::Array{EmptyAmpFitted,2}`, can't be `setfield!` to `::Array{SfcFitted,2}`, and vice versa
    blsub_fluos = blsub_fitted = rbbs_ary3
    empty_vals_4cq = fill(OrderedDict{String,AbstractFloat}(), num_fluo_wells, num_channels)
    ct_fluos_empty = fill(NaN, num_channels)

    full_amp_out = AmpStepRampOutput(
        fr_ary3,
        mw_ary3,
        k4dcv,
        dcvd_ary3,
        wva_data,
        rbbs_ary3,
        fluo_well_nums,
        channel_nums,
        cq_method,
        fitted_prebl,
        fill(Vector{String}(), num_fluo_wells, num_channels), # bl_notes
        blsub_fluos,
        fitted_postbl,
        fill(:not_fitted, num_fluo_wells, num_channels), # postbl_status
        fill(NaN, 1, num_fluo_wells, num_channels), # coefs # size = 1 for 1st dimension may not be correct for the chosen model
        NaN_ary2, # d0s
        blsub_fitted,
        NaN_ary2, # max_d1
        NaN_ary2, # max_d2
        empty_vals_4cq, # cyc_vals_4cq
        empty_vals_4cq, # eff_vals_4cq
        NaN_ary2, # cq_raw
        NaN_ary2, # cq
        NaN_ary2, # eff
        NaN_ary2, # cq_fluo
        NaN_ary2, # qt_fluos
        Inf, # max_qt_fluo
        NaN_ary2, # max_bsf
        NaN_ary2, # n_max_bsf
        NaN_ary2, # n_max_d1
        NaN_ary2, # n_max_d2
        fill("", num_fluo_wells, num_channels), # why_NaN
        ct_fluos,
        OrderedDict{String,Vector{String}}(), # assignments_adj_labels_dict
        OrderedDict{String,AssignGenosResult}() # agr_dict
    )

    if num_cycs <= 2
        print_v(println, verbose, "Number of cycles $num_cycs <= 2, baseline subtraction and Cq calculation will not be performed.")
    else
        if length(ct_fluos) == 0
            if cq_method == "ct"
                ct_fluos = map(1:num_channels) do channel_i
                    mbq_ary1 = map(1:num_fluo_wells) do well_i
                        mod_bl_q(
                            rbbs_ary3[:, well_i, channel_i];
                            min_reliable_cyc=min_reliable_cyc,
                            baseline_cyc_bounds=baseline_cyc_bounds[well_i, channel_i],
                            cq_method="cp_d1",
                            ct_fluo=NaN,
                            af_key=af_key,
                            kwdict_mbq...,
                            verbose=verbose
                        )
                    end # do well_i

                    # find `idc_useful`
                    postbl_stata = map(mbq -> mbq["postbl_status"], mbq_ary1)
                    idc_useful = find(postbl_stata) do postbl_status
                        postbl_status == :Optimal
                    end # do postbl_status
                    if length(idc_useful) == 0
                        idc_useful = find(postbl_stata) do postbl_status
                            postbl_status == :UserLimit
                        end # do postbl_status
                        if length(idc_useful) == 0
                            idc_useful = 1:length(postbl_status)
                        end # if length(idc_useful)
                    end # if length(idc_useful)

                    fluos_useful = map(idc_useful) do mbq_i
                        mbq_ary1[mbq_i]["cq_fluo"]
                    end # do mbq_i
                    median(fluos_useful)
                end # do channel_i
            else
                ct_fluos = fill(NaN, num_channels)
            end # if cq_method
        end # if length

        full_amp_out.ct_fluos = ct_fluos

        mbq_ary2 = [
            begin
                ipopt_print2file = length(ipopt_print2file_prefix) == 0 ? "" : "$(join([ipopt_print2file_prefix, channel_i, well_i], '_')).txt"
                mod_bl_q(
                    rbbs_ary3[:, well_i, channel_i];
                    min_reliable_cyc=min_reliable_cyc,
                    baseline_cyc_bounds=baseline_cyc_bounds[well_i, channel_i],
                    cq_method=cq_method,
                    ct_fluo=ct_fluos[channel_i],
                    af_key=af_key,
                    kwdict_mbq...,
                    ipopt_print2file=ipopt_print2file,
                    verbose=verbose
                )
            end
            for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
        ]

        fns_mbq = fieldnames(MbqOutput)
        for fn_mbq in fns_mbq
            fv = [
                getfield(mbq_ary2[well_i, channel_i], fn_mbq)
                for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
            ]
            if fn_mbq in [:blsub_fluos, :coefs, :blsub_fitted]
                fv = reshape(
                    cat(2, fv...), # 2-dim array of size (`num_cycs` or number of coefs, `num_wells * num_channels`)
                    length(fv[1,1]), size(fv)...
                )
            end # if fn_mbq in
            setfield!(full_amp_out, fn_mbq, convert(typeof(getfield(full_amp_out, fn_mbq)), fv)) # `setfield!` doesn't call `convert` on its own
        end # for fn_mbq

        full_amp_out.qt_fluos = [
            quantile(full_amp_out.blsub_fluos[:, well_i, channel_i], qt_prob_rc)
            for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
        ]
        full_amp_out.max_qt_fluo = maximum(full_amp_out.qt_fluos)

        for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
            report_cq!(full_amp_out, well_i, channel_i; kwdict_rc...)
        end

    end # if num_cycs <= 2 ... else


    # allelic discrimination
    if dcv
        full_amp_out.assignments_adj_labels_dict, full_amp_out.agr_dict = process_ad(
            full_amp_out,
            ad_cycs,
            ctrl_well_dict,
            cluster_method,
            expected_ncg_raw,
            categ_well_vec
        )
    end # if dcv


    if endswith(out_format, "json")
        amp_out = AmpStepRampOutput2Bjson(map(fieldnames(AmpStepRampOutput2Bjson)) do fn # numeric fields only
            field_value = getfield(full_amp_out, fn)
            try
                round.(field_value, json_digits)
            catch
                field_value
            end # try
        end...) # do fn
    elseif out_format == "full"
        amp_out = full_amp_out
    end

    return join([asrp.step_or_ramp, asrp.id], "_") => amp_out

end # process_amp_ps


#
