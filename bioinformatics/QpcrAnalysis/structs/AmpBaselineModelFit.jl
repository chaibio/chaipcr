## AmpBaselineModelFit.jl
##
## output from fit_baseline_model() in amplification.jl
##
## Author: Tom Price
## Date:   July 2019


struct AmpBaselineModelFitOutput
    fitted_prebl    ::AmpModelFit
    bl_notes        ::Vector{String}
    blsub_fluos     ::Vector{Float_T}
end
