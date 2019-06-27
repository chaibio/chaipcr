## types_for_amplification.jl

import DataStructures.OrderedDict


## types

abstract type            AbstractAmpFitted end
struct EmptyAmpFitted <: AbstractAmpFitted end

struct AmpStepRampProperties
    step_or_ramp    ::String
    id              ::Int
    cyc_nums        ::Vector{Int} ## accommodates non-continuous sequences of cycles
end

## `mod_bl_q` output
struct MbqOutput
    fitted_prebl    ::AbstractAmpFitted
    bl_notes        ::Vector{String}
    blsub_fluos     ::Vector{Float_T}
    fitted_postbl   ::AbstractAmpFitted
    postbl_status   ::Symbol
    coefs           ::Vector{Float_T}
    d0              ::Float_T
    blsub_fitted    ::Vector{Float_T}
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

## amplification output format per step or ramp
mutable struct AmpStepRampOutput
    ## computed in `process_amp_1sr`
    fr_ary3         ::Array{R,3} where R <: Real
    mw_ary3         ::Array{S,3} where S <: Real
    k4dcv           ::K4Deconv
    dcvd_ary3       ::Array{Float_T,3}
    wva_data        ::OrderedDict{Symbol,OrderedDict{Integer,Vector{T}}} where T <: Real
    rbbs_ary3       ::Array{Float_T,3}
    fluo_well_nums  ::Vector{Integer}
    channel_nums    ::Vector{Integer}
    cq_method       ::Symbol
    ## computed by `mod_bl_q` as part of `MbqOutput` and arranged in arrays in `process_amp_1sr`
    fitted_prebl    ::Array{AbstractAmpFitted,2}
    bl_notes        ::Array{Array{String,1},2}
    blsub_fluos     ::Array{Float_T,3}
    fitted_postbl   ::Array{AbstractAmpFitted,2}
    postbl_status   ::Array{Symbol,2}
    coefs           ::Array{Float_T,3}
    d0              ::Array{Float_T,2}
    blsub_fitted    ::Array{Float_T,3}
    dr1_pred        ::Array{Float_T,3}
    dr2_pred        ::Array{Float_T,3}
    max_dr1         ::Array{Float_T,2}
    max_dr2         ::Array{Float_T,2}
    cyc_vals_4cq    ::Array{OrderedDict{Symbol,Float_T},2}
    eff_vals_4cq    ::Array{OrderedDict{Symbol,Float_T},2}
    cq_raw          ::Array{Float_T,2}
    cq              ::Array{Float_T,2}
    eff             ::Array{Float_T,2}
    cq_fluo         ::Array{Float_T,2}
    ## computed in `process_amp_1sr` from `MbqOutput`
    qt_fluos        ::Array{Float_T,2}
    max_qt_fluo     ::Float_T
    ## computed by `report_cq!` and arranged in arrays in `process_amp_1sr`
    max_bsf         ::Array{Float_T,2}
    scld_max_bsf    ::Array{Float_T,2}
    scld_max_dr1    ::Array{Float_T,2}
    scld_max_dr2    ::Array{Float_T,2}
    why_NaN         ::Array{String,2}
    ## for ct method
    ct_fluos        ::Vector{Float_T}
    ## allelic discrimination
    assignments_adj_labels_dict ::OrderedDict{Symbol,Vector{String}}
    agr_dict        ::OrderedDict{Symbol,AssignGenosResult}
end # type AmpStepRampOutput

struct AmpStepRampOutput2Bjson
    rbbs_ary3       ::Array{Float_T,3} ## fluorescence after deconvolution and adjusting well-to-well variation
    blsub_fluos     ::Array{Float_T,3} ## fluorescence after baseline subtraction
    dr1_pred        ::Array{Float_T,3} ## dF/dc
    dr2_pred        ::Array{Float_T,3} ## d2F/dc2
    cq              ::Array{Float_T,2} ## cq values, applicable to sigmoid models but not to MAK models
    d0              ::Array{Float_T,2} ## starting quantity from absolute quanitification
    ct_fluos        ::Vector{Float_T}  ## fluorescence thresholds (one value per channel) for Ct method
    assignments_adj_labels_dict ::OrderedDict{Symbol,Vector{String}} ## assigned genotypes from allelic discrimination, keyed by type of data (see `AD_DATA_CATEG` in "allelic_discrimination.jl")
end


## constants

const Ct_VAL_DomainError = -99 ## a value that cannot be obtained by normal calculation of Ct
const DEFAULT_cyc_nums = Vector{Int}()
const KWDICT_RC_SYMBOLS = Dict(
    "min_fluomax"   => :max_bsf_lb,
    "min_D1max"     => :max_dr1_lb,
    "min_D2max"     => :max_dr2_lb)
const KWDICT_PA1_KEYWORDS =
    ["min_reliable_cyc", "baseline_cyc_bounds", "cq_method", "ctrl_well_dict"]


