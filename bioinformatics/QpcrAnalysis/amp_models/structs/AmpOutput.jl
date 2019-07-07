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

abstract type AmpOutput end

## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
mutable struct AmpLongOutput <: AmpOutput
    raw_data                    ::Array{<: Real,3}
    ## computed in amp_process_1sr()
    background_subtracted_data  ::Array{<: Real,3} ## mw_ary3
    k4dcv                       ::K4Deconv
    deconvoluted_data           ::Array{<: Real,3} ## dcvd_ary3
    norm_data                   ::OrderedDict{Symbol,OrderedDict{Int,Vector{C}}} where {C <: Real} ## wva_data
    rbbs_3ary                   ::Array{<: Real,3} ## calibrated_data
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
    ## computed in amp_process_1sr()
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

## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
mutable struct AmpShortOutput <: AmpOutput
    rbbs_3ary                   ::Array{Float_T,3} ## fluorescence after deconvolution and normalization
    blsub_fluos                 ::Array{Float_T,3} ## fluorescence after baseline subtraction
    dr1_pred                    ::Array{Float_T,3} ## dF/dc (slope of fluorescence/cycle)
    dr2_pred                    ::Array{Float_T,3} ## d2F/dc2
    cq                          ::Array{Float_T,2} ## cq values, applicable to sigmoid models but not to MAK models
    d0                          ::Array{Float_T,2} ## starting quantity for absolute quantification
    ct_fluos                    ::Vector{Float_T}  ## fluorescence thresholds (one value per channel) for Ct method
    assignments_adj_labels_dict ::OrderedDict{Symbol,Vector{String}} ## assigned genotypes from allelic discrimination, keyed by type of data (see `AD_DATA_CATEG` in "allelic_discrimination.jl")
end


mutable struct AmpCqOnlyOutput <: AmpOutput
    cq_fluo                     ::Array{Float_T,2}
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

function AmpOutput(
    ::Type{Val{long}},
    raw_data                    ::AmpRawData{<: Real},
    background_subtracted_data  ::Array{<: Real,3},
    k4dcv                       ::K4Deconv,
    deconvoluted_data           ::Array{<: Real,3},
    norm_data                   ::OrderedDict{Symbol,OrderedDict{Int,Vector{C}}} where {C <: Real},
    norm_well_nums              ::AbstractVector,
    calibrated_data             ::Array{<: Real,3},
    ct_fluos                    ::Vector{Float_T};
)
    const NaN_array2        = amp_init(i, NaN)
    const fitted_init       = amp_init(i, FIT[i, i.amp_model]())
    const empty_vals_4cq    = amp_init(i, OrderedDict{Symbol, AbstractFloat}())
    AmpLongOutput(
        i.raw_data,
        background_subtracted_data, ## formerly mw_ary3
        k4dcv,
        deconvoluted_data, ## formerly dcvd_ary3
        norm_data, ## formerly wva_data
        calibrated_data, ## formerly rbbs_ary3
        # cq_method,
        ## ct_fluos
        ct_fluos, ## ct_fluos
        ## baseline model fit
        fitted_init, ## bl_fit,
        amp_init(i, Vector{String}()), ## bl_notes
        calibrated_data, ## blsub_fluos
        ## quantification model fit
        fitted_init, ## quant_fit,
        amp_init(i, :not_fitted), ## quant_status
        amp_init(i, NaN, 1), ## coefs ## NB size = 1 for 1st dimension may not be correct for the chosen model
        NaN_array2, ## d0
        calibrated_data, ## quant_fluos,
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
        amp_init(i, ""), ## why_NaN
        ## allelic discrimination
        OrderedDict{Symbol, Vector{String}}(), ## assignments_adj_labels_dict
        OrderedDict{Symbol, AssignGenosResult}()) ## agr_dict
end ## constructor


function AmpOutput(
    ::Type{Val{short}},
    background_subtracted_data  ::Array{<: Real,3},
    k4dcv                       ::K4Deconv,
    deconvoluted_data           ::Array{<: Real,3},
    norm_data                   ::OrderedDict{Symbol,OrderedDict{Int,Vector{C}}} where {C <: Real},
    norm_well_nums              ::AbstractVector,
    calibrated_data             ::Array{<: Real,3},
    ct_fluos                    ::Vector{Float_T};
    reporting                   ::Function = roundoff(JSON_DIGITS) ## reporting function
)
    const NaN_array2 = amp_init(i, NaN)
    const cd = reporting(calibrated_data)
    AmpShortOutput(
        cd, ## formerly rbbs_ary3
        cd, ## blsub_fluos
        zeros(0, 0, 0), ## dr1_pred
        zeros(0, 0, 0), ## dr2_pred
        NaN_array2, ## d0
        NaN_array2, ## cq
        ct_fluos, ## ct_fluos
        OrderedDict{Symbol, AssignGenosResult}()) ## agr_dict
end ## constructor


AmpOutput(::Type{Val{cq_only}}, i ::AmpInput, args...) =
    AmpCqOnlyOutput(amp_init(i, NaN))


## calculate ct_fluos
function calc_ct_fluos(
    o                       ::AmpOutput,
    i                       ::AmpInput,
    ct_fluos                ::AbstractVector,
    baseline_cyc_bounds     ::AbstractArray,
)
    debug(logger, "at calc_ct_fluos()")
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
                const fluos = o.rbbs_3ary[:, well_i, channel_i]
                const fit_bl =
                    fit_baseline_model(
                        Val{SFC},
                        o,
                        i,
                        fluos;
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


function calc_fit_array2(
    i                       ::AmpInput,
    o                       ::AmpOutput, 
    bl_cyc_bounds           ::AbstractArray,
)
    debug(logger, "at calc_fit_array2()")
    solver = i.solver
    const prefix = i.ipopt_print2file_prefix
    [
        begin
            if isa(solver, Ipopt.IpoptSolver) && length(prefix) > 0
                const ipopt_file = string(join([prefix, channel_i, well_i], '_')) * ".txt"
                push!(solver.options, (:output_file, ipopt_file))
            end
            const kw_bl =
                i.amp_model == SFCModel ?
                    Dict{Symbol, Any}(
                        :baseline_cyc_bounds => bl_cyc_bounds[well_i, channel_i],
                        kwargs_bl(i)...) :
                    Dict{Symbol, Any}()
            const fit_bl =
                fit_baseline_model(
                    Val{i.amp_model},
                    i,
                    o,
                    o.rbbs_3ary[:, well_i, channel_i];
                    kw_bl...) ## parameters that apply only when fitting SFC models
            const fit_q =
                fit_quant_model(
                    Val{SFCModel},
                    fit_bl;
                    solver = i.solver,
                    ct_fluo = o.ct_fluos[channel_i],
                    kwargs_quant(i)...)


                # cq_method *= cq_method,
                # ct_fluo = 
        end
        for well_i in 1:i.num_fluo_wells, channel_i in 1:i.num_channels
    ]
end ## calc_fit_array2()


function calc_quant_array2(
    o                   ::AmpOutput,
    fit_array2          ::AbstractArray
)
    debug(logger, "at calc_quant_array2()")
    const i = o.input
    [
        i.amp_model == SFCModel ?
            fit_quant_model(
                Val{SFCModel},
                fit_array2[well_i, channel_i],
                solver = i.solver,
                cq_method = cq_method,
                ct_fluo = o.ct_fluos[channel_i],
            ) :
            AmpQuantModelFit()
        for well_i in 1:i.num_fluo_wells, channel_i in 1:i.num_channels
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
            for well_i in 1:i.num_fluo_wells, channel_i in 1:i.num_channels ]
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


AmpJSONOutput(
    o               ::AmpOutput;
    reporting       ::Function = roundoff(JSON_DIGITS) ## reporting function
) =
    AmpJSONOutput(
        map(fieldnames(AmpJSONOutput)) do fieldname
            const fieldvalue = getfield(o, fieldname)
            try 
                reporting(fieldvalue)
            catch()
                fieldvalue ## non-numeric fields
            end ## try
        end...) ## do fieldname
