## AmpStepRampOutput.jl
##
## amplification output format per step or ramp
##
## Issue:
## possible 'god object' anti-pattern: this can be fixed,
## but first the allelic discrimination code needs to be stable
##
## Author: Tom Price
## Date:   June 2019

import DataStructures.OrderedDict


## issue: rename `rbbs_3ary` as `calibrated` once juliaapi_new has been updated
mutable struct AmpStepRampOutput
    ## computed in process_amp_1sr()
    raw_data                    ::Array{<: Real,3} ## formerly fr_ary3
    background_subtracted_data  ::Array{<: Real,3} ## mw_ary3
    k4dcv                       ::K4Deconv
    deconvoluted_data           ::Array{Float_T,3} ## dcvd_ary3
    norm_data                   ::OrderedDict{Symbol,OrderedDict{Integer,Vector{Float_T}}} ## wva_data
    rbbs_3ary                   ::Array{Float_T,3} ## calibrated_data
    fluo_well_nums              ::Vector{Int}
    channel_nums                ::Vector{Int}
    # cq_method                   ::Symbol
    ## for ct method
    ct_fluos                    ::Vector{Float_T}
    ## computed by fit_baseline_model()
    fitted_prebl                ::Array{Union{AmpModelFit,Symbol},2}
    bl_notes                    ::Array{Array{String,1},2}
    blsub_fluos                 ::Array{Float_T,3}
    ## computed by fit_quantification model()
    fitted_postbl               ::Array{Union{AmpModelFit,Symbol},2}
    postbl_status               ::Array{Symbol,2}
    coefs                       ::Array{Float_T,3}
    d0                          ::Array{Float_T,2}
    blsub_fitted                ::Array{Float_T,3}
    ## computed by quantify()
    dr1_pred                    ::Array{Float_T,3}
    dr2_pred                    ::Array{Float_T,3}
    max_dr1                     ::Array{Float_T,2}
    max_dr2                     ::Array{Float_T,2}
    cyc_vals_4cq                ::Array{OrderedDict{Symbol,Float_T},2}
    eff_vals_4cq                ::Array{OrderedDict{Symbol,Float_T},2}
    cq_raw                      ::Array{Float_T,2}
    cq                          ::Array{Float_T,2}
    eff                         ::Array{Float_T,2}
    cq_fluo                     ::Array{Float_T,2}
    ## computed in process_amp_1sr()
    qt_fluos                    ::Array{Float_T,2}
    max_qt_fluo                 ::Float_T
    ## computed by report_cq!()
    max_bsf                     ::Array{Float_T,2}
    scaled_max_bsf              ::Array{Float_T,2}
    scaled_max_dr1              ::Array{Float_T,2}
    scaled_max_dr2              ::Array{Float_T,2}
    why_NaN                     ::Array{String,2}
    ## allelic discrimination output
    assignments_adj_labels_dict ::OrderedDict{Symbol,Vector{String}}
    agr_dict                    ::OrderedDict{Symbol,AssignGenosResult}
end

## constructor
function AmpStepRampOutput(
    raw_data,
    background_subtracted_data,
    k4dcv,
    deconvoluted_data,
    norm_data,
    calibrated_data,
    fluo_well_nums,
    num_channels,
    ct_fluos
)
    ## helper function
    amp_init(x...) = fill(x..., num_fluo_wells, num_channels)
    #
    const NaN_array2 = amp_init(NaN)
    const fitted_init = amp_init(FIT[amp_model]())
    const empty_vals_4cq = amp_init(OrderedDict{Symbol, AbstractFloat}())
    #
    AmpStepRampOutput(
        raw_data, ## formerly fr_ary3
        background_subtracted_data, ## formerly mw_ary3
        k4dcv,
        deconvoluted_data, ## formerly dcvd_ary3
        norm_data, ## formerly wva_data
        calibrated_data, ## formerly rbbs_ary3
        fluo_well_nums,
        collect(1:num_channels), ## channel_nums
        # cq_method,
        ## ct_fluos
        ct_fluos, ## ct_fluos
        ## model fit
        fitted_init, ## fitted_prebl,
        amp_init(Vector{String}()), ## bl_notes
        calibrated_data, ## blsub_fluos
        fitted_init, ## fitted_postbl,
        amp_init(:not_fitted), ## postbl_status
        amp_init(NaN, 1), ## coefs ## NB size = 1 for 1st dimension may not be correct for the chosen model
        NaN_array2, ## d0
        ## quantification
        calibrated_data, ## blsub_fitted,
        zeros(0, 0, 0), ## dr1_pred
        zeros(0, 0, 0), ## dr2_pred
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
        amp_init(""), ## why_NaN
        ## allelic discrimination
        OrderedDict{Symbol, Vector{String}}(), ## assignments_adj_labels_dict
        OrderedDict{Symbol, AssignGenosResult}()) ## agr_dict
end ## constructor

## setter method
function set_field_from_array!(
    full_amp_out        ::AmpStepRampOutput,
    fieldname           ::Symbol,
    data_array2         ::AbstractArray,
)
    debug(logger, "at set_fieldname_fit!()")
    const val = [   getfield(data_array2[well_i, channel_i], fieldname)
                    for well_i in 1:num_fluo_wells, channel_i in 1:num_channels ]
    const reshaped_val =
        fieldname in [:blsub_fluos, :coefs, :blsub_fitted, :dr1_pred, :dr2_pred] ?
            ## reshape to 3D array
            reshape(
                cat(2, val...), ## 2D array of size (`num_cycs` or number of coefs, `num_wells * num_channels`)
                length(val[1, 1]),
                size(val)...) :
            val
    setfield!(
        full_amp_out,
        fieldname,
        convert(typeof(getfield(full_amp_out, fieldname)), reshaped_val)) ## `setfield!` doesn't call `convert` on its own
    return nothing ## side effects only
end ## set_field_from_array!()
