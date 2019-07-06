## AmpQuantOutput.jl
##
## output from quantify() in amplification.jl
##
## Author: Tom Price
## Date:   July 2019

import DataStructures.OrderedDict


struct AmpQuantOutput
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

## null constructor
AmpQuantOutput() =
    AmpQuantOutput(
        NaN,            ## dr1_pred
        NaN,            ## dr2_pred
        Inf,            ## max_dr1
        Inf,            ## max_dr2
        OrderedDict(),  ## cyc_vals_4cq
        OrderedDict(),  ## eff_vals_4cq
        NaN,            ## cq_raw
        NaN,            ## cq
        NaN,            ## eff
        NaN)            ## cq_fluo
