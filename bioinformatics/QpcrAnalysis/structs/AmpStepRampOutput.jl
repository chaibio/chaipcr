## AmpStepRampOutput.jl
##
## amplification output format per step or ramp
## 'god object' antipattern?
##
## Author: Tom Price
## Date:   June 2019

import DataStructures.OrderedDict


## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
mutable struct AmpStepRampOutput
    ## computed in process_amp_1sr()
    fr_ary3                 ::Array{<: Real,3} ## raw_data
    mw_ary3                 ::Array{<: Real,3} ## background_subtracted_data
    k4dcv                   ::K4Deconv
    dcvd_ary3               ::Array{Float_T,3} ## deconvoluted_dat
    wva_data                ::OrderedDict{Symbol,OrderedDict{Integer,Vector{Float_T}}} ## norm_data
    rbbs_3ary               ::Array{Float_T,3} ## calibrated_data
    fluo_well_nums          ::Vector{Int}
    channel_nums            ::Vector{Int}
    cq_method               ::Symbol
    ## computed by quantify() as part of AmpQuantification and arranged in arrays in process_amp_1sr()
    fitted_prebl            ::Array{Union{AmpModelFit,Symbol},2}
    bl_notes                ::Array{Array{String,1},2}
    blsub_fluos             ::Array{Float_T,3}
    fitted_postbl           ::Array{Union{AmpModelFit,Symbol},2}
    postbl_status           ::Array{Symbol,2}
    coefs                   ::Array{Float_T,3}
    d0                      ::Array{Float_T,2}
    blsub_fitted            ::Array{Float_T,3}
    dr1_pred                ::Array{Float_T,3}
    dr2_pred                ::Array{Float_T,3}
    max_dr1                 ::Array{Float_T,2}
    max_dr2                 ::Array{Float_T,2}
    cyc_vals_4cq            ::Array{OrderedDict{Symbol,Float_T},2}
    eff_vals_4cq            ::Array{OrderedDict{Symbol,Float_T},2}
    cq_raw                  ::Array{Float_T,2}
    cq                      ::Array{Float_T,2}
    eff                     ::Array{Float_T,2}
    cq_fluo                 ::Array{Float_T,2}
    ## computed in process_amp_1sr() from AmpQuantification
    qt_fluos                ::Array{Float_T,2}
    max_qt_fluo             ::Float_T
    ## computed by report_cq!() and arranged in arrays in process_amp_1sr()
    max_bsf                 ::Array{Float_T,2}
    scld_max_bsf            ::Array{Float_T,2}
    scld_max_dr1            ::Array{Float_T,2}
    scld_max_dr2            ::Array{Float_T,2}
    why_NaN                 ::Array{String,2}
    ## for ct method
    ct_fluos                ::Vector{Float_T}
    ## allelic discrimination
    assignments_adj_labels_dict ::OrderedDict{Symbol,Vector{String}}
    agr_dict                    ::OrderedDict{Symbol,AssignGenosResult}
end
