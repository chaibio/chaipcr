## AmpQuantification.jl
##
## output from quantify() in amplification.jl
##
## Author: Tom Price
## Date:   June 2019

import DataStructures.OrderedDict

struct MbqOutput
    fitted_prebl    ::AmpModelFit
    bl_notes        ::Vector{String}
    blsub_fluos     ::Vector{Float_T}
    fitted_postbl   ::AmpModelFit
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
