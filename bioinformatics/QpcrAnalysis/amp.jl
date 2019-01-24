## amp.jl
#
## amplification analysis

import JSON: parse
import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver
using Ipopt


## called by QpcrAnalysis.dispatch
function act(
    ::Amplification,
    req_dict        ::Associative;
    out_format      ::Symbol = :pre_json,
    verbose         ::Bool =false
)   
    ## issue:
    ## the following assumes only 1 step/ramp because the current data format
    ## does not allow us to break the fluorescence data down by step_id/ramp_id
    function parsed_raw_data()
        const cyc_nums, fluo_well_nums, channel_nums =
            map(["cycle_num", "well_num", "channel"]) do key
                req_dict["raw_data"][key] |> unique             # in order of appearance
            end
        const num_cycs, num_fluo_wells, num_channels =
            (cyc_nums, fluo_well_nums, channel_nums) |> map[length]
        try
            assert(req_dict["raw_data"]["cycle_num"] ==
                repeat(
                    cyc_nums,
                    outer = num_fluo_wells * num_channels))
            assert(req_dict["raw_data"]["well_num" ] ==
                repeat(
                    fluo_well_nums,
                    inner = num_cycs,
                    outer = num_channels))
            assert(req_dict["raw_data"]["channel"  ] ==
                repeat(
                    channel_nums,
                    inner = num_cycs * num_fluo_wells))
        catch
            error("The format of the fluorescence data does not lend itself" *
                " to transformation into a 3-dimensional array. Please make sure" *
                " that it is sorted by channel, well number, and cycle number.")
        end
        ## `fr_ary3` - fluo_raw_array_3d
        ## this code assumes that the data in the request
        ## is formatted appropriately for this transformation
        ## we can check the cycle/well/channel data if necessary
        const R = typeof(req_dict["raw_data"]["fluorescence_value"][1][1])
        const fr_ary3 ::Array{R,3} =
            reshape(
                req_dict["raw_data"]["fluorescence_value"],
                num_cycs, num_fluo_wells, num_channels)
        ## rearrange data in sort order of each index
        const cyc_perm  = sortperm(cyc_nums)
        const well_perm = sortperm(fluo_well_nums)
        const chan_perm = sortperm(channel_nums)
        return (
            cyc_nums[cyc_perm],
            fluo_well_nums[well_perm],
            channel_nums[chan_perm] |> map[i -> "channel_$(i)"],
            num_cycs,
            num_fluo_wells,
            num_channels,
            fr_ary3[cyc_perm,well_perm,chan_perm])
    end
    ## remove MySql dependency
    ## asrp_vec
    # if "step_id" in keys_req_dict
    #     asrp_vec = [AmpStepRampProperties("step", req_dict["step_id"], DEFAULT_cyc_nums)]
    # elseif "ramp_id" in keys_req_dict
    #     asrp_vec = [AmpStepRampProperties("ramp", req_dict["ramp_id"], DEFAULT_cyc_nums)]
    # else
    #     asrp_vec = Vector{AmpStepRampProperties}()
    # end

    ## we will assume that any relevant step/ramp information has already been passed along
    ## and is present in step_id / ramp_id
    if haskey(req_dict, "step_id")
        const asrp_vec = [AmpStepRampProperties(:step, req_dict["step_id"], DEFAULT_cyc_nums)]
    elseif haskey(req_dict, "ramp_id")
        const asrp_vec = [AmpStepRampProperties(:ramp, req_dict["ramp_id"], DEFAULT_cyc_nums)]
    else
        error("no step/ramp information found")
    end
    ## `report_cq!` arguments
    kwdict_rc = Dict{Symbol,Any}()
    for key in keys(KWDICT_RC_SYMBOLS)
        if haskey(req_dict, key)
            kwdict_rc[KWDICT_RC_SYMBOLS[key]] = req_dict[key]
        end
    end
    ## `process_amp_1sr` arguments
    kwdict_pa1 = Dict{Symbol,Any}()
    for key in KWDICT_PA1_KEYWORDS
        if haskey(req_dict, key)
            kwdict_pa1[Symbol(key)] = str2sym.(req_dict[key])
        end
    end
    ## categ_well_vec argument
    if haskey(req_dict, "categ_well_vec")
        kwdict_pa1[:categ_well_vec] =
            map(x -> str2sym.(x), req_dict["categ_well_vec"])
        for i in req_dict["categ_well_vec"] |> length |> range[1]
            if length(req_dict["categ_well_vec"][i][2]) == 0
                kwdict_pa1[:categ_well_vec][i][2] = Colon()
            end
        end
    end
    ## `mod_bl_q` arguments
    kwdict_mbq = Dict{Symbol,Any}()
    if haskey(req_dict, "baseline_method")
        if req_dict["baseline_method"] == "sigmoid"
            kwdict_mbq[:bl_method] = :l4_enl
            kwdict_mbq[:bl_fallback_func] = median
        elseif req_dict["baseline_method"] == "linear"
            kwdict_mbq[:bl_method] = :lin_1ft
            kwdict_mbq[:bl_fallback_func] = mean
        elseif req_dict["baseline_method"] == "median"
            kwdict_mbq[:bl_method] = median
        end
    end
    

    ## call
    response = process_amp(
        ## remove MySql dependency
        # db_conn, exp_id, asrp_vec, calib_info;
        # req_dict["experiment_id"],
        parsed_raw_data()...,
        req_dict["calibration_info"],
        asrp_vec;
        out_format  = out_format,
        verbose     = verbose,
        kwdict_rc   = kwdict_rc,
        kwdict_mbq  = kwdict_mbq,
        out_sr_dict = false,
        kwdict_pa1...
    )
end # act(::Amplification)


## currently this function does nothing
## it just passes data through to process_amp_1sr()
## the compiler might be able to eliminate it
function process_amp(
    ## remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # asrp_vec ::Vector{AmpStepRampProperties},
    # calib_info ::Union{Integer,OrderedDict};
    # exp_id                  ::Integer,
    #
    ## arguments that might be passed by upstream code
    # well_nums ::AbstractVector =[],
    cyc_nums                ::Vector{I} where I <: Integer,
    fluo_well_nums          ::Vector{J} where J <: Integer,
    channel_nums            ::Vector{String},
    num_cycs                ::Integer,
    num_fluo_wells          ::Integer,
    num_channels            ::Integer,
    fr_ary3                 ::DenseArray,
    calib_data              ::Associative,
    ## we will assume that any relevant step/ramp information
    ## has already been passed along and is present in asrp_vec
    asrp_vec                ::Vector{AmpStepRampProperties};
    ## keyword arguments
    min_reliable_cyc        ::Real =5,
    baseline_cyc_bounds     ::AbstractVector =[],
    cq_method               ::Symbol = :Cy0,
    ct_fluos                ::AbstractVector =[],
    max_cycle               ::Integer =1000, # maximum temperature to analyze
    dcv                     ::Bool =true, # logical, whether to perform multi-channel deconvolution
    dye_in                  ::Symbol = :FAM,
    dyes_2bfild             ::AbstractVector =[],
    qt_prob_rc              ::Real =0.9, # quantile probablity for fluo values per well
    af_key                  ::Symbol = :sfc,
    ipopt_print2file_prefix ::String ="", # file prefix for Ipopt print for `mod_bl_q`
    kwdict_rc               ::Associative =Dict(), # keyword arguments passed onto `report_cq!`,
    kwdict_mbq              ::Associative =Dict(), # keyword arguments passed onto `mod_bl_q`
    ## allelic discrimination
    ad_cycs                 ::Union{Integer,AbstractVector} =0, # allelic discrimination: cycles of fluorescence to be used, 0 means the last cycle
    ctrl_well_dict          ::OrderedDict =CTRL_WELL_DICT,
    cluster_method          ::ClusteringMethod = K_means_medoids(), # allelic discrimination: K_means(), K_medoids(), K_means_medoids()
    norm_l                  ::Real =2, # norm level for distance matrix, e.g. norm_l = 2 means l2-norm
    expected_ncg_raw        ::AbstractMatrix =DEFAULT_encgr, # each column is a vector of binary genotype whose length is number of channels (0 => no signal, 1 => yes signal)
    categ_well_vec          ::AbstractVector =CATEG_WELL_VEC,
    ## output options
    out_sr_dict             ::Bool =true, # output an OrderedDict keyed by `sr_str`s
    out_format              ::Symbol = :json, # :full, :pre_json, :json
    json_digits             ::Integer =JSON_DIGITS,
    verbose                 ::Bool =false
)
    # print_v(println, verbose,
    #     "db_conn: ", db_conn, "\n",
    #     "experiment_id: $exp_id\n",
    #     "asrp_vec: $asrp_vec\n",
    #     "calib_info: $calib_info\n",
    #     "max_cycle: $max_cycle"
    # )

    ## remove MySql dependency
    #
    # calib_info = ensure_ci(db_conn, calib_info, exp_id)
    #
    ## find step_id/ramp_id information
    # if length(asrp_vec) == 0
    #     sr_qry = """SELECT
    #             steps.id AS steps_id,
    #             steps.collect_data AS steps_collect_data,
    #             ramps.id AS ramps_id,
    #             ramps.collect_data AS ramps_collect_data
    #         FROM experiments
    #         LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
    #         LEFT JOIN stages ON protocols.id = stages.protocol_id
    #         LEFT JOIN steps ON stages.id = steps.stage_id
    #         LEFT JOIN ramps ON steps.id = ramps.next_step_id
    #         WHERE
    #             experiments.id = $exp_id AND
    #             stages.stage_type <> \'meltcurve\'
    #     """
    #     # (mapping no longer needed after using "AS" in query):
    #     # [1] steps.id, [2] steps.collect_data, [3] ramps.id, [4] ramps.collect_data
    #     sr = MySQL.mysql_execute(db_conn, sr_qry)[1] # [index] fieldnames
    #
    #     step_ids = unique(sr[1][sr[2] .== 1])
    #     ramp_ids = unique(sr[3][sr[4] .== 1])
    #
    #     asrp_vec = vcat(
    #         map(step_ids) do step_id
    #             AmpStepRampProperties("step", step_id, DEFAULT_cyc_nums)
    #         end,
    #         map(ramp_ids) do ramp_id
    #             AmpStepRampProperties("ramp", ramp_id, DEFAULT_cyc_nums)
    #         end
    #     )
    # end # if length(sr_str_vec)
    #
    ### find the latest step or ramp
    ## if out_sr_dict
    ##     sr_ids = map(asrp -> asrp.id, asrp_vec)
    ##     max_step_id = maximum(sr_ids)
    ##     msi_idc = find(sr_id -> sr_id == max_step_id, sr_ids) # msi = max_step_id
    ##     if length(msi_idc) == 1
    ##         latest_idx = msi_idc[1]
    ##     else # length(max_idc) == 2
    ##         latest_idx = find(asrp_vec) do asrp
    ##             asrp.step_or_ramp == "step" && aspr.id == max_step_id
    ##         end[1] # do asrp
    ##     end # if length(min_idc) == 1
    ##     asrp_latest = asrp_vec[latest_idx]
    ## else # implying `sr_vec` has only one element
    ##     asrp_latest = asrp_vec[1]
    ## end
    #
    ## print_v(println, verbose, asrp_latest)
    #
    ## find `asrp`
    # for asrp in asrp_vec
    #     fd_qry_2b = """
    #         SELECT well_num, cycle_num
    #             FROM fluorescence_data
    #             WHERE
    #                 experiment_id = $exp_id AND
    #                 $(asrp.step_or_ramp)_id = $(asrp.id) AND
    #                 cycle_num <= $max_cycle AND
    #                 step_id is not NULL
    #                 well_constraint
    #             ORDER BY cycle_num
    #     """
    #     # must "SELECT well_num" for `get_mysql_data_well`
    #     fd_nt, fluo_well_nums = get_mysql_data_well(
    #         well_nums, fd_qry_2b, db_conn, verbose
    #     )
    #     asrp.cyc_nums = unique(fd_nt[:cycle_num])
    #  end # for asrp
    #
    ## find `fluo_well_nums` and `channel_nums`.
    ## literal i.e. non-pointer variables created in a Julia for-loop is local,
    ## i.e. not accessible outside of the for-loop.
    #  asrp_1 = asrp_vec[1]
    #  fd_qry_2b = """
    #      SELECT well_num, channel
    #          FROM fluorescence_data
    #          WHERE
    #              experiment_id = $exp_id AND
    #              $(asrp_1.step_or_ramp)_id = $(asrp_1.id) AND
    #              step_id is not NULL
    #              well_constraint
    #          ORDER BY well_num
    #  """
    #  # must "SELECT well_num" and "ORDER BY well_num" for `get_mysql_data_well`
    #  fd_nt, fluo_well_nums = get_mysql_data_well(
    #      well_nums, fd_qry_2b, db_conn, verbose
    #  )
    #
    # channel_nums = unique(fd_nt[:channel])

    const out_format_1sr =  (out_format == "json" ? "pre_json" : out_format)
    ## issues:
    ## 1.
    ## the new code currently assumes only 1 step/ramp
    ## because as the request body is currrently structured
    ## we cannot subset the fluorescence data by step_id/ramp_id
    ## 2.
    ## need to verify that the fluorescence data complies
    ## with the constraints imposed by max_cycle and well_constraint
    sr_dict = OrderedDict(
        map([ asrp_vec[1] ]) do asrp
            join([asrp.step_or_ramp, asrp.id], "_") =>
                process_amp_1sr(
                    ## remove MySql dependency
                    # db_conn, exp_id, asrp, calib_info,
                    # fluo_well_nums, well_nums,
                    cyc_nums,
                    fluo_well_nums,
                    channel_nums,
                    num_cycs,
                    num_fluo_wells,
                    num_channels,
                    fr_ary3,
                    calib_data,
                    asrp,
                    dcv && num_channels > 1, # `dcv`
                    dye_in,
                    dyes_2bfild,
                    min_reliable_cyc,
                    baseline_cyc_bounds,
                    cq_method,
                    ct_fluos,
                    af_key,
                    kwdict_mbq,
                    ipopt_print2file_prefix,
                    qt_prob_rc,
                    kwdict_rc,
                    ad_cycs,
                    ctrl_well_dict,
                    cluster_method,
                    norm_l,
                    expected_ncg_raw,
                    categ_well_vec,
                    (out_format == :json ? :pre_json : out_format), # out_format_1sr
                    json_digits,
                    verbose)
        end) # do sr_ele
    ## output
    if (out_sr_dict)
        final_out = sr_dict
    else
        first_sr_out = first(values(sr_dict))
        final_out =
            OrderedDict(
                map(fieldnames(first_sr_out)) do key
                    key => getfield(first_sr_out,key)
                end)
    end
    final_out[:valid] = true
    return out_format == :json ?
        JSON.json(final_out) :
        final_out
end # process_amp()


## deprecated to remove MySql dependency
#
# function get_amp_data(
#    db_conn ::MySQL.MySQLHandle,
#    col_name ::String, # "fluorescence_value" or "baseline_value"
#    exp_id ::Integer,
#    asrp ::AmpStepRampProperties,
#    fluo_well_nums ::AbstractVector, # not `[]`, all elements are expected to be found
#    channel_nums ::AbstractVector,
# )
#
#    cyc_nums = asrp.cyc_nums
#
#    get fluorescence data for amplification
#    fluo_qry = """SELECT $col_name
#        FROM fluorescence_data
#        WHERE
#            experiment_id= $exp_id AND
#            $(asrp.step_or_ramp)_id = $(asrp.id) AND
#            cycle_num in ($(join(cyc_nums, ","))) AND
#            well_num in ($(join(fluo_well_nums, ","))) AND
#            channel in ($(join(channel_nums, ","))) AND
#            step_id is not NULL
#        ORDER BY channel, well_num, cycle_num
#    """
#    fluo_sel = MySQL.mysql_execute(db_conn, fluo_qry)[1]
#
#    fluo_raw = reshape(
#        fluo_sel[JSON.parse(col_name)],
#        map(length, (cyc_nums, fluo_well_nums, channel_nums))...
#    )
#
#    return fluo_raw
#
# end # get_amp_data


## fit model, baseline subtraction, quantification
function mod_bl_q(
    fluos               ::AbstractVector;
    min_reliable_cyc    ::Real =5, # >= 1
    af_key              ::Symbol = :sfc, # a string representation of amplification curve model, used for finding the right model `DataType` in `dfc_DICT` and the right empty model instance in `AF_EMPTY_DICT`
    sfc_model_defs      ::OrderedDict{Symbol,SFCModelDef} =MDs,
    bl_method           ::Symbol = :l4_enl,
    baseline_cyc_bounds ::AbstractVector =[],
    bl_fallback_func    ::Function =median,
    m_postbl            ::Symbol = :l4_enl,
    denser_factor       ::Real =100,
    cq_method           ::Symbol = :Cy0,
    ct_fluo             ::Real =NaN,
    verbose             ::Bool =false,
    kwargs_jmp_model    ::OrderedDict =OrderedDict(
        :solver => IpoptSolver(print_level=0, max_iter=35) # `ReadOnlyMemoryError()` for v0.5.1
        # :solver => IpoptSolver(print_level=0, max_iter=100) # increase allowed number of iterations for MAK-based methods, due to possible numerical difficulties during search for fitting directions (step size becomes too small to be precisely represented by the precision allowed by the system's capacity)
        # :solver => NLoptSolver(algorithm=:LN_COBYLA)
    ),
    ipopt_print2file ::String ="",
)
    function fit_dfc_model()
        ## no fallback for baseline, because:
        ## (1) curve may fit well though :Error or :UserLimit
        ## (search step becomes very small but has not converge);
        ## (2) the guessed basedline (`start` of `fb`) is usually
        ## quite close to a sensible baseline.
        const dfc_inst = dfc_DICT[af_key]()
        const wts = ones(num_cycs)
        const fitted_prebl = fit(dfc_inst, cycs, fluos, wts; kwargs_jmp_model...)
        if af_key in [:MAK3, :MAKERGAUL4]
            baseline = fitted_prebl.coefs[1] + fitted_prebl.coefs[2] .* cycs # .+ ???
        else
            baseline = fitted_prebl.coefs[1] # `fb` - fallback
        end # if af_key
        const fitted_postbl = fitted_prebl
        const coefs_pob = fitted_postbl.coefs
        const d0_i_vec = find(coef_sym -> coef_sym == :d0, fitted_postbl.coef_syms)
        return MbqOutput(
            fitted_prebl,
            [af_key], # bl_notes,
            fluos .- baseline, # blsub_fluos
            fitted_postbl,
            fitted_postbl.status,
            coefs_pob, # coefs
            coefs_pob[d0_i_vec[1]], # d0
            pred_from_cycs(dfc_inst, cycs, coefs_pob...), # blsub_fitted
            NaN, # dr1_pred,
            NaN, # dr2_pred,
            Inf, # max_dr1
            Inf, # max_dr2
            OrderedDict(), # cyc_vals_4cq
            OrderedDict(), # eff_vals_4cq
            NaN, # cq_raw
            NaN, # cq
            NaN, # eff
            NaN # cq_fluo
        )
    end

    function fit_sfc_model()

        function sfc_wts()
            if bl_method in [:lin_1ft, :lin_2ft]
                _wts = zeros(num_cycs)
                _wts[colon(baseline_cyc_bounds...)] .= 1
                return _wts
            else # sigmoid models so far
                return vcat(zeros(last_cyc_wt0), ones(num_cycs - last_cyc_wt0))
            end
        end

        ## update bl_notes
        function sfc_prebl_status(prebl_status)
            bl_notes = ["prebl_status $prebl_status", "model-derived baseline"]
            if prebl_status in [:Optimal, :UserLimit]
                const min_bfd, max_bfd = extrema(fluos .- baseline) # `bfd` - blsub_fluos_draft
                if max_bfd - min_bfd <= abs(min_bfd)
                    bl_notes[2] = "fallback"
                    push!(bl_notes, "max_bfd ($max_bfd) - min_bfd ($min_bfd) == $(max_bfd - min_bfd) <= abs(min_bfd)")
                end # if max_bfd
            elseif prebl_status == :Error
                bl_notes[2] = "fallback"
            else
                ## other status codes include
                ## ::Infeasible, :Unbounded, :DualityFailure, and possibly others
                ## https://mathprogbasejl.readthedocs.io/en/latest/solverinterface.html
                ## My suggestion is to treat the same as :Error (TP Jan 2019):
                bl_notes[2] = "fallback"
                ## Alternatively, an error could be raised:
                # error("Baseline estimation returned unrecognized termination status $prebl_status")
            end
            return bl_notes
        end

        function calc_bl_cycs()
            if !(len_bcb in [0, 2])
                error("Length of `baseline_cyc_bounds` must be 0 or 2.")
            elseif len_bcb == 2
                push!(bl_notes, "User-defined")
                # baseline = bl_fallback_func(fluos[colon(baseline_cyc_bounds...)])
                return colon(baseline_cyc_bounds...)
            elseif len_bcb == 0 && last_cyc_wt0 > 1 && num_cycs >= min_reliable_cyc
                return auto_choose_bl_cycs()
            end
            ## fallthrough
            error("Cannot calculate `bl_cycs`")
        end

        ## automatically choose baseline cycles as the flat part of the curve
        ## uses `fluos`, `last_cyc_wt0`; updates `bl_notes` using push!()
        ## `last_cyc_wt0 == floor(min_reliable_cyc) - 1`
        function auto_choose_bl_cycs()
            const num_cycs = length(fluos)
            const cycs = range(1.0, num_cycs)
            const min_fluo, min_fluo_cyc = findmin(fluos)
            const dr2_cfd = finite_diff(cycs, fluos; nu=2) # `Dierckx.Spline1D` resulted in all `NaN` in some cases
            const dr2_cfd_left = dr2_cfd[1:min_fluo_cyc]
            const dr2_cfd_right = dr2_cfd[min_fluo_cyc:end]
            const max_dr2_left_cyc, max_dr2_right_cyc =
                map(
                    dr2_vec -> findmax(dr2_vec)[2],
                    (dr2_cfd_left, dr2_cfd_right))
            if max_dr2_right_cyc <= last_cyc_wt0
                ## fluo on fitted spline may not be close to raw fluo
                ## at `cyc_m2l` and `cyc_m2r`
                push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) <= last_cyc_wt0 ($last_cyc_wt0), bl_cycs = $(last_cyc_wt0+1):$num_cycs")
                return colon(last_cyc_wt0+1, num_cycs)
            end
            ## max_dr2_right_cyc > last_cyc_wt0
            const bl_cyc_start = max(last_cyc_wt0+1, max_dr2_left_cyc)
            push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) > last_cyc_wt0 ($last_cyc_wt0), bl_cyc_start = $bl_cyc_start (max(last_cyc_wt0+1, max_dr2_left_cyc), i.e. max($(last_cyc_wt0+1), $max_dr2_left_cyc))")
            if max_dr2_right_cyc - bl_cyc_start <= 1
                push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) - bl_cyc_start ($bl_cyc_start) <= 1")
                const max_dr2_right_2, max_dr2_right_cyc_2_shifted =
                    findmax(dr2_cfd[max_dr2_right_cyc+1:end])
                const max_dr2_right_cyc_2 = max_dr2_right_cyc_2_shifted + max_dr2_right_cyc
                if max_dr2_right_cyc_2 - max_dr2_right_cyc == 1
                    const bl_cyc_end = num_cycs
                    push!(bl_notes, "max_dr2_right_cyc_2 ($max_dr2_right_cyc_2) - max_dr2_right_cyc ($max_dr2_right_cyc) == 1")
                else # max_dr2_right_cyc_2 - max_dr2_right_cyc != 1
                    push!(bl_notes, "max_dr2_right_cyc_2 ($max_dr2_right_cyc_2) - max_dr2_right_cyc ($max_dr2_right_cyc) != 1")
                    const bl_cyc_end = max_dr2_right_cyc_2
                end # if
            else # cyc_m2r - bl_cyc_start > 1
                push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) - bl_cyc_start ($bl_cyc_start) > 1")
                const bl_cyc_end = max_dr2_right_cyc
            end # if
            push!(bl_notes, "bl_cyc_end = $bl_cyc_end")
            const bl_cycs = bl_cyc_start:bl_cyc_end
            push!(bl_notes, "bl_cycs = $bl_cyc_start:$bl_cyc_end")
            return bl_cycs
        end # auto_choose_bl_cycs()

        ## function needed because `Cy0` may not be in `cycs_denser`
        function func_pred_eff(cyc)
            try
                log(2, /(map([0.5, -0.5]) do epsilon
                    func_pred_f(cyc + epsilon, coefs_pob...)
                end...))
            catch err
                isa(err, DomainError) ? NaN : "unhandled error"
            end # try
        end
        ## end of function definitions nested within fit_sfc()

        if bl_method in keys(sfc_model_defs)
            ## fit model to find baseline
            const wts = sfc_wts()
            const fitted_prebl = sfc_model_defs[bl_method].func_fit(
                cycs, fluos, wts; kwargs_jmp_model...)
            baseline = sfc_model_defs[bl_method].funcs_pred[:bl](
                cycs, fitted_prebl.coefs...) # may be changed later
            bl_notes = sfc_prebl_status(fitted_prebl.status)
            if length(bl_notes) >= 2 && bl_notes[2] == "fallback"
                const bl_func = bl_fallback_func
            end
        else
            ## do not fit model to find baseline
            const wts = ones(num_cycs)
            const fitted_prebl = AF_EMPTY_DICT[af_key]
            bl_notes = ["no prebl_status", "no fallback"]
            if bl_method == :median
                const bl_func = median
            else
                ## `bl_func` undefined
                error("Baseline estimation function `bl_func` not defined for `bl_method` $bl_method")
            end
        end
        const bl_cycs = calc_bl_cycs()
        if !(length(bl_notes) >= 2 && bl_notes[2] == "model-derived baseline")
            baseline = bl_func(fluos[bl_cycs]) # change or new def
        end
        const blsub_fluos = fluos .- baseline
        const fitted_postbl = sfc_model_defs[m_postbl].func_fit(
            cycs, blsub_fluos, wts; kwargs_jmp_model...)
        const coefs_pob = fitted_postbl.coefs
        const func_pred_f = sfc_model_defs[m_postbl].funcs_pred[:f]
        const dr1_pred = sfc_model_defs[m_postbl].funcs_pred[:dr1](
            cycs_denser, coefs_pob...)
        const max_dr1, idx_max_dr1 = findmax(dr1_pred)
        const cyc_max_dr1 = cycs_denser[idx_max_dr1]
        const dr2_pred = sfc_model_defs[m_postbl].funcs_pred[:dr2](
            cycs_denser, coefs_pob...)
        const max_dr2, idx_max_dr2 = findmax(dr2_pred)
        const cyc_max_dr2 = cycs_denser[idx_max_dr2]
        const Cy0 = cyc_max_dr1 - func_pred_f(cyc_max_dr1, coefs_pob...) / max_dr1
        const ct = try
            sfc_model_defs[m_postbl].funcs_pred[:inv](ct_fluo, coefs_pob...)
        catch err
            isa(err, DomainError) ? Ct_VAL_DomainError : "unhandled error"
        end # try
        const eff_pred = map(func_pred_eff, cycs_denser)
        const eff_max, idx_max_eff = findmax(eff_pred)
        const cyc_vals_4cq = OrderedDict(
            :cp_dr1  => cyc_max_dr1,
            :cp_dr2  => cyc_max_dr2,
            :Cy0     => Cy0,
            :ct      => ct,
            :max_eff => cycs_denser[idx_max_eff])
        const cq_raw = cyc_vals_4cq[cq_method]
        const eff_vals_4cq =
            OrderedDict(
                map(keys(cyc_vals_4cq)) do key
                    key => (key == :max_eff) ?
                        eff_max :
                        func_pred_eff(cyc_vals_4cq[key])
                end)
        return MbqOutput(
            fitted_prebl,
            bl_notes,
            blsub_fluos,
            fitted_postbl,
            fitted_postbl.status, # postbl_status
            coefs_pob, # coefs
            NaN, # d0
            func_pred_f(cycs, coefs_pob...), # blsub_fitted
            dr1_pred,
            dr2_pred,
            max_dr1,
            max_dr2,
            cyc_vals_4cq,
            eff_vals_4cq,
            cq_raw,
            copy(cyc_vals_4cq[cq_method]), # cq
            eff_vals_4cq[cq_method], # eff
            func_pred_f(cq_raw <= 0 ? NaN : cq_raw, coefs_pob...) # cq_fluo
        )
    end
    ## end of function definitions nested within mod_bl_q

    const num_cycs = length(fluos)
    const cycs = range(1.0, num_cycs)
    const cycs_denser = Array(colon(1, (num_cycs - 1) / denser_factor, num_cycs))
    const len_bcb = length(baseline_cyc_bounds)
    const last_cyc_wt0 = floor(min_reliable_cyc) - 1 # to determine weights (`wts`) for sigmoid fitting per `min_reliable_cyc`
    ## will remain the same `if len_bcb == 0 && (last_cyc_wt0 <= 1 || num_cycs < min_reliable_cyc)`
    #
    ## set up solver
    solver = kwargs_jmp_model[:solver]
    if isa(solver, Ipopt.IpoptSolver)
        push!(solver.options, (:output_file, ipopt_print2file))
    end
    ## fit model
    if af_key == :dfc
        return fit_dfc_model()
    elseif af_key == :sfc
        return fit_sfc_model()
    end
    ## fallthrough
    error("`af_key` $af_key is not recognized.")
end # mod_bl_q()


function report_cq!(
    full_amp_out    ::AmpStepRampOutput,
    well_i          ::Integer,
    channel_i       ::Integer;
    before_128x     ::Bool =false,
    max_dr1_lb =472,
    max_dr2_lb =41,
    max_bsf_lb =4356,
    scld_max_dr1_lb ::Real =0.0089, # look like real amplification, scld_max_dr1 0.00894855, ip223, exp. 75, well A7, channel 2.
    scld_max_dr2_lb ::Real =0.000689,
    scld_max_bsf_lb ::Real =0.086
)
    if before_128x
        max_dr1_lb, max_dr2_lb, max_bsf_lb = [max_dr1_lb, max_dr2_lb, max_bsf_lb] / 128
    end
    #
    const num_cycs = size(full_amp_out.fr_ary3)[1]
    const postbl_status, cq_raw, max_dr1, max_dr2 =
        map(
            fn -> getindex(getfield(full_amp_out, fn), well_i, channel_i),
            [ :postbl_status, :cq_raw, :max_dr1, :max_dr2 ])
    const max_bsf = maximum(full_amp_out.blsub_fluos[:, well_i, channel_i])
    const b_ = full_amp_out.coefs[1, well_i, channel_i]
    const scld_max_dr1, scld_max_dr2, scld_max_bsf = [max_dr1, max_dr2, max_bsf] / full_amp_out.max_qt_fluo
    #
    if postbl_status == :Error
        const why_NaN = "postbl_status == :Error"
    elseif b_ > 0
        const why_NaN = "b > 0"
    elseif full_amp_out.cq_method == :ct && cq_raw == Ct_VAL_DomainError
        const why_NaN = "DomainError when calculating Ct"
    elseif cq_raw <= 0.1 || cq_raw >= num_cycs
        const why_NaN = "cq_raw <= 0.1 || cq_raw >= num_cycs"
    elseif max_dr1 < max_dr1_lb
        const why_NaN = "max_dr1 $max_dr1 < max_dr1_lb $max_dr1_lb"
    elseif max_dr2 < max_dr2_lb
        const why_NaN = "max_dr2 $max_dr2 < max_dr2_lb $max_dr2_lb"
    elseif max_bsf < max_bsf_lb
        const why_NaN = "max_bsf $max_bsf < max_bsf_lb $max_bsf_lb"
    elseif scld_max_dr1 < scld_max_dr1_lb
        why_NaN = "scld_max_dr1 $scld_max_dr1 < scld_max_dr1_lb $scld_max_dr1_lb"
    elseif scld_max_dr2 < scld_max_dr2_lb
        const why_NaN = "scld_max_dr2 $scld_max_dr2 < scld_max_dr2_lb $scld_max_dr2_lb"
    elseif scld_max_bsf < scld_max_bsf_lb
        const why_NaN = "scld_max_bsf $scld_max_bsf < scld_max_bsf_lb $scld_max_bsf_lb"
    else
        const why_NaN = ""
    end
    if (why_NaN != "")
        full_amp_out.cq[well_i, channel_i] = NaN
    end
    #
    for tup in (
        (:max_bsf,      max_bsf),
        (:scld_max_dr1, scld_max_dr1),
        (:scld_max_dr2, scld_max_dr2),
        (:scld_max_bsf, scld_max_bsf),
        (:why_NaN,      why_NaN))
        getfield(full_amp_out, tup[1])[well_i, channel_i] = tup[2]
    end
    return nothing
end # report_cq!


## process amplification per step
function process_amp_1sr(
    ## remove MySql dependency
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # asrp ::AmpStepRampProperties,
    # calib_info ::Union{Integer,OrderedDict},
    # fluo_well_nums ::AbstractVector,
    # well_nums ::AbstractVector,
    cyc_nums                ::Vector{I} where I <: Integer,
    fluo_well_nums          ::Vector{J} where J <: Integer,
    channel_nums            ::Vector{String},
    num_cycs                ::Integer,
    num_fluo_wells          ::Integer,
    num_channels            ::Integer,
    fr_ary3                 ::DenseArray,
    calib_data              ::Associative,
    asrp                    ::AmpStepRampProperties,
    dcv                     ::Bool, # logical, whether to perform multi-channel deconvolution
    dye_in                  ::Symbol,
    dyes_2bfild             ::AbstractVector,
    min_reliable_cyc        ::Real,
    baseline_cyc_bounds     ::AbstractVector,
    cq_method               ::Symbol,
    ct_fluos                ::AbstractVector,
    af_key                  ::Symbol,
    kwdict_mbq              ::Associative, # keyword arguments passed onto `mod_bl_q`
    ipopt_print2file_prefix ::String,
    qt_prob_rc              ::Real, # quantile probablity for fluo values per well
    kwdict_rc               ::Associative, # keyword arguments passed onto `report_cq`
    ad_cycs                 ::Union{Integer,AbstractVector},
    ctrl_well_dict          ::OrderedDict,
    cluster_method          ::ClusteringMethod,
    norm_l                  ::Real,
    expected_ncg_raw        ::AbstractMatrix,
    categ_well_vec          ::AbstractVector,
    out_format              ::Symbol, # :full, :pre_json, :json
    json_digits             ::Integer,
    verbose                 ::Bool
)
    function find_ct_fluos()

        function find_idc_useful()
            const postbl_stata = mbq_ary1 |> map[index["postbl_status"]]
            idc_useful = find(postbl_stata .== :Optimal)
            (length(idc_useful) > 0) && return idc_useful
            idc_useful = find(postbl_stata .== :UserLimit)
            (length(idc_useful) > 0) && return idc_useful
            return 1:length(postbl_status)
        end
        ## end of function definition nested within find_ct_fluos()

        if num_cycs > 2
            if length(ct_fluos) == 0
                if cq_method == :ct
                    return map(1:num_channels) do channel_i
                        const mbq_ary1 =
                            map(1:num_fluo_wells) do well_i
                                mod_bl_q(
                                    rbbs_ary3[:, well_i, channel_i];
                                    min_reliable_cyc = min_reliable_cyc,
                                    baseline_cyc_bounds = baseline_cyc_bounds[well_i, channel_i],
                                    cq_method = :cp_dr1,
                                    ct_fluo = NaN,
                                    af_key = af_key,
                                    kwdict_mbq...,
                                    verbose = verbose)
                            end
                        find_idc_useful() |>
                            map[mbq_i -> mbq_ary1[mbq_i][:cq_fluo]] |>
                            median
                    end
                else # cq_method != :ct
                    return fill(NaN, num_channels)
                end # if
            end # if
        end # if
        return ct_fluos
    end

    calc_mbq_ary2() =
        [
            begin
                ipopt_print2file = length(ipopt_print2file_prefix) == 0 ?
                    "" : "$(join([ipopt_print2file_prefix, channel_i, well_i], '_')).txt"
                mod_bl_q(
                    rbbs_ary3[:, well_i, channel_i];
                    min_reliable_cyc = min_reliable_cyc,
                    baseline_cyc_bounds = baseline_cyc_bounds[well_i, channel_i],
                    cq_method = cq_method,
                    ct_fluo = _ct_fluos[channel_i],
                    af_key = af_key,
                    kwdict_mbq...,
                    ipopt_print2file = ipopt_print2file,
                    verbose = verbose)
            end
            for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
        ]

    function set_fn_mbq!()
        for fn_mbq in fieldnames(MbqOutput)
            fv =
                [   getfield(mbq_ary2[well_i, channel_i], fn_mbq)
                    for well_i in 1:num_fluo_wells, channel_i in 1:num_channels ]
            if fn_mbq in [:blsub_fluos, :coefs, :blsub_fitted, :dr1_pred, :dr2_pred]
                fv = reshape(
                        cat(2, fv...), # 2-dim array of size (`num_cycs` or number of coefs, `num_wells * num_channels`)
                        length(fv[1,1]),
                        size(fv)...)
            end # if fn_mbq in
            setfield!(
                full_amp_out,
                fn_mbq,
                convert(typeof(getfield(full_amp_out, fn_mbq)), fv)) # `setfield!` doesn't call `convert` on its own
        end # for fn_mbq
        return nothing
    end

    function set_qt_fluos!()
        full_amp_out.qt_fluos =
            [   quantile(full_amp_out.blsub_fluos[:, well_i, channel_i], qt_prob_rc)
                for well_i in 1:num_fluo_wells, channel_i in 1:num_channels ]
        full_amp_out.max_qt_fluo = maximum(full_amp_out.qt_fluos)
        return nothing
    end

    function set_fn_rcq!()
        for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
            report_cq!(full_amp_out, well_i, channel_i; kwdict_rc...)
        end
    end
    ## end of function definitions nested within process_amp_1sr

    ## remove MySql dependency
    # fr_ary3 = get_amp_data(
    #     db_conn,
    #     "fluorescence_value", # "fluorescence_value" or "baseline_value"
    #     exp_id, asrp,
    #     fluo_well_nums, channel_nums)

    ## perform deconvolution and adjust well-to-well variation in absolute fluorescence
    const mw_ary3, k4dcv, dcvd_ary3, wva_data, wva_well_nums, rbbs_ary3 =
        dcv_aw(
            fr_ary3,
            dcv,
            channel_nums,
            ## remove MySql dependency
            # db_conn,
            # calib_info,
            # fluo_well_nums,
            # well_nums,
            calib_data,
            fluo_well_nums,
            dye_in,
            dyes_2bfild;
            aw_out_format = :array)
    #
    const size_bcb = size(baseline_cyc_bounds)
    if size_bcb == (0,) || (size_bcb == (2,) && size(baseline_cyc_bounds[1]) == ()) # can't use `eltype(baseline_cyc_bounds) <: Integer` because `JSON.parse("[1,2]")` results in `Any[1,2]` instead of `Int[1,2]`
        baseline_cyc_bounds = fill(baseline_cyc_bounds, num_fluo_wells, num_channels)
    elseif size_bcb == (num_fluo_wells, num_channels) && eltype(baseline_cyc_bounds) <: AbstractVector # final format of `baseline_cyc_bounds`
        nothing
    else
        error("`baseline_cyc_bounds` is not in the right format.")
    end # if ndims
    #
    const NaN_ary2 =
        fill(NaN, num_fluo_wells, num_channels)
    const fitted_prebl = const fitted_postbl =
        fill(AF_EMPTY_DICT[af_key], num_fluo_wells, num_channels) # once ` ::Array{EmptyAmpFitted,2}`, can't be `setfield!` to ` ::Array{SfcFitted,2}`, and vice versa
    const empty_vals_4cq =
        fill(OrderedDict{String,AbstractFloat}(), num_fluo_wells, num_channels)
    const ct_fluos_empty =
        fill(NaN, num_channels)
    const blsub_fluos = const blsub_fitted = rbbs_ary3
    const _ct_fluos = find_ct_fluos()
    #
    full_amp_out = AmpStepRampOutput(
        fr_ary3,
        mw_ary3,
        k4dcv,
        dcvd_ary3,
        wva_data,
        rbbs_ary3,
        fluo_well_nums,
        collect(1:num_channels),
        cq_method,
        fitted_prebl,
        fill(Vector{String}(), num_fluo_wells, num_channels), # bl_notes
        blsub_fluos,
        fitted_postbl,
        fill(:not_fitted, num_fluo_wells, num_channels), # postbl_status
        fill(NaN, 1, num_fluo_wells, num_channels), # coefs # size = 1 for 1st dimension may not be correct for the chosen model
        NaN_ary2, # d0
        blsub_fitted,
        zeros(0, 0, 0), # dr1_pred
        zeros(0, 0, 0), # dr2_pred
        NaN_ary2, # max_dr1
        NaN_ary2, # max_dr2
        empty_vals_4cq, # cyc_vals_4cq
        empty_vals_4cq, # eff_vals_4cq
        NaN_ary2, # cq_raw
        NaN_ary2, # cq
        NaN_ary2, # eff
        NaN_ary2, # cq_fluo
        NaN_ary2, # qt_fluos
        Inf, # max_qt_fluo
        NaN_ary2, # max_bsf
        NaN_ary2, # scld_max_bsf
        NaN_ary2, # scld_max_dr1
        NaN_ary2, # scld_max_dr2
        fill("", num_fluo_wells, num_channels), # why_NaN
        _ct_fluos, # ct_fluos
        OrderedDict{String,Vector{String}}(), # assignments_adj_labels_dict
        OrderedDict{String,AssignGenosResult}() # agr_dict
    )
    if num_cycs <= 2
        print_v(println, verbose, "Number of cycles $num_cycs <= 2, baseline subtraction and Cq calculation will not be performed.")
    else # num_cycs > 2
        const mbq_ary2 = calc_mbq_ary2()
        set_fn_mbq!()
        set_qt_fluos!()
        set_fn_rcq!()
    end # if
    #
    ## allelic discrimination
    if dcv
        full_amp_out.assignments_adj_labels_dict, full_amp_out.agr_dict =
            process_ad(
                full_amp_out,
                ad_cycs,
                ctrl_well_dict,
                cluster_method,
                norm_l,
                expected_ncg_raw,
                categ_well_vec)
    end # if dcv
    #
    ## format output
    if out_format == :full
        return full_amp_out
    end
    ## out_format == :json || out_format == :pre_json
    return AmpStepRampOutput2Bjson(
        map(fieldnames(AmpStepRampOutput2Bjson)) do fn # numeric fields only
            field_value = getfield(full_amp_out, fn)
            try
                round.(field_value, json_digits)
            catch
                field_value
            end # try
        end...) # do fn
end # process_amp_1sr





#
