#===============================================================================

    AmpModelResults.jl

    output from fit_model!()

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver


#===============================================================================
    Field definitions >>
===============================================================================#

## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
const AMPLONGMODELRESULTS_FIELD_DEFS = [
    Field(:rbbs_3ary,        Vector{Float_T}),
    Field(:bl_fit,           Union{AmpModelFit,Symbol}),
    Field(:bl_notes,         Vector{String}),
    Field(:blsub_fluos,      Vector{Float_T}),
    Field(:quant_fit,        AmpModelFit),
    Field(:quant_status,     Symbol),
    Field(:coefs,            Vector{Float_T}),
    Field(:d0,               Float_T),
    Field(:quant_fluos,      Vector{Float_T}),
    Field(:dr1_pred,         Vector{Float_T}),
    Field(:dr2_pred,         Vector{Float_T}),
    Field(:max_dr1,          Float_T),
    Field(:max_dr2,          Float_T),
    Field(:cyc_vals_4cq,     OrderedDict{Symbol,Float_T}),
    Field(:eff_vals_4cq,     OrderedDict{Symbol,Float_T}),
    Field(:cq_raw,           Float_T),
    Field(:cq,               Float_T),
    Field(:eff,              Float_T),
    Field(:cq_fluo,          Float_T)]


const AMPSHORTMODELRESULTS_FIELDNAMES = [
    # rbbs_3ary,
    :blsub_fluos,
    :dr1_pred,
    :dr2_pred,
    :cq,
    :d0]


const AMPCQFLUOMODELRESULTS_FIELDNAMES = [
    :quant_status,
    :cq_fluo]



#===============================================================================
    struct and constructor generation >>
===============================================================================#

abstract type AmpModelResults end

SCHEMA = AMPLONGMODELRESULTS_FIELD_DEFS
@make_struct_from_SCHEMA AmpLongModelResults AmpModelResults
@make_constructor_from_SCHEMA AmpLongModelResults

SCHEMA = subset_schema(
    AMPLONGMODELRESULTS_FIELD_DEFS,
    AMPSHORTMODELRESULTS_FIELDNAMES)
@make_struct_from_SCHEMA AmpShortModelResults AmpModelResults
@make_constructor_from_SCHEMA AmpShortModelResults

SCHEMA = subset_schema(
    AMPLONGMODELRESULTS_FIELD_DEFS,
    AMPCQFLUOMODELRESULTS_FIELDNAMES)
@make_struct_from_SCHEMA AmpCqFluoModelResults AmpModelResults
@make_constructor_from_SCHEMA AmpCqFluoModelResults
