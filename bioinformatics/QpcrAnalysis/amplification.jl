## amplification.jl
##
## amplification analysis
##
## issue:
## the code assumes only 1 step/ramp because the current data format
## does not allow us to break the fluorescence data down by step_id/ramp_id

import JSON: parse
import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver
import Memento: debug, warn, error
using Ipopt


## constants >>

## default for calibration
const DEFAULT_AMP_DCV               = true

## defaults for baseline model
const DEFAULT_AMP_MODEL             = SFCModel
const DEFAULT_AMP_MODEL_NAME        = :l4_enl
const DEFAULT_AMP_MODEL_DEF         = SFC_MDs[DEFAULT_AMP_MODEL_NAME]

## defaults for report_cq!()
## note for default scaled_max_dr1_lb:
## 'look like real amplification, scaled_max_dr1 0.00894855, ip223, exp. 75, well A7, channel 2`
const DEFAULT_AMP_QT_PROB           = 0.9
const DEFAULT_AMP_BEFORE_128X       = false
const DEFAULT_AMP_MAX_DR1_LB        = 472
const DEFAULT_AMP_MAX_DR2_LB        = 41
const DEFAULT_AMP_MAX_BSF_LB        = 4356
const DEFAULT_AMP_SCALED_MAX_DR1_LB = 0.0089
const DEFAULT_AMP_SCALED_MAX_DR2_LB = 0.000689
const DEFAULT_AMP_SCALED_MAX_BSF_LB = 0.086

## defaults for process_ad()
const DEFAULT_AMP_CYCS              = 0
# const DEFAULT_AMP_CTRL_WELL_DICT    = CTRL_WELL_DICT
const DEFAULT_AMP_CLUSTER_METHOD    = k_means_medoids
const DEFAULT_AMP_NORM_L            = 2
# const DEFAULT_AMP_DEFAULT_ENCGR     = DEFAULT_encgr
# const DEFAULT_AMP_CATEG_WELL_VEC    = CATEG_WELL_VEC

## default for asrp_vec
# const DEFAULT_AMP_CYC_NUMS          = Vector{Int}()

## other
const CT_VAL_DOMAINERROR = -99 ## a value that cannot be obtained by normal calculation of Ct
const KWARGS_RC_KEYS = Dict(
    "min_fluomax"   => :max_bsf_lb,
    "min_D1max"     => :max_dr1_lb,
    "min_D2max"     => :max_dr2_lb)
const KWARGS_FIT_KEYS =
    ["min_reliable_cyc", "baseline_cyc_bounds", "cq_method", "ctrl_well_dict"]


## function definitions >>

## called by dispatch()
function act(
    ::Type{Val{amplification}},
    req_dict        ::Associative;
    out_format      ::Symbol = :pre_json
)
    debug(logger, "at act(::Type{Val{amplification}})")
    ## calibration data is required
    req_key = curry(haskey)(req_dict)
    if !(req_key(CALIBRATION_INFO_KEY) &&
        typeof(req_dict[CALIBRATION_INFO_KEY]) <: Associative)
            return fail(logger, ArgumentError(
                "no calibration information found")) |> out(out_format)
    end
    const calibration_data = CalibrationData(req_dict[CALIBRATION_INFO_KEY])
    ## `report_cq!` arguments
    const kwargs_rc = Dict{Symbol,Any}(
        map(KWARGS_RC_KEYS   |> keys |> collect |> sift(req_key)) do key
            KWARGS_RC_KEYS[key] => req_dict[key]
        end) ## map
    ## `process_amp_1sr` arguments
    const kwargs_fit = Dict{Symbol,Any}(
        map(KWARGS_FIT_KEYS |> keys |> collect |> sift(req_key)) do key
            if (key == CATEG_WELL_VEC_KEY)
                :categ_well_vec =>
                    map(req_dict[CATEG_WELL_VEC_KEY]) do x
                        const element = str2sym.(x)
                        (length(element[2]) == 0) ?
                            element :
                            Colon()
                    end ## do x
            else
                Symbol(key) => str2sym.(req_dict[key])
            end ## if
        end) ## map
    ## arguments for fit_baseline_model()
    const kwargs_bl =
        begin
            const baseline_method =
                req_key(BASELINE_METHOD_KEY) &&
               req_dict[BASELINE_METHOD_KEY] 
            if      (baseline_method == SIGMOID_KEY)
                        Dict{Symbol,Any}(
                            :bl_method          =>  :l4_enl,
                            :bl_fallback_func   =>  median)
            elseif  (baseline_method == LINEAR_KEY)
                        Dict{Symbol,Any}(
                            :bl_method          =>  :lin_1ft,
                            :bl_fallback_func   =>  mean)
            elseif  (baseline_method == MEDIAN_KEY)
                        Dict{Symbol,Any}(
                            :bl_method          =>  median)
            else
                Dict{Symbol,Any}()
            end
        end
    const parsed_raw_data = parse_raw_data()
    ## create container for data and parameters
    ## to pass to process_amp_1sr
    const amp = Amp(
        parsed_raw_data...,
        calibration_data,
        IpoptSolver(print_level = 0, max_iter = 35),
        "",
        DEFAULT_AMP_DCV && parsed_raw_data[4] > 1, ## dcv && num_channels > 1
        DEFAULT_AMP_MODEL,
        kwargs_bl,
        kwargs_fit,
        kwargs_rc,
        # true,
        out_format,
        roundoff(JSON_DIGITS))
    const process_amp = try
        ## issues:
        ## 1.
        ## the new code currently assumes only 1 step/ramp
        ## because as the request body is currently structured
        ## we cannot subset the fluorescence data by step_id/ramp_id
        ## 2.
        ## need to verify that the fluorescence data complies
        ## with the constraints imposed by max_cycle and well_constraint
        #
        # const sr_key =
        #     if      req_key(STEP_ID_KEY) STEP_ID_KEY
        #     elseif  req_key(RAMP_ID_KEY) RAMP_ID_KEY
        #     else throw(ArgumentError("no step/ramp information found"))
        #     end
        # const asrp_vec = [AmpStepRampProperties(:ramp, req_dict[sr_key], DEFAULT_cyc_nums)]
        # const sr_dict = 
        #     OrderedDict(
        #         map([ asrp_vec[1] ]) do asrp
        #             join([asrp.step_or_ramp, asrp.id], "_") =>
        #                 process_amp_1sr(
        #                     # remove MySql dependency
        #                     # db_conn, exp_id, asrp, calib_info,
        #                     # fluo_well_nums, well_nums,
        #                     amp,
        #                     asrp,
        #                     out_format == :json ? :pre_json : out_format)) ## out_format_1sr
        #         end) ## do asrp
        # ## output
        # if (out_sr_dict)
        #     final_out = sr_dict
        # else
        #     const first_sr_out = first(values(sr_dict))
        #     final_out =
        #         OrderedDict(
        #             map(fieldnames(first_sr_out)) do key
        #                 key => getfield(first_sr_out, key)
        #             end)
        # end
        final_out = process_amp_1sr(amp)
        final_out[:valid] = true
        final_out        
    catch err
        return fail(logger, err; bt=true) |> out(out_format)
    end ## try
    return process_amp |> out(out_format)
end ## act(::Type{Val{amplification}})


## process amplification per step
function process_amp_1sr(
    amp                     ::Amp;
    # asrp                    ::AmpStepRampProperties,
    out_format              ::Symbol = :pre_json ## :full, :pre_json
)
    function parse_raw_data()
        const (cyc_nums, fluo_well_nums, channel_nums) =
            map([CYCLE_NUM_KEY, WELL_NUM_KEY, CHANNEL_KEY]) do key
                req_dict[RAW_DATA_KEY][key] |> unique             ## in order of appearance
            end
        const (num_cycs, num_fluo_wells, num_channels) =
            map(length, (cyc_nums, fluo_well_nums, channel_nums))
        try
            assert(req_dict[RAW_DATA_KEY][CYCLE_NUM_KEY] ==
                repeat(
                    cyc_nums,
                    outer = num_fluo_wells * num_channels))
            assert(req_dict[RAW_DATA_KEY][WELL_NUM_KEY ] ==
                repeat(
                    fluo_well_nums,
                    inner = num_cycs,
                    outer = num_channels))
            assert(req_dict[RAW_DATA_KEY][CHANNEL_KEY  ] ==
                repeat(
                    channel_nums,
                    inner = num_cycs * num_fluo_wells))
        catch
            throw(AssertionError("The format of the fluorescence data does not " *
                "lend itself to transformation into a 3-dimensional array. " *
                "Please make sure that it is sorted by channel, well number, and cycle number."))
        end ## try
        ## this code assumes that the data in the request
        ## is formatted appropriately for this transformation
        ## we can check the cycle/well/channel data if necessary
        const R = typeof(req_dict[RAW_DATA_KEY][FLUORESCENCE_VALUE_KEY][1][1])
        const raw_data ::Array{R,3} =
            reshape(
                req_dict[RAW_DATA_KEY][FLUORESCENCE_VALUE_KEY],
                num_cycs, num_fluo_wells, num_channels)
        ## rearrange data in sort order of each index
        const cyc_perm  = sortperm(cyc_nums)
        const well_perm = sortperm(fluo_well_nums)
        const chan_perm = sortperm(channel_nums)
        return (
            raw_data[cyc_perm,well_perm,chan_perm],
            num_cycs,
            num_fluo_wells,
            num_channels,
            cyc_nums[cyc_perm],
            fluo_well_nums[well_perm],
            map(channel_nums[chan_perm]) do c
                Symbol(CHANNEL_KEY, "_", c)
            end)
    end ## parse_raw_data()

    ## << end of function definition nested within amp()
    function check_baseline_cyc_bounds()
        debug(logger, "at find_baseline_cyc_bounds()")
        const size_bcb = size(baseline_cyc_bounds)
        if size_bcb == (0,) || (size_bcb == (2,) && size(baseline_cyc_bounds[1]) == ()) ## can't use `eltype(baseline_cyc_bounds) <: Integer` because `JSON.parse("[1,2]")` results in `Any[1,2]` instead of `Int[1,2]`
            return amp_init(baseline_cyc_bounds)
        elseif size_bcb == (num_fluo_wells, num_channels) && eltype(baseline_cyc_bounds) <: AbstractVector ## final format of `baseline_cyc_bounds`
            return baseline_cyc_bounds
        end
        throw(ArgumentError("`baseline_cyc_bounds` is not in the right format"))
    end ## check_baseline_cyc_bounds()

    ## calculate ct_fluos when amp_model == SFC && cq_method == :ct
    function calc_ct_fluos()
        debug(logger, "at calc_ct_fluos()")
        (length(ct_fluos) > 0) && return ct_fluos
        (cq_method != :ct)     && return ct_fluos_empty
        ## num_cycs > 2 && length(ct_fluos) == 0 && cq_method == :ct
        map(1:num_channels) do channel_i
            const fit_array1 =
                map(1:num_fluo_wells) do well_i
                    solver =
                    const fit =
                        fit_baseline_model(
                            Val{amp_model},
                            calibrated_data[:, well_i, channel_i],
                            kwargs_jmp_model;
                            amp_model = amp_model,
                            ipopt_print2file = ipopt_print2file,
                            ## parameters that apply only when fitting SFC models
                            kwargs_bl = Dict(
                                baseline_cyc_bounds => checked_baseline_cyc_bounds[well_i, channel_i],
                                min_reliable_cyc => min_reliable_cyc,
                                kwargs_fit...)) ## passed from request
                            # cq_method = :cp_dr1,
                            # ct_fluo = NaN)
                end ## do well_i
            fit_array1 |>
                mold(index(:postbl_status)) |>
                find_idc_useful |>
                mold(fit_i -> fit_array1[fit_i][:cq_fluo]) |>
                median
        end ## do channel_i
    end ## calc_ct_fluos()

    function calc_fit_array2()
        debug(logger, "at calc_fit_array2()")
        [
            begin
                ipopt_print2file = length(ipopt_print2file_prefix) == 0 ?
                    "" : "$(join([ipopt_print2file_prefix, channel_i, well_i], '_')).txt"
                fit_baseline_model(
                    Val{amp_model},
                    calibrated_data[:, well_i, channel_i],
                    kwargs_jmp_model;
                    amp_model = amp_model,
                    ipopt_print2file = ipopt_print2file,
                    ## parameters that apply only when fitting SFC models
                    kwargs_bl = Dict(
                        baseline_cyc_bounds => checked_baseline_cyc_bounds[well_i, channel_i],
                        min_reliable_cyc => min_reliable_cyc,
                        kwargs_fit...)) ## passed from request
                    # cq_method = cq_method,
                    # ct_fluo = calculated_ct_fluos[channel_i]),
            end
            for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
        ]
    end ## calc_fit_array2()

    function calc_quant_array2(fit_array2 ::AbstractArray)
        debug(logger, "at calc_quant_array2()")
        [
            amp_model == SFCModel ?
                quantify(
                    Val{amp_model},
                    fit_array2[well_i, channel_i];
                    cq_method = cq_method,
                    ct_fluo = calculated_ct_fluos[channel_i],
                ) :
                AmpQuantOutput()
            for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
        ]
    end ## calc_quant_array2()

    function set_qt_fluos!()
        debug(logger, "at set_qt_fluos!()")
        full_amp_out.qt_fluos =
            [   quantile(full_amp_out.blsub_fluos[:, well_i, channel_i], qt_prob_rc)
                for well_i in 1:num_fluo_wells, channel_i in 1:num_channels             ]
        full_amp_out.max_qt_fluo = maximum(full_amp_out.qt_fluos)
        return nothing ## side effects only
    end

    function set_fieldname_rcq!()
        debug(logger, "at set_fn_rcq!()")
        for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
            report_cq!(full_amp_out, well_i, channel_i; kwargs_rc...)
        end
        return nothing ## side effects only
    end

    ## << end of function definitions nested within process_amp_1sr

    debug(logger, "at process_amp_1sr()")

    ## remove MySql dependency
    # raw_data = get_amp_data(
    #     db_conn,
    #     "fluorescence_value", # "fluorescence_value" or "baseline_value"
    #     exp_id, asrp,
    #     fluo_well_nums, channel_nums)

    kwargs_jmp_model = Dict(:solver => amp.solver)
    ## deconvolute and normalize
    const (background_subtracted_data, k4dcv, deconvoluted_data,
            norm_data, norm_well_nums, calibrated_data) =
        calibrate(
            ## remove MySql dependency
            # db_conn,
            # calib_info,
            # fluo_well_nums,
            # well_nums,
            raw_data,
            calibration_data,
            fluo_well_nums,
            channel_nums,
            dcv,
            :array)
    #
    ## initialize output
    full_amp_out = AmpStepRampOutput(
        raw_data,
        background_subtracted_data,
        k4dcv,
        deconvoluted_data,
        norm_data,
        calibrated_data,
        fluo_well_nums,
        num_channels,
        # cq_method,
        ct_fluos)
    #
    if num_cycs <= 2
        warn(logger, "number of cycles $num_cycs <= 2: baseline subtraction " *
            "and Cq calculation will not be performed")
    else ## num_cycs > 2
        const ct_fluos_empty = fill(NaN, num_channels)
        const (checked_baseline_cyc_bounds, calculated_ct_fluos) =
            amp_model == SFC ?
                (check_baseline_cyc_bounds(), calc_ct_fluos()) :
                (baseline_cyc_bounds, ct_fluos_empty)
        full_amp_out.ct_fluos = calculated_ct_fluos
        ## baseline model fit
        const fit_array2 = calc_fit_array2()
        foreach(fieldnames(AmpModelFitOutput)) do fieldname
            set_field_from_array!(full_amp_out, fieldname, fit_array2)
        end ## do fieldname
        ## quantification
        const quant_array2 = calc_quant_array2(fit_array2)
        foreach(fieldnames(AmpQuantOutput)) do fieldname
            set_field_from_array!(full_amp_out, fieldname, quant_array2)
        end ## do fieldname
        ## qt_fluos
        set_qt_fluos!()
        ## report_cq
        set_fieldname_rcq!()
    end ## if
    #
    ## allelic discrimination
    # if dcv
    #     full_amp_out.assignments_adj_labels_dict, full_amp_out.agr_dict =
    #         process_ad(
    #             full_amp_out,
    #             kwargs_ad...)
    # end # if dcv
    #
    ## format output
    return (out_format == :full) ?
        full_amp_out :
        AmpStepRampOutput2Bjson(full_amp_out, reporting)
end ## process_amp_1sr()


## used in calc_ct_fluos()
function find_idc_useful(postbl_stata ::AbstractVector)
    idc_useful = find(postbl_stata .== :Optimal)
    (length(idc_useful) > 0) && return idc_useful
    idc_useful = find(postbl_stata .== :UserLimit)
    (length(idc_useful) > 0) && return idc_useful
    return 1:length(postbl_stata)
end ## find_idc_useful()



## function needed because `Cy0` may not be in `cycs_denser`
function func_pred_eff(cyc)
    try
        -(map([0.5, -0.5]) do epsilon
            log2(func_pred_f(cyc + epsilon, coefs_pob...))
        end...)
    catch err
        isa(err, DomainError) ?
            NaN :
            throw(ErrorException("unhandled error in func_pred_eff()"))
    end ## try
end


## quantification for SFC models
function quantify(
    fit                 ::AmpModelFit,
    amp_model           ::AmpModel, ## SFC, MAKx, MAKERGAULx
    ## parameters that apply only when fitting SFC models
    SFC_model           ::SFCModelDef,
    denser_factor       ::Int,
    cq_method           ::Symbol,
    ct_fluo             ::AbstractFloat,
    cq_fluo_only        ::Bool
)
    const num_cycs = length(fluos)
    const cycs = range(1.0, num_cycs)
    const len_denser = denser_factor * (num_cycs - 1) + 1
    const cycs_denser = Array(range(1, 1/denser_factor, len_denser))
    const raw_cycs_index = colon(1, denser_factor, len_denser)
    const funcs_pred = SFC_model.funcs_pred
    const funcs_pred_f = funcs_pred[:f]
    #
    const fitted_postbl = SFC_model.func_fit(
        cycs, blsub_fluos, wts; kwargs_jmp_model...)
    const dr1_pred = fit.funcs_pred[:dr1](cycs_denser, fit.coefs...)
    const (max_dr1, idx_max_dr1) = findmax(dr1_pred)
    const cyc_max_dr1 = cycs_denser[idx_max_dr1]
    const dr2_pred = fit.funcs_pred[:dr2](cycs_denser, fit.coefs...)
    const (max_dr2, idx_max_dr2) = findmax(dr2_pred)
    const cyc_max_dr2 = cycs_denser[idx_max_dr2]
    const Cy0 = cyc_max_dr1 - fit.funcs_pred[:f](cyc_max_dr1, fit.coefs...) / max_dr1
    const ct = try
        fit.funcs_pred[:inv](ct_fluo, fit.coefs...)
    catch err
        isa(err, DomainError) ?
            CT_VAL_DOMAINERROR :
            rethrow()
    end ## try
    const eff_pred = map(func_pred_eff, cycs_denser)
    const (eff_max, idx_max_eff) = findmax(eff_pred)
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
    return AmpQuantOutput(
        fitted_postbl,
        fitted_postbl.status, ## postbl_status
        fitted_postbl.coefs, ## coefs
        NaN) ## d0
        funcs_pred[:f](cycs, coefs_pob...), ## blsub_fitted
        dr1_pred[raw_cycs_index],
        dr2_pred[raw_cycs_index],
        max_dr1,
        max_dr2,
        cyc_vals_4cq,
        eff_vals_4cq,
        cq_raw,
        copy(cyc_vals_4cq[cq_method]), ## cq
        copy(eff_vals_4cq[cq_method]), ## eff
        funcs_pred[:f](cq_raw <= 0 ? NaN : cq_raw, coefs_pob...) ## cq_fluo
end ## quantify()


function report_cq!(
    full_amp_out        ::AmpStepRampOutput,
    well_i              ::Integer,
    channel_i           ::Integer;
    before_128x         ::Bool = DEFAULT_RCQ_BEFORE_128X,
    max_dr1_lb          ::Integer = DEFAULT_RCQ_MAX_DR1_LB,
    max_dr2_lb          ::Integer = DEFAULT_RCQ_MAX_DR2_LB,
    max_bsf_lb          ::Integer = DEFAULT_RCQ_MAX_BSF_LB,
    scaled_max_dr1_lb   ::AbstractFloat = DEFAULT_RCQ_SCALED_MAX_DR1_LB, 
    scaled_max_dr2_lb   ::AbstractFloat = DEFAULT_RCQ_SCALED_MAX_DR2_LB,
    scaled_max_bsf_lb   ::AbstractFloat = DEFAULT_RCQ_SCALED_MAX_BSF_LB,
)
    if before_128x
        max_dr1_lb, max_dr2_lb, max_bsf_lb = [max_dr1_lb, max_dr2_lb, max_bsf_lb] ./ 128
    end
    #
    const num_cycs = size(full_amp_out.raw_data, 1)
    const (postbl_status, cq_raw, max_dr1, max_dr2) =
        map([ :postbl_status, :cq_raw, :max_dr1, :max_dr2 ]) do fieldname
            fieldname -> getfield(full_amp_out, fieldname)[well_i, channel_i]
        end 
    const max_bsf = maximum(full_amp_out.blsub_fluos[:, well_i, channel_i])
    const b_ = full_amp_out.coefs[1, well_i, channel_i]
    const (scaled_max_dr1, scaled_max_dr2, scaled_max_bsf) =
        [max_dr1, max_dr2, max_bsf] ./ full_amp_out.max_qt_fluo
    const why_NaN =
        if postbl_status == :Error
            "postbl_status == :Error"
        elseif b_ > 0
            "b > 0"
        elseif full_amp_out.cq_method == :ct && cq_raw == CT_VAL_DOMAINERROR
            "DomainError when calculating Ct"
        elseif cq_raw <= 0.1 || cq_raw >= num_cycs
            "cq_raw <= 0.1 || cq_raw >= num_cycs"
        elseif max_dr1 < max_dr1_lb
            "max_dr1 $max_dr1 < max_dr1_lb $max_dr1_lb"
        elseif max_dr2 < max_dr2_lb
            "max_dr2 $max_dr2 < max_dr2_lb $max_dr2_lb"
        elseif max_bsf < max_bsf_lb
            "max_bsf $max_bsf < max_bsf_lb $max_bsf_lb"
        elseif scaled_max_dr1 < scaled_max_dr1_lb
            "scaled_max_dr1 $scaled_max_dr1 < scaled_max_dr1_lb $scaled_max_dr1_lb"
        elseif scaled_max_dr2 < scaled_max_dr2_lb
            "scaled_max_dr2 $scaled_max_dr2 < scaled_max_dr2_lb $scaled_max_dr2_lb"
        elseif scaled_max_bsf < scaled_max_bsf_lb
            "scaled_max_bsf $scaled_max_bsf < scaled_max_bsf_lb $scaled_max_bsf_lb"
        else
            ""
        end ## why_NaN
    (why_NaN != "") && (full_amp_out.cq[well_i, channel_i] = NaN)
    #
    for tup in (
        (:max_bsf,        max_bsf),
        (:scaled_max_dr1, scaled_max_dr1),
        (:scaled_max_dr2, scaled_max_dr2),
        (:scaled_max_bsf, scaled_max_bsf),
        (:why_NaN,        why_NaN))
        getfield(full_amp_out, tup[1])[well_i, channel_i] = tup[2]
    end
    return nothing ## side effects only
end ## report_cq!


## deprecated to remove MySql dependency
#
# function get_amp_data(
#    db_conn ::MySQL.MySQLHandle,
#    col_name ::String, ## "fluorescence_value" or "baseline_value"
#    exp_id ::Integer,
#    asrp ::AmpStepRampProperties,
#    fluo_well_nums ::AbstractVector, ## not `[]`, all elements are expected to be found
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
# end ## get_amp_data
