# amp_model_types

import DataStructures.OrderedDict
import JuMP: Model

# types from amp.jl

mutable struct AmpStepRampProperties
    step_or_ramp ::String
    id ::Int
    cyc_nums ::Vector{Int} # accomodating non-continuous sequences of cycles
end

# `mod_bl_q` output
struct MbqOutput
    fitted_prebl ::AbstractAmpFitted
    bl_notes ::Vector{String}
    blsub_fluos ::Vector{Float64}
    fitted_postbl ::AbstractAmpFitted
    postbl_status ::Symbol
    coefs ::Vector{Float64}
    d0 ::AbstractFloat
    blsub_fitted ::Vector{Float64}
    dr1_pred ::Vector{Float64}
    dr2_pred ::Vector{Float64}
    max_dr1 ::AbstractFloat
    max_dr2 ::AbstractFloat
    cyc_vals_4cq ::OrderedDict{String,Float64}
    eff_vals_4cq ::OrderedDict{String,Float64}
    cq_raw ::Float64
    cq ::Float64
    eff ::Float64
    cq_fluo ::Float64
end

# amplification output format per step or ramp
mutable struct AmpStepRampOutput
    # computed in `process_amp_1sr`
    fr_ary3 ::Array{Float64,3}
    mw_ary3 ::Array{Float64,3}
    k4dcv ::K4Deconv
    dcvd_ary3 ::Array{Float64,3}
    wva_data ::OrderedDict{String,OrderedDict{Int,Vector{Float64}}}
    rbbs_ary3 ::Array{Float64,3}
    fluo_well_nums ::Vector{Int}
    channel_nums ::Vector{Int}
    cq_method ::String
    # computed by `mod_bl_q` as part of `MbqOutput` and arranged in arrays in `process_amp_1sr`
    fitted_prebl ::Array{AbstractAmpFitted,2}
    bl_notes ::Array{Array{String,1},2}
    blsub_fluos ::Array{Float64,3}
    fitted_postbl ::Array{AbstractAmpFitted,2}
    postbl_status ::Array{Symbol,2}
    coefs ::Array{Float64,3}
    d0 ::Array{Float64,2}
    blsub_fitted ::Array{Float64,3}
    dr1_pred ::Array{Float64,3}
    dr2_pred ::Array{Float64,3}
    max_dr1 ::Array{Float64,2}
    max_dr2 ::Array{Float64,2}
    cyc_vals_4cq ::Array{OrderedDict{String,Float64},2}
    eff_vals_4cq ::Array{OrderedDict{String,Float64},2}
    cq_raw ::Array{Float64,2}
    cq ::Array{Float64,2}
    eff ::Array{Float64,2}
    cq_fluo ::Array{Float64,2}
    # computed in `process_amp_1sr` from `MbqOutput`
    qt_fluos ::Array{Float64,2}
    max_qt_fluo ::Float64
    # computed by `report_cq!` and arranged in arrays in `process_amp_1sr`
    max_bsf ::Array{Float64,2}
    scld_max_bsf ::Array{Float64,2}
    scld_max_dr1 ::Array{Float64,2}
    scld_max_dr2 ::Array{Float64,2}
    why_NaN ::Array{String,2}
    # for ct method
    ct_fluos ::Vector{Float64}
    # allelic discrimination
    assignments_adj_labels_dict ::OrderedDict{String,Vector{String}}
    agr_dict ::OrderedDict{String,AssignGenosResult}
end # type AmpStepRampOutput

struct AmpStepRampOutput2Bjson
    rbbs_ary3 ::Array{Float64,3} # fluorescence after deconvolution and adjusting well-to-well variation
    blsub_fluos ::Array{Float64,3} # fluorescence after baseline subtraction
    dr1_pred ::Array{Float64,3} # dF/dc
    dr2_pred ::Array{Float64,3} # d2F/dc2
    cq ::Array{Float64,2} # cq values, applicable to sigmoid models but not to MAK models
    d0 ::Array{Float64,2} # starting quantity from absolute quanitification
    ct_fluos ::Vector{Float64} # fluorescence thresholds (one value per channel) for Ct method
    assignments_adj_labels_dict ::OrderedDict{String,Vector{String}} # assigned genotypes from allelic discrimination, keyed by type of data (see `AD_DATA_CATEG` in "allelic_discrimination.jl")
end


abstract type AbstractAmpFitted end
struct EmptyAmpFitted <: AbstractAmpFitted end

###################################################################################################

# sfc: same formula for each cycle
struct SfcFitted <: AbstractAmpFitted
    coef_strs ::Vector{String}
    coefs ::Vector{Float64}
    status ::Symbol
    obj_val ::AbstractFloat
    jmp_model ::JuMP.Model
    init_coefs ::OrderedDict{String,Float64}
end
const SfcFitted_EMPTY = SfcFitted(
    Vector{String}(), # coef_strs
    zeros(0), # coefs
    :not_fitted, # status
    0., # obj_val
    Model(), # jmp_model
    OrderedDict{String,Float64}() # init_coefs
)

# from sfc_models.jl
mutable struct SFCModelDef # non-linear model, one feature (`x`)

# included in SFC_MODEL_BASE

    name::String
    linear::Bool

    _x_strs::AbstractVector
    X_strs::AbstractVector
    coef_strs::AbstractVector
    coef_cnstrnts::AbstractVector # assume all linear

    func_init_coefs::Function

    pred_strs::OrderedDict

# added by `add*!`` functions

    func_pred_strs::OrderedDict
    funcs_pred::OrderedDict

    func_fit_str::String
    func_fit::Function

end

# from sfc_models.jl
const MD_func_keys = ["f", "inv", "bl", "dr1", "dr2"] # when `num_fts > 1`, "d*" are partial derivatives in vector of length `num_fts`

# from sfc_models.jl
# `EMPTY_fp` for `func_pred_strs` and `funcs_pred`
const EMPTY_fp = map(("", empty_func)) do empty_val
    # OrderedDict(map(MD_func_keys) do func_key # v0.4, `supertype` not defined, `typeof(some_function) == Function`
    OrderedDict{String,supertype(typeof(empty_val))}(map(MD_func_keys) do func_key # v0.5, `super` becomes `supertype`, `typeof(some_function) == #some_function AND supertype(typeof(some_function)) == Function`
        func_key => empty_val
    end) # do func_key
end # do empty_val

# from sfc_models.jl
const MD_EMPTY_vals = (
    EMPTY_fp..., # :func_pred_strs, :funcs_pred
    "", # func_fit_str
    empty_func # func_fit
)

# from sfc_models.jl
const SFC_MODEL_BASES = [ # vector of tuples

# generic

    (
    "lin_1ft",
    true,
    ["_x"],
    ["X"],
    ["c0", "c1"],
    [],
    function lin_1ft_func_init_coefs(args...; kwargs...)
        OrderedDict("c0"=>0, "c1"=>0)
    end,
    OrderedDict(
        "f" => "c0 + c1 * _x",
        "inv" => "(_x - c0) / c1",
        "bl" => "0",
        "dr1" => "c1",
        "dr2" => "0"
    )
    ),

    (
    "lin_2ft",
    true,
    ["_x1", "_x2"],
    ["X1", "X2"],
    ["c0", "c1", "c2"],
    [],
    function lin_2ft_func_init_coefs(args...; kwargs...)
        OrderedDict("c0"=>0, "c1"=>0, "c2"=>0)
    end,
    OrderedDict(
        "f" => "c0 + c1 * _x1 + c2 * _x2",
        "inv" => "0", # not applicable
        "bl" => "0",
        "dr1" => "[c1, c2]",
        "dr2" => "[0, 0]"
    )
    ),


# amplification curve

    (
    "b4",
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_"],
    [],
    function b4_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.001
        )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(X[idc_4be], Y_logit)
        b_ = lin1_coefs[2]
        e_ = -lin1_coefs[1] / b_
        return OrderedDict("b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_)
    end,
    OrderedDict(
        "f" => "c_ + (d_ - c_) / (1 + exp(b_ * (_x - e_)))",
        "inv" => "log((-d_ + _x) / (c_ - _x)) / b_ + e_",
        "bl" => "c_",
        "dr1" =>
            "(b_ * (c_ - d_) * exp(b_ * (e_ + _x)))/(exp(b_ * e_) + exp(b_ * _x))^2",
        "dr2" =>
            "(b_^2 * (c_ - d_) * exp(b_ * (e_ + _x)) * (exp(b_ * e_) - exp(b_ * _x)))/(exp(b_ * e_) + exp(b_ * _x))^3"
    )
    ),

    (
    "l4", # name
    false, # linear
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_"], # coef_strs
    ["e_ >= 1e-100"], # removing bound did not improve Cq accuracy
    function l4_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        return OrderedDict("b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_)
    end,
    OrderedDict( # pred_strs
        "f" => "c_ + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "((e_^b_ * (-d_ + _x))/(c_ - _x))^(1/b_)",
        "bl" => "c_",
        "dr1" => "(b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
        "dr2" =>
            "(b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
    )
    ),

    (
    "l4_hbl", # hyperbolic baseline: increase before log-phase then minimal at plateau (most simple version is -1/x). baseline model `c + bl_k / (e_ - x)` model caused "Ipopt finished with status Restoration_Failed"
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "bl_k", "bl_o"],
    ["e_ >= 1e-100"],
    function l4_hbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        bl_k = 0
        bl_o = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "bl_k"=>bl_k, "bl_o"=>bl_o
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + bl_k / (_x + bl_o) + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + bl_k / (_x + bl_o)",
        "dr1" =>
            "-bl_k / (_x + bl_o)^2 + (b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
        "dr2" =>
            "bl_k / (_x + bl_o)^3 + (b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
    )
    ),

    (
    "l4_lbl", # linear baseline
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "k1"],
    ["e_ >= 1e-100"],
    function l4_lbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        k1 = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "k1"=>k1
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + k1 * _x + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + k1 * _x",
        "dr1" =>
            "k1 + (b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
        "dr2" =>
            "(b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
    )
    ),

    (
    "l4_qbl", # quadratic baseline
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "k1", "k2"],
    ["e_ >= 1e-100"],
    function l4_qbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        k1 = 0
        k2 = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "k1"=>k1, "k2"=>k2
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + k1 * _x + k2 * _x^2 + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + k1 * _x + k2 * _x^2",
        "dr1" =>
            "k1 + 2 * k2 * _x + (b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
        "dr2" =>
            "2 * k2 + (b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
    )
    ),

    (
    "l4_enl", # name
    false, # linear
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_"], # coef_strs
    [], # coef_cnstrnts
    function l4_enl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = -lin1_coefs[1] / b_
        return OrderedDict("b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_)
    end,
    OrderedDict( # pred_strs
        "f" => "c_ + (d_ - c_) / (1 + exp(b_ * (log(_x) - e_)))",
        "inv" => "((exp(e_ * b_) * (-d_ + _x))/(c_ - _x))^(1/b_)",
        "bl" => "c_",
        "dr1" => "(b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
        "dr2" =>
            "(b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
    )
    ),

    (
    "l4_enl_hbl", # hyperbolic baseline: increase before log-phase then minimal at plateau (most simple version is -1/x). baseline model `c + bl_k / (e_ - x)` model caused "Ipopt finished with status Restoration_Failed"
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "bl_k", "bl_o"],
    [],
    function l4_enl_hbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        bl_k = 0
        bl_o = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "bl_k"=>bl_k, "bl_o"=>bl_o
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + bl_k / (_x + bl_o) + (d_ - c_) / (1 + exp(b_ * (log(_x) - e_)))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + bl_k / (_x + bl_o)",
        "dr1" =>
            "-bl_k / (_x + bl_o)^2 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
        "dr2" =>
            "bl_k / (_x + bl_o)^3 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
    )
    ),

    (
    "l4_enl_lbl", # linear baseline
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "k1"],
    [],
    function l4_enl_lbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        k1 = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "k1"=>k1
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + k1 * _x + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + k1 * _x",
        "dr1" =>
            "k1 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
        "dr2" =>
            "(b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
    )
    ),

    (
    "l4_enl_qbl", # quadratic baseline
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "k1", "k2"],
    [],
    function l4_enl_qbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        k1 = 0
        k2 = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "k1"=>k1, "k2"=>k2
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + k1 * _x + k2 * _x^2 + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + k1 * _x + k2 * _x^2",
        "dr1" =>
            "k1 + 2 * k2 * _x + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
        "dr2" =>
            "2 * k2 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
    )
    )
]

# from sfc_models.jl
# generate generic md objects
const MDs = OrderedDict(map(SFC_MODEL_BASES) do sfc_model_base
    sfc_model_base[1] => SFCModelDef(
        sfc_model_base...,
        deepcopy(MD_EMPTY_vals)...
    )
end) # do generic_sfc_model_base

# from sfc_models.jl
# choose model for amplification curve fitting
const AMP_MODEL_NAME = "l4_enl"
const AMP_MD = MDs[AMP_MODEL_NAME]

###################################################################################################

# Dfc: different formula for each cycle
# refs:
# # http://docs.julialang.org/en/stable/manual/types/#value-types
# https://discourse.julialang.org/t/avoid-repeating-the-same-using-line-for-enclosed-modules/2549/7

abstract type AbstractDfcArg end
struct MAK2 <: AbstractDfcArg end
struct MAK3 <: AbstractDfcArg end
struct MAKERGAUL3 <: AbstractDfcArg end
struct MAKERGAUL4 <: AbstractDfcArg end

const dfc_DICT = OrderedDict(
    "MAK2" => MAK2,
    "MAK3" => MAK3,
    "MAKERGAUL3" => MAKERGAUL3,
    "MAKERGAUL4" => MAKERGAUL4
) # calling `process_amp` with `dfc=QpcrAnalysis.Essentials.MAK2()` raised error `TypeError: typeassert: expected QpcrAnalysis.Essentials.Dfc, got QpcrAnalysis.Essentials.MAK2`

abstract type DfcFitted <: AbstractAmpFitted end

struct MAK2Fitted <: DfcFitted
    max_d_idx ::Int
    coef_strs ::Vector{String}
    coefs ::Vector{Float64}
    status ::Symbol
    obj_val ::Float64
    jmp_model ::JuMP.Model
end
const MAK2Fitted_EMPTY = MAK2Fitted(
    0, # max_d_idx
    Vector{String}(), # coef_strs
    zeros(0), # coefs
    :not_fitted, # status
    0., # obj_val
    Model(), # jmp_model
)

struct MAK3Fitted <: DfcFitted
    max_d_idx ::Int
    fb_start ::Float64
    bl_k_start ::Float64
    coef_strs ::Vector{String}
    coefs ::Vector{Float64}
    status ::Symbol
    obj_val ::Float64
    jmp_model ::JuMP.Model
end
const MAK3Fitted_EMPTY = MAK3Fitted(
    0, # max_d_idx
    0., # fb_start
    0., # bl_k_start
    Vector{String}(), # coef_strs
    zeros(0), # coefs
    :not_fitted, # status
    0., # obj_val
    Model(), # jmp_model
)

struct MAKERGAUL3Fitted <: DfcFitted
    max_of_idx ::Int
    coef_strs ::Vector{String}
    coefs ::Vector{Float64}
    status ::Symbol
    obj_val ::Float64
    jmp_model ::JuMP.Model
end
const MAKERGAUL3Fitted_EMPTY = MAKERGAUL3Fitted(
    0, # max_of_idx
    Vector{String}(), # coef_strs
    zeros(0), # coefs
    :not_fitted, # status
    0., # obj_val
    Model(), # jmp_model
)

struct MAKERGAUL4Fitted <: DfcFitted
    max_of_idx ::Int
    fb_start ::Float64
    bl_k_start ::Float64
    coef_strs ::Vector{String}
    coefs ::Vector{Float64}
    status ::Symbol
    obj_val ::Float64
    jmp_model ::JuMP.Model
end
const MAKERGAUL4Fitted_EMPTY = MAKERGAUL4Fitted(
    0, # max_of_idx
    0., # fb_start
    0., # bl_k_start
    Vector{String}(), # coef_strs
    zeros(0), # coefs
    :not_fitted, # status
    0., # obj_val
    Model(), # jmp_model
)


# bounds from MAKERGAUL.jl
const fb_B_MULTIPLE = 1.9
const d0_LB = 1e-14
const d0_UB = Inf # used: 0.1 (Bultmann 2013)
const eu0_inh_LB = 0.0001
const eu0_UB_MULTIPLE = 10
const inh_UB_MULTIPLE = 10

# start from MAKERGAUL.jl
const eu0_START = 7e3 # used: eu0_inh_LB, 0.01, 1, 50
const MAKERGAUL_d0_START = 1 # used: 0, 1e-14 (change_d3), 0.01, 1 (change_d2), 50 (change_d1)
const inh_START = 4e-6 # used: eu0_inh_LB (Infeasible for flat line), 0, 0.05, 1, (Invalid_Number_Detected for flat line), 10 (Infeasible for flat line), 50
# `:Optimal` when `max_of_idx == 1`, "Invalid_Number_Detected" for the rest: eu0_START = 0.01, inh_START = 0; eu0_START = 50, inh_START = 0.05; eu0_START = 50, inh_START = 1; eu0_START = 50, inh_START = 50;

# from MAKx.jl
const MAK_d0_START = 0 # 0 good, 1 bad
const k_START = 10 # used: 10 better, 2 good, 1e-10 bad, 1 bad


#
const AF_EMPTY_DICT = OrderedDict(
    "sfc" => SfcFitted_EMPTY,
    "MAK2" => MAK2Fitted_EMPTY,
    "MAK3" => MAK3Fitted_EMPTY,
    "MAKERGAUL3" => MAKERGAUL3Fitted_EMPTY,
    "MAKERGAUL4" => MAKERGAUL4Fitted_EMPTY,
)


#
