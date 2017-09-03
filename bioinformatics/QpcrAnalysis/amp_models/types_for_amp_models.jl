# amp_model_types

abstract type AbstractAmpFitted end
immutable EmptyAmpFitted <: AbstractAmpFitted end


# sfc: same formula for each cycle
type SfcFitted <: AbstractAmpFitted
    coef_strs::Vector{String}
    coefs::Vector{AbstractFloat}
    status::Symbol
    obj_val::AbstractFloat
    jmp_model::JuMP.Model
    init_coefs::OrderedDict{String,AbstractFloat}
end
const SfcFitted_EMPTY = SfcFitted(
    Vector{String}(), # coef_strs
    zeros(0), # coefs
    :not_fitted, # status
    0., # obj_val
    Model(), # jmp_model
    OrderedDict{String,AbstractFloat}() # init_coefs
)


# Dfc: different formula for each cycle
# refs:
# # http://docs.julialang.org/en/stable/manual/types/#value-types
# https://discourse.julialang.org/t/avoid-repeating-the-same-using-line-for-enclosed-modules/2549/7

abstract type AbstractDfcArg end
immutable MAK2 <: AbstractDfcArg end
immutable MAK3 <: AbstractDfcArg end
immutable MAKERGAUL3 <: AbstractDfcArg end
immutable MAKERGAUL4 <: AbstractDfcArg end

const dfc_DICT = OrderedDict(
    "MAK2"=>MAK2,
    "MAK3"=>MAK3,
    "MAKERGAUL3"=>MAKERGAUL3,
    "MAKERGAUL4"=>MAKERGAUL4
) # calling `process_amp` with `dfc=QpcrAnalysis.Essentials.MAK2()` raised error `TypeError: typeassert: expected QpcrAnalysis.Essentials.Dfc, got QpcrAnalysis.Essentials.MAK2`

abstract type DfcFitted <: AbstractAmpFitted end

type MAK2Fitted <: DfcFitted
    max_d_idx::Int
    coef_strs::Vector{String}
    coefs::Vector{AbstractFloat}
    status::Symbol
    obj_val::AbstractFloat
    jmp_model::JuMP.Model
end
const MAK2Fitted_EMPTY = MAK2Fitted(
    0, # max_d_idx
    Vector{String}(), # coef_strs
    zeros(0), # coefs
    :not_fitted, # status
    0., # obj_val
    Model(), # jmp_model
)

type MAK3Fitted <: DfcFitted
    max_d_idx::Int
    fb_start::AbstractFloat
    bl_k_start::AbstractFloat
    coef_strs::Vector{String}
    coefs::Vector{AbstractFloat}
    status::Symbol
    obj_val::AbstractFloat
    jmp_model::JuMP.Model
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

type MAKERGAUL3Fitted <: DfcFitted
    max_of_idx::Int
    coef_strs::Vector{String}
    coefs::Vector{AbstractFloat}
    status::Symbol
    obj_val::AbstractFloat
    jmp_model::JuMP.Model
end
const MAKERGAUL3Fitted_EMPTY = MAKERGAUL3Fitted(
    0, # max_of_idx
    Vector{String}(), # coef_strs
    zeros(0), # coefs
    :not_fitted, # status
    0., # obj_val
    Model(), # jmp_model
)

type MAKERGAUL4Fitted <: DfcFitted
    max_of_idx::Int
    fb_start::AbstractFloat
    bl_k_start::AbstractFloat
    coef_strs::Vector{String}
    coefs::Vector{AbstractFloat}
    status::Symbol
    obj_val::AbstractFloat
    jmp_model::JuMP.Model
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

#
const AF_EMPTY_DICT = OrderedDict(
    "sfc" => SfcFitted_EMPTY,
    "MAK2" => MAK2Fitted_EMPTY,
    "MAK3" => MAK3Fitted_EMPTY,
    "MAKERGAUL3" => MAKERGAUL3Fitted_EMPTY,
    "MAKERGAUL4" => MAKERGAUL4Fitted_EMPTY,
)




#
