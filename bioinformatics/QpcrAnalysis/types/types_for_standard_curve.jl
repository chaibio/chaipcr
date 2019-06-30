## types_for_standard_curve.jl
#
## Author: Tom Price
## Date: Dec 2018

abstract type Result end

immutable TargetResultEle <: Result
    target_id   ::Int
    slope       ::Float_T
    offset      ::Float_T
    efficiency  ::Float_T
    r2          ::Float_T
end
const EMPTY_TRE = TargetResultEle(0, fill(NaN, 4)...)

immutable GroupResultEle <: Result
    well        ::Vector{Int}
    target_id   ::Int
    cq_mean     ::Float_T
    cq_sd       ::Float_T
    qty_mean    ::Float_T
    qty_sd      ::Float_T
end
const EMPTY_GRE = GroupResultEle([], 0, fill(NaN, 4)...)
