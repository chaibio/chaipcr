## AmpQuantModelFit.jl
##
## output from fit_quant_model() in amplification.jl
##
## Author: Tom Price
## Date:   July 2019


struct AmpQuantModelFitOutput
    fitted_postbl   ::AmpModelFit
    postbl_status   ::Symbol
    coefs           ::Vector{Float_T}
    d0              ::Float_T
    blsub_fitted    ::Vector{Float_T}
end
