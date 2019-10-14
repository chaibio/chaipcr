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
    Field definitions >>
===============================================================================#

const AMPLONGOUTPUT_FIELD_DEFS = [
    Field(:raw_data,                     Array{<: Real,3}), ## fr_ary3
    ## computed in amp_analysis()
    Field(:background_subtracted_data,   Array{<: Real,3}), ## mw_ary3
    Field(:norm_data,                    SArray{S,<: Real} where {S}), ## wva_data
    Field(:k_deconv,                     DeconvolutionMatrices), ## k4dcv
    Field(:deconvoluted_data,            Array{<: Real,3}), ## dcvd_ary3
    Field(:rbbs_ary3,                    Array{Float_T,3}), ## calibrated_data
    # cq_method,                           Symbol
    ## for ct method
    Field(:ct_fluos,                     SVector{C,Float_T} where {C}),
    ## computed by fit_model!()
    Field(:bl_fit,                       SMatrix{W,C,Union{AmpModelFit,Symbol}} where {W,C}),
    Field(:bl_notes,                     SMatrix{W,C,Vector{String}} where {W,C}),
    Field(:blsub_fluos,                  Array{Float_T,3}),
    Field(:quant_fit,                    SMatrix{W,C,Union{AmpModelFit,Symbol}} where {W,C}),
    Field(:quant_status,                 SMatrix{W,C,Symbol} where {W,C}),
    Field(:coefs,                        Array{Float_T,3}),
    Field(:d0,                           SMatrix{W,C,Float_T} where {W,C}),
    Field(:quant_fluos,                  Array{Float_T,3}),
    Field(:dr1_pred,                     Array{Float_T,3}),
    Field(:dr2_pred,                     Array{Float_T,3}),
    Field(:max_dr1,                      SMatrix{W,C,Float_T} where {W,C}),
    Field(:max_dr2,                      SMatrix{W,C,Float_T} where {W,C}),
    Field(:cyc_vals_4cq,                 SMatrix{W,C,OrderedDict{Symbol,Float_T}} where {W,C}),
    Field(:eff_vals_4cq,                 SMatrix{W,C,OrderedDict{Symbol,Float_T}} where {W,C}),
    Field(:cq_raw,                       SMatrix{W,C,Float_T} where {W,C}),
    Field(:cq,                           SMatrix{W,C,Float_T} where {W,C}),
    Field(:eff,                          SMatrix{W,C,Float_T} where {W,C}),
    Field(:cq_fluo,                      SMatrix{W,C,Float_T} where {W,C}),
    ## computed in amp_analysis()
    Field(:qt_fluos,                     SMatrix{W,C,Float_T} where {W,C}),
    Field(:max_qt_fluo,                  Float_T),
    ## computed by report_cq!()
    Field(:max_bsf,                      SMatrix{W,C,Float_T} where {W,C}),
    Field(:scaled_max_bsf,               SMatrix{W,C,Float_T} where {W,C}),
    Field(:scaled_max_dr1,               SMatrix{W,C,Float_T} where {W,C}),
    Field(:scaled_max_dr2,               SMatrix{W,C,Float_T} where {W,C}),
    Field(:why_NaN,                      SMatrix{W,C,String} where {W,C}),
    ## allelic discrimination output
    Field(:assignments_adj_labels_dict,  OrderedDict{Symbol,Vector{String}}),
    Field(:agr_dict,                     OrderedDict{Symbol,AssignGenosResult})]


const AMPSHORTOUTPUT_FIELDNAMES = [
    :rbbs_ary3,
    :blsub_fluos,
    :dr1_pred,
    :dr2_pred,
    :cq,
    :d0,
    :ct_fluos,
    :assignments_adj_labels_dict]



#===============================================================================
    struct generation >>
===============================================================================#

abstract type AmpOutput end

SCHEMA = AMPLONGOUTPUT_FIELD_DEFS
@make_struct_from_SCHEMA AmpLongOutput AmpOutput true
@make_constructor_from_SCHEMA AmpLongOutput

SCHEMA = subset_schema(
    AMPLONGOUTPUT_FIELD_DEFS,
    AMPSHORTOUTPUT_FIELDNAMES)
@make_struct_from_SCHEMA AmpShortOutput AmpOutput true
@make_constructor_from_SCHEMA AmpShortOutput



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
    const NaN_array2        = amp_init(i, NaN_T)
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
        fill(NaN_T, 1, i.num_wells, i.num_channels), ## coefs ## NB size = 1 for 1st dimension may not be correct for the chosen model
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
    const NaN_array2 = amp_init(i, NaN_T)
    const cd = reporting.(calibrated_data)
    AmpShortOutput(
        cd, ## formerly rbbs_ary3
        cd, ## blsub_fluos
        cd, ## dr1_pred
        cd, ## dr2_pred
        NaN_array2, ## d0
        NaN_array2, ## cq
        ct_fluos, ## ct_fluos
        OrderedDict{Symbol, AssignGenosResult}()) ## agr_dict
end ## constructor
