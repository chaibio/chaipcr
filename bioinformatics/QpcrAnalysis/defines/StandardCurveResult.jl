#===============================================================================

    StandardCurveResult.jl

    Author: Tom Price
    Date: Dec 2018

===============================================================================#



abstract type StandardCurveResult end

struct TargetResultEle <: StandardCurveResult
    target_id   ::Int_T
    slope       ::Float_T
    offset      ::Float_T
    efficiency  ::Float_T
    r2          ::Float_T
end
const EMPTY_TRE = TargetResultEle(0, fill(NaN, 4)...)


struct GroupResultEle <: StandardCurveResult
    well        ::Vector{Int_T}
    target_id   ::Int_T
    cq_mean     ::Float_T
    cq_sd       ::Float_T
    qty_mean    ::Float_T
    qty_sd      ::Float_T
end
const EMPTY_GRE = GroupResultEle([], 0, fill(NaN, 4)...)
