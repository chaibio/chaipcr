## types_for_dfc_models.jl

import DataStructures.OrderedDict
import JuMP: Model



## Dfc: different formula for each cycle
## refs:
## http://docs.julialang.org/en/stable/manual/types/#value-types
## https://discourse.julialang.org/t/avoid-repeating-the-same-using-line-for-enclosed-modules/2549/7

abstract type        AbstractDfcArg end
struct MAK2       <: AbstractDfcArg end
struct MAK3       <: AbstractDfcArg end
struct MAKERGAUL3 <: AbstractDfcArg end
struct MAKERGAUL4 <: AbstractDfcArg end

## calling `process_amp` with `dfc=QpcrAnalysis.Essentials.MAK2()` raised error `TypeError: typeassert: expected QpcrAnalysis.Essentials.Dfc, got QpcrAnalysis.Essentials.MAK2`
const dfc_DICT = OrderedDict(
    :MAK2       => MAK2,
    :MAK3       => MAK3,
    :MAKERGAUL3 => MAKERGAUL3,
    :MAKERGAUL4 => MAKERGAUL4)

abstract type DfcFitted <: AbstractAmpFitted end

struct MAK2Fitted <: DfcFitted
    max_d_idx   ::Int
    coef_strs   ::Vector{String}
    coefs       ::Vector{Float_T}
    status      ::Symbol
    obj_val     ::Float_T
    jmp_model   ::JuMP.Model
end
const MAK2Fitted_EMPTY = MAK2Fitted(
    0,                  # max_d_idx
    Vector{String}(),   # coef_strs
    zeros(0),           # coefs
    :not_fitted,        # status
    0.0,                # obj_val
    JuMP.Model())

struct MAK3Fitted <: DfcFitted
    max_d_idx   ::Int
    fb_start    ::Float_T
    bl_k_start  ::Float_T
    coef_strs   ::Vector{String}
    coefs       ::Vector{Float_T}
    status      ::Symbol
    obj_val     ::Float_T
    jmp_model   ::JuMP.Model
end
const MAK3Fitted_EMPTY = MAK3Fitted(
    0,                  # max_d_idx
    0.0,                # fb_start
    0.0,                # bl_k_start
    Vector{String}(),   # coef_strs
    zeros(0),           # coefs
    :not_fitted,        # status
    0.0,                # obj_val
    JuMP.Model())

struct MAKERGAUL3Fitted <: DfcFitted
    max_of_idx  ::Int
    coef_strs   ::Vector{String}
    coefs       ::Vector{Float_T}
    status      ::Symbol
    obj_val     ::Float_T
    jmp_model   ::JuMP.Model
end
const MAKERGAUL3Fitted_EMPTY = MAKERGAUL3Fitted(
    0,                  # max_of_idx
    Vector{String}(),   # coef_strs
    zeros(0),           # coefs
    :not_fitted,        # status
    0.0,                # obj_val
    JuMP.Model())

struct MAKERGAUL4Fitted <: DfcFitted
    max_of_idx  ::Int
    fb_start    ::Float_T
    bl_k_start  ::Float_T
    coef_strs   ::Vector{String}
    coefs       ::Vector{Float_T}
    status      ::Symbol
    obj_val     ::Float_T
    jmp_model   ::JuMP.Model
end
const MAKERGAUL4Fitted_EMPTY = MAKERGAUL4Fitted(
    0, # max_of_idx
    0.0, # fb_start
    0.0, # bl_k_start
    Vector{String}(), # coef_strs
    zeros(0), # coefs
    :not_fitted, # status
    0.0, # obj_val
    JuMP.Model())

## bounds for MAKERGAUL.jl
const fb_B_MULTIPLE     = 1.9
const d0_LB             = 1e-14
const d0_UB             = Inf # used: 0.1 (Bultmann 2013)
const eu0_inh_LB        = 0.0001
const eu0_UB_MULTIPLE   = 10
const inh_UB_MULTIPLE   = 10

## start for MAKERGAUL.jl
const eu0_START             = 7e3 # used: eu0_inh_LB, 0.01, 1, 50
const MAKERGAUL_d0_START    = 1 # used: 0, 1e-14 (change_d3), 0.01, 1 (change_d2), 50 (change_d1)
const inh_START             = 4e-6 # used: eu0_inh_LB (Infeasible for flat line), 0, 0.05, 1, (Invalid_Number_Detected for flat line), 10 (Infeasible for flat line), 50
# `:Optimal` when `max_of_idx == 1`, "Invalid_Number_Detected" for the rest: eu0_START = 0.01, inh_START = 0; eu0_START = 50, inh_START = 0.05; eu0_START = 50, inh_START = 1; eu0_START = 50, inh_START = 50;

## for MAKx.jl
const MAK_d0_START  = 0 # 0 good, 1 bad
const k_START       = 10 # used: 10 better, 2 good, 1e-10 bad, 1 bad

const AF_EMPTY_DICT = OrderedDict(
    :sfc        => SfcFitted_EMPTY,
    :MAK2       => MAK2Fitted_EMPTY,
    :MAK3       => MAK3Fitted_EMPTY,
    :MAKERGAUL3 => MAKERGAUL3Fitted_EMPTY,
    :MAKERGAUL4 => MAKERGAUL4Fitted_EMPTY)
