## AmpOutput.jl
##
## amplification output format per step or ramp
## also stripped-down struct for conversion to JSON
##
## Author: Tom Price
## Date:   June 2019

import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver


## structs >>

## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
struct AmpOutput2Bjson
    rbbs_3ary                   ::Array{Float_T,3} ## fluorescence after deconvolution and normalization
    blsub_fluos                 ::Array{Float_T,3} ## fluorescence after baseline subtraction
    dr1_pred                    ::Array{Float_T,3} ## dF/dc (slope of fluorescence/cycle)
    dr2_pred                    ::Array{Float_T,3} ## d2F/dc2
    cq                          ::Array{Float_T,2} ## cq values, applicable to sigmoid models but not to MAK models
    d0                          ::Array{Float_T,2} ## starting quantity from absolute quanitification
    ct_fluos                    ::Vector{Float_T}  ## fluorescence thresholds (one value per channel) for Ct method
    assignments_adj_labels_dict ::OrderedDict{Symbol,Vector{String}} ## assigned genotypes from allelic discrimination, keyed by type of data (see `AD_DATA_CATEG` in "allelic_discrimination.jl")
end


## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
mutable struct AmpOutput
    input                       ::AmpInput
    ## computed in process_amp_1sr()
    background_subtracted_data  ::Array{<: Real,3} ## mw_ary3
    k4dcv                       ::K4Deconv
    deconvoluted_data           ::Array{Float_T,3} ## dcvd_ary3
    norm_data                   ::OrderedDict{Symbol,OrderedDict{Integer,Vector{Float_T}}} ## wva_data
    rbbs_3ary                   ::Array{Float_T,3} ## calibrated_data
    # cq_method                   ::Symbol
    ## for ct method
    ct_fluos                    ::Vector{Float_T}
    ## computed by fit_baseline_model()
    bl_fit                      ::Array{Union{AmpModelFit,Symbol},2}
    bl_notes                    ::Array{Array{String,1},2}
    blsub_fluos                 ::Array{Float_T,3} ## baseline_subtracted_data
    ## computed by fit_quant_model()
    quant_fit                   ::Array{Union{AmpModelFit,Symbol},2}
    quant_status                ::Array{Symbol,2}
    coefs                       ::Array{Float_T,3}
    d0                          ::Array{Float_T,2}
    quant_fluos                 ::Array{Float_T,3}
    ## computed by fit_quant_model(Val{SFCModel})
    dr1_pred                    ::Array{Float_T,3}
    dr2_pred                    ::Array{Float_T,3}
    max_dr1                     ::Array{Float_T,2}
    max_dr2                     ::Array{Float_T,2}
    cyc_vals_4cq                ::Array{OrderedDict{Symbol,Float_T},2}
    eff_vals_4cq                ::Array{OrderedDict{Symbol,Float_T},2}
    cq_raw                      ::Array{Float_T,2}
    cq                          ::Array{Float_T,2}
    eff                         ::Array{Float_T,2}
    cq_fluo                     ::Array{Float_T,2}
    ## computed in process_amp_1sr()
    qt_fluos                    ::Array{Float_T,2}
    max_qt_fluo                 ::Float_T
    ## computed by report_cq!()
    max_bsf                     ::Array{Float_T,2}
    scaled_max_bsf              ::Array{Float_T,2}
    scaled_max_dr1              ::Array{Float_T,2}
    scaled_max_dr2              ::Array{Float_T,2}
    why_NaN                     ::Array{String,2}
    ## allelic discrimination output
    assignments_adj_labels_dict ::OrderedDict{Symbol,Vector{String}}
    agr_dict                    ::OrderedDict{Symbol,AssignGenosResult}
end


## constants >>

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


## constructors >>

AmpOutput2Bjson(
    o               ::AmpOutput;
    reporting       ::Function = roundoff(JSON_DIGITS) ## reporting function
) =
    AmpOutput2Bjson(
        map(fieldnames(AmpOutput2Bjson)) do fieldname
            const fieldvalue = getfield(full_amp_out, fieldname)
            try
                reporting(fieldvalue)
            catch
                fieldvalue ## non-numeric fields
            end ## try
        end...) ## do fieldname


function AmpOutput(
    input,
    background_subtracted_data,
    k4dcv,
    deconvoluted_data,
    norm_data,
    calibrated_data,
    ct_fluos
)
    const NaN_array2 = amp_init(NaN)
    const fitted_init = amp_init(FIT[amp_model]())
    const empty_vals_4cq = amp_init(OrderedDict{Symbol, AbstractFloat}())
    AmpOutput(
        input,
        background_subtracted_data, ## formerly mw_ary3
        k4dcv,
        deconvoluted_data, ## formerly dcvd_ary3
        norm_data, ## formerly wva_data
        calibrated_data, ## formerly rbbs_ary3
        # cq_method,
        ## ct_fluos
        ct_fluos, ## ct_fluos
        ## baseline model fit
        fitted_init, ## fitted_prebl,
        amp_init(Vector{String}()), ## bl_notes
        calibrated_data, ## blsub_fluos
        ## quantification model fit
        fitted_init, ## fitted_postbl,
        amp_init(:not_fitted), ## postbl_status
        amp_init(NaN, 1), ## coefs ## NB size = 1 for 1st dimension may not be correct for the chosen model
        NaN_array2, ## d0
        calibrated_data, ## blsub_fitted,
        ## quantification
        zeros(0, 0, 0), ## dr1_pred
        zeros(0, 0, 0), ## dr2_pred
        NaN_array2, ## max_dr1
        NaN_array2, ## max_dr2
        empty_vals_4cq, ## cyc_vals_4cq
        empty_vals_4cq, ## eff_vals_4cq
        NaN_array2, ## cq_raw
        NaN_array2, ## cq
        NaN_array2, ## eff
        NaN_array2, ## cq_fluo
        ## set_qt_fluos!()
        NaN_array2, ## qt_fluos
        NaN_array2, ## max_qt_fluo
        ## report_cq!()
        NaN_array2, ## max_bsf
        NaN_array2, ## scaled_max_bsf
        NaN_array2, ## scaled_max_dr1
        NaN_array2, ## scaled_max_dr2
        amp_init(""), ## why_NaN
        ## allelic discrimination
        OrderedDict{Symbol, Vector{String}}(), ## assignments_adj_labels_dict
        OrderedDict{Symbol, AssignGenosResult}()) ## agr_dict
end ## constructor


## analyse amplification per step/ramp
function amp_process_1sr(
    i                       ::AmpInput;
    # asrp                    ::AmpStepRampProperties,
    out_format              ::Symbol = :pre_json ## :full, :pre_json
)
    debug(logger, "at amp_process_1sr()")
    ## deconvolute and normalize
    const (background_subtracted_data, k4dcv, deconvoluted_data,
            norm_data, norm_well_nums, calibrated_data) =
        calibrate(
            i.raw_data,
            i.calibration_data,
            i.fluo_well_nums,
            i.channel_nums,
            i.dcv,
            :array)
    ## initialize output
    o = AmpOutput(
        i.raw_data,
        background_subtracted_data,
        k4dcv,
        deconvoluted_data,
        norm_data,
        calibrated_data,
        i.fluo_well_nums,
        i.num_channels,
        # cq_method,
        DEFAULT_AMP_CT_FLUOS)
    #
    # kwargs_jmp_model = Dict(:solver => this.solver)
    if num_cycs <= 2
        warn(logger, "number of cycles $num_cycs <= 2: baseline subtraction " *
            "and Cq calculation will not be performed")
    else ## num_cycs > 2
        ## calculate ct_fluos
        const baseline_cyc_bounds =
            check_baseline_cyc_bounds(i, DEFAULT_AMP_BASELINE_CYC_BOUNDS)
        o.ct_fluos =
            calc_ct_fluos(o, DEFAULT_AMP_CT_FLUOS, baseline_cyc_bounds)
        ## baseline model fit
        const fit_array2 = calc_fit_array2(o)
        foreach(fieldnames(AmpModelFitOutput)) do fieldname
            set_field_from_array!(o, fieldname, fit_array2)
        end ## do fieldname
        ## quantification
        const quant_array2 = calc_quant_array2(o, fit_array2)
        foreach(fieldnames(AmpQuantOutput)) do fieldname
            set_field_from_array!(o, fieldname, quant_array2)
        end ## do fieldname
        ## qt_fluos
        set_qt_fluos!(o)
        ## report_cq
        set_fieldname_rcq!(o)
    end ## if
    #
    ## allelic discrimination
    # if dcv
    #     o.assignments_adj_labels_dict, o.agr_dict =
    #         process_ad(
    #             o,
    #             kwargs_ad...)
    # end # if dcv
    #
    ## format output
    return (out_format == :full) ?
        o :
        AmpOutput2Bjson(o, reporting)
end ## amp_process_1sr()


## calculate ct_fluos
function calc_ct_fluos(
    o                       ::AmpOutput,
    ct_fluos                ::AbstractVector,
    baseline_cyc_bounds     ::AbstractVector,
)
    debug(logger, "at calc_ct_fluos()")
    const i = o.input
    const ct_fluos_empty = fill(NaN, i.num_channels)
    (i.num_cycs <= 2)       && return ct_fluos
    (length(ct_fluos) > 0)  && return ct_fluos
    (i.cq_method != :ct)    && return ct_fluos_empty
    (i.amp_model != :SFC)   && return ct_fluos_empty
    ## else
    map(1:i.num_channels) do channel_i
        const fit_array1 =
            map(1:i.num_fluo_wells) do well_i
                const kw_bl =
                    Dict{Symbol, Any}(
                        baseline_cyc_bounds => baseline_cyc_bounds[well_i, channel_i],
                        kwargs_bl(i)...)
                const fluos = o.calibrated_data[:, well_i, channel_i] 
                const fit_bl =
                    fit_baseline_model(
                        Val{SFC},
                        o,
                        fluos,
                        i.solver;
                        kw_bl...) ## parameters that apply only when fitting SFC models
                const fit_q =
                    fit_quant_model(
                        Val{SFC},
                        fit_bl;
                        solver = i.solver,
                        cq_only = true,
                        cq_method = :cp_dr1,
                        ct_fluo = NaN)
            end ## do well_i
        fit_array1 |>
            mold(index(:postbl_status)) |>
            find_idc_useful |>
            mold(fit_i -> fit_array1[fit_i][:cq_fluo]) |>
            median
    end ## do channel_i
end ## calc_ct_fluos()


## used in calc_ct_fluos()
function find_idc_useful(postbl_stata ::AbstractVector)
    idc_useful = find(postbl_stata .== :Optimal)
    (length(idc_useful) > 0) && return idc_useful
    idc_useful = find(postbl_stata .== :UserLimit)
    (length(idc_useful) > 0) && return idc_useful
    return 1:length(postbl_stata)
end ## find_idc_useful()


function calc_fit_array2(o ::AmpOutput)
    debug(logger, "at calc_fit_array2()")
    const i = o.input
    solver = i.solver
    [
        begin
            if isa(solver, Ipopt.IpoptSolver) && length(ipopt_print2file_prefix) > 0
                const ipopt_print2file =
                    string(join([ipopt_print2file_prefix, channel_i, well_i], '_')) * ".txt"
                push!(solver.options, (:output_file, ipopt_print2file))
            end
            const kw_bl =
                i.amp_model == SFC ?
                    Dict{Symbol, Any}(
                        baseline_cyc_bounds => baseline_cyc_bounds[well_i, channel_i],
                        kwargs_bl(i)...) :
                    Dict{Symbol, Any}()
            const fit_bl =
                fit_baseline_model(
                    Val{i.amp_model},
                    o,
                    o.calibrated_data[:, well_i, channel_i],
                    i.solver;
                    kw_bl...) ## parameters that apply only when fitting SFC models
            const fit_q =
                fit_quant_model(
                    Val{SFC},
                    fit_bl;
                    solver = i.solver,
                    ct_fluo = calculated_ct_fluos[channel_i],
                    kwargs_quant(i)...)


                # cq_method = cq_method,
                # ct_fluo = 
        end
        for well_i in 1:i.num_fluo_wells, channel_i in 1:i.num_channels
    ]
end ## calc_fit_array2()


function calc_quant_array2(fit_array2 ::AbstractArray)
    debug(logger, "at calc_quant_array2()")
    [
        amp_model == SFC ?
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


## setter method
function set_field_from_array!(
    o                   ::AmpOutput,
    fieldname           ::Symbol,
    data_array2         ::AbstractArray
)
    debug(logger, "at set_field_from_array!()")
    const i = o.input
    const val = [   getfield(data_array2[well_i, channel_i], fieldname)
                    for well_i in 1:i.num_fluo_wells, channel_i in 1:i.num_channels ]
    const reshaped_val =
        fieldname in [:blsub_fluos, :coefs, :blsub_fitted, :dr1_pred, :dr2_pred] ?
            ## reshape to 3D array
            reshape(
                cat(2, val...), ## 2D array of size (`num_cycs` or number of coefs, `num_wells * num_channels`)
                length(val[1, 1]),
                size(val)...) :
            val
    setfield!(
        o,
        fieldname,
        convert(typeof(getfield(o, fieldname)), reshaped_val)) ## `setfield!` doesn't call `convert` on its own
    return nothing ## side effects only
end ## set_field_from_array!()


function set_qt_fluos!(o ::AmpOutput)
    debug(logger, "at set_qt_fluos!()")
    i = o.input
    o.qt_fluos =
        [   quantile(o.blsub_fluos[:, well_i, channel_i], qt_prob_rc)
            for well_i in 1:i.num_fluo_wells, channel_i in 1:i.num_channels             ]
    o.max_qt_fluo = maximum(o.qt_fluos)
    return nothing ## side effects only
end ## set_qt_fluos!()


function set_fieldname_rcq!(o ::AmpOutput)
    debug(logger, "at set_fieldname_rcq!()")
    i = o.input
    for well_i in 1:i.num_fluo_wells, channel_i in 1:i.num_channels
        report_cq!(o, well_i, channel_i; kwargs_rc...)
    end
    return nothing ## side effects only
end ## set_fieldname_rcq!()


function report_cq!(
    o                   ::AmpOutput,
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
    const num_cycs = size(o.input.raw_data, 1)
    const (postbl_status, cq_raw, max_dr1, max_dr2) =
        map([ :postbl_status, :cq_raw, :max_dr1, :max_dr2 ]) do fieldname
            fieldname -> getfield(o, fieldname)[well_i, channel_i]
        end 
    const max_bsf = maximum(o.blsub_fluos[:, well_i, channel_i])
    const b_ = full_amp_out.coefs[1, well_i, channel_i]
    const (scaled_max_dr1, scaled_max_dr2, scaled_max_bsf) =
        [max_dr1, max_dr2, max_bsf] ./ full_amp_out.max_qt_fluo
    const why_NaN =
        if postbl_status == :Error
            "postbl_status == :Error"
        elseif b_ > 0
            "b > 0"
        elseif o.cq_method == :ct && cq_raw == AMP_CT_VAL_DOMAINERROR
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
    (why_NaN != "") && (o.cq[well_i, channel_i] = NaN)
    #
    for tup in (
        (:max_bsf,        max_bsf),
        (:scaled_max_dr1, scaled_max_dr1),
        (:scaled_max_dr2, scaled_max_dr2),
        (:scaled_max_bsf, scaled_max_bsf),
        (:why_NaN,        why_NaN))
        getfield(o, tup[1])[well_i, channel_i] = tup[2]
    end
    return nothing ## side effects only
end ## report_cq!
