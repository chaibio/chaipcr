#=====================================================

    AmpOutput.jl

    amplification output formats per step or ramp:
    long (full) and short (for conversion to JSON)

    Author: Tom Price
    Date:   June 2019

======================================================#

import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver


## structs >>

abstract type AmpOutput end

## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
mutable struct AmpLongOutput <: AmpOutput
    raw_data                    ::Array{<: Real,3}
    ## computed in amp_analysis()
    background_subtracted_data  ::Array{<: Real,3} ## mw_ary3
    k4dcv                       ::K4Deconv
    deconvoluted_data           ::Array{<: Real,3} ## dcvd_ary3
    norm_data                   ::OrderedDict{Symbol,OrderedDict{Int,Vector{C}}} where {C <: Real} ## wva_data
    rbbs_3ary                   ::Array{<: Real,3} ## calibrated_data
    # cq_method                   ::Symbol
    ## for ct method
    ct_fluos                    ::Vector{Float_T}
    ## computed by fit_model!()
    bl_fit                      ::Array{Union{AmpModelFit,Symbol},2}
    bl_notes                    ::Array{Array{String,1},2}
    blsub_fluos                 ::Array{Float_T,3}
    quant_fit                   ::Array{Union{AmpModelFit,Symbol},2}
    quant_status                ::Array{Symbol,2}
    coefs                       ::Array{Float_T,3}
    d0                          ::Array{Float_T,2}
    quant_fluos                 ::Array{Float_T,3}
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
    ## computed in amp_analysis()
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


## constructors >>

function AmpOutput(
    ::Type{Val{long}},
    i                           ::AmpInput,
    background_subtracted_data  ::Array{<: Real,3},
    k4dcv                       ::K4Deconv,
    deconvoluted_data           ::Array{<: Real,3},
    norm_data                   ::OrderedDict{Symbol,OrderedDict{Int,Vector{C}}} where {C <: Real},
    norm_well_nums              ::AbstractVector,
    calibrated_data             ::Array{<: Real,3},
    ct_fluos                    ::Vector{Float_T};
)
    const NaN_array2        = amp_init(i, NaN)
    const zeros_array2      = amp_init(i, zeros(0, 0, 0))
    const fitted_init       = amp_init(i, FIT[i.amp_model]())
    const empty_vals_4cq    = amp_init(i, OrderedDict{Symbol, Float_T}())
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
        ## model fit
        fitted_init, ## bl_fit,
        amp_init(i, Vector{String}()), ## bl_notes
        calibrated_data, ## blsub_fluos
        fitted_init, ## quant_fit,
        amp_init(i, :not_fitted), ## quant_status
        amp_init(i, NaN, 1), ## coefs ## NB size = 1 for 1st dimension may not be correct for the chosen model
        NaN_array2, ## d0
        calibrated_data, ## quant_fluos,
        zeros_array2, ## dr1_pred
        zeros_array2, ## dr2_pred
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
    i                           ::AmpInput,
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
    const cd = reporting.(calibrated_data)
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
