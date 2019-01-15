## types_for_standard_curve.jl
#
## Author: Tom Price
## Date: Dec 2018

abstract type Result end

immutable TargetResultEle <: Result
    target_id   ::Int
    slope       ::Float64
    offset      ::Float64
    efficiency  ::Float64
    r2          ::Float64
end
const EMPTY_TRE = TargetResultEle(0, fill(NaN, 4)...)

immutable GroupResultEle <: Result
    well        ::Vector{Int}
    target_id   ::Int
    cq_mean     ::Float64
    cq_sd       ::Float64
    qty_mean    ::Float64
    qty_sd      ::Float64
end
const EMPTY_GRE = GroupResultEle([], 0, fill(NaN, 4)...)
