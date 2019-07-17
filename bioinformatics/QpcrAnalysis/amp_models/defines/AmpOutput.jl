#===============================================================================

    AmpOutput.jl

    amplification output formats per step or ramp:
    long (full) and short (for conversion to JSON)

    Author: Tom Price
    Date:   June 2019

===============================================================================#

import DataStructures.OrderedDict
import StaticArrays: SArray, SMatrix, SVector
import Ipopt: IpoptSolver #, NLoptSolver


#===============================================================================
    structs >>
===============================================================================#

abstract type AmpOutput end

## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
mutable struct AmpLongOutput <: AmpOutput
    raw_data                    ::Array{<: Real,3} ## fr_ary3
    ## computed in amp_analysis()
    background_subtracted_data  ::Array{<: Real,3} ## mw_ary3
    norm_data                   ::SArray{S,<: Real} where {S} ## wva_data
    k_deconv                    ::DeconvolutionMatrices ## k4dcv
    deconvoluted_data           ::Array{<: Real,3} ## dcvd_ary3
    rbbs_3ary                   ::Array{Float_T,3} ## calibrated_data
    # cq_method                   ::Symbol
    ## for ct method
    ct_fluos                    ::SVector{C,Float_T} where {C}
    ## computed by fit_model!()
    bl_fit                      ::SMatrix{W,C,Union{AmpModelFit,Symbol}} where {W,C}
    bl_notes                    ::SMatrix{W,C,Vector{String}} where {W,C}
    blsub_fluos                 ::Array{Float_T,3}
    quant_fit                   ::SMatrix{W,C,Union{AmpModelFit,Symbol}} where {W,C}
    quant_status                ::SMatrix{W,C,Symbol} where {W,C}
    coefs                       ::Array{Float_T,3}
    d0                          ::SMatrix{W,C,Float_T} where {W,C}
    quant_fluos                 ::Array{Float_T,3}
    dr1_pred                    ::Array{Float_T,3}
    dr2_pred                    ::Array{Float_T,3}
    max_dr1                     ::SMatrix{W,C,Float_T} where {W,C}
    max_dr2                     ::SMatrix{W,C,Float_T} where {W,C}
    cyc_vals_4cq                ::SMatrix{W,C,OrderedDict{Symbol,Float_T}} where {W,C}
    eff_vals_4cq                ::SMatrix{W,C,OrderedDict{Symbol,Float_T}} where {W,C}
    cq_raw                      ::SMatrix{W,C,Float_T} where {W,C}
    cq                          ::SMatrix{W,C,Float_T} where {W,C}
    eff                         ::SMatrix{W,C,Float_T} where {W,C}
    cq_fluo                     ::SMatrix{W,C,Float_T} where {W,C}
    ## computed in amp_analysis()
    qt_fluos                    ::SMatrix{W,C,Float_T} where {W,C}
    max_qt_fluo                 ::Float_T
    ## computed by report_cq!()
    max_bsf                     ::SMatrix{W,C,Float_T} where {W,C}
    scaled_max_bsf              ::SMatrix{W,C,Float_T} where {W,C}
    scaled_max_dr1              ::SMatrix{W,C,Float_T} where {W,C}
    scaled_max_dr2              ::SMatrix{W,C,Float_T} where {W,C}
    why_NaN                     ::SMatrix{W,C,String} where {W,C}
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
    cq                          ::SMatrix{W,C,Float_T} where {W,C} ## cq values, applicable to sigmoid models but not to MAK models
    d0                          ::SMatrix{W,C,Float_T} where {W,C} ## starting quantity for absolute quantification
    ct_fluos                    ::SVector{C,Float_T} where {C} ## fluorescence thresholds (one value per channel) for Ct method
    assignments_adj_labels_dict ::OrderedDict{Symbol,Vector{String}} ## assigned genotypes from allelic discrimination, keyed by type of data (see `AD_DATA_CATEG` in "allelic_discrimination.jl")
end



#===============================================================================
    constructors >>
===============================================================================#

function AmpOutput(
    ::Type{Val{long}},
    i                           ::AmpInput,
    background_subtracted_data  ::Array{<: Real,3},
    k_deconv                    ::DeconvolutionMatrices,
    deconvoluted_data           ::Array{<: Real,3},
    norm_data                   ::SArray{S,R} where {S <: Tuple, R <: Real},
    norm_wells                  ::AbstractVector{Symbol},
    calibrated_data             ::Array{<: Real,3},
    ct_fluos                    ::AbstractVector;
)
    const NaN_array2        = amp_init(i, NaN)
    const fitted_init       = amp_init(i, FIT[i.amp_model]())
    const empty_vals_4cq    = amp_init(i, OrderedDict{Symbol, Float_T}())
    AmpLongOutput(
        i.raw_data, ## formerly fr_ary3
        background_subtracted_data, ## formerly mw_ary3
        norm_data, ## formerly wva_data
        k_deconv, ## formerly k4dcv
        deconvoluted_data, ## formerly dcvd_ary3
        calibrated_data, ## formerly rbbs_ary3
        # cq_method,
        ## ct_fluos
        SVector{i.num_channels, Float_T}(ct_fluos), ## ct_fluos
        ## model fit
        fitted_init, ## bl_fit,
        amp_init(i, Vector{String}()), ## bl_notes
        calibrated_data, ## blsub_fluos
        fitted_init, ## quant_fit,
        amp_init(i, :not_fitted), ## quant_status
        fill(NaN, 1, i.num_wells, i.num_channels), ## coefs ## NB size = 1 for 1st dimension may not be correct for the chosen model
        NaN_array2, ## d0
        calibrated_data, ## quant_fluos,
        calibrated_data, ## dr1_pred
        calibrated_data, ## dr2_pred
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
    k_deconv                    ::DeconvolutionMatrices,
    deconvoluted_data           ::Array{<: Real,3},
    norm_data                   ::SArray{S,R} where {S <: Tuple, R <: Real},
    norm_well_nums              ::AbstractVector,
    calibrated_data             ::Array{<: Real,3},
    ct_fluos                    ::AbstractVector;
    reporting                   ::Function = roundoff(JSON_DIGITS) ## reporting function
)
    const NaN_array2 = amp_init(i, NaN)
    const cd = reporting.(calibrated_data)
    AmpShortOutput(
        cd, ## formerly rbbs_ary3
        cd, ## blsub_fluos
        cd, ## dr1_pred
        cd, ## dr2_pred
        NaN_array2, ## d0
        NaN_array2, ## cq
        SVector{i.num_channels, Float_T}(ct_fluos), ## ct_fluos
        OrderedDict{Symbol, AssignGenosResult}()) ## agr_dict
end ## constructor
