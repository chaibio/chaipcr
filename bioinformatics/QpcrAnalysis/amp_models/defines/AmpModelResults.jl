#==============================================================================================

    AmpModelResults.jl

    output from fit_model!()

    Author: Tom Price
    Date:   July 2019

==============================================================================================#

import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver


#==============================================================================================
    structs >>
==============================================================================================#

abstract type AmpModelResults end

## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
struct AmpLongModelResults <: AmpModelResults
    rbbs_3ary       ::Vector{Float_T}
    bl_fit          ::Union{AmpModelFit,Symbol}
    bl_notes        ::Vector{String}
    blsub_fluos     ::Vector{Float_T}
    quant_fit       ::AmpModelFit
    quant_status    ::Symbol
    coefs           ::Vector{Float_T}
    d0              ::Float_T
    quant_fluos     ::Vector{Float_T}
    dr1_pred        ::Vector{Float_T}
    dr2_pred        ::Vector{Float_T}
    max_dr1         ::Float_T
    max_dr2         ::Float_T
    cyc_vals_4cq    ::OrderedDict{Symbol,Float_T}
    eff_vals_4cq    ::OrderedDict{Symbol,Float_T}
    cq_raw          ::Float_T
    cq              ::Float_T
    eff             ::Float_T
    cq_fluo         ::Float_T
end

## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
struct AmpShortModelResults <: AmpModelResults
    # rbbs_3ary       ::Vector{Float_T}   ## fluorescence after deconvolution and normalization
    blsub_fluos     ::Vector{Float_T}   ## fluorescence after baseline subtraction
    dr1_pred        ::Vector{Float_T}   ## dF/dc (slope of fluorescence/cycle)
    dr2_pred        ::Vector{Float_T}   ## d2F/dc2
    cq              ::Float_T           ## cq values, applicable to sigmoid models but not to MAK models
    d0              ::Float_T           ## starting quantity for absolute quantification
end

struct AmpCqFluoModelResults <: AmpModelResults
    quant_status    ::Symbol
    cq_fluo         ::Float_T
end
