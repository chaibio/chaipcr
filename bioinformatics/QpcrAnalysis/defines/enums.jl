#===============================================================================

    enums.jl

    Dispatch on enumerated instances of a type is preferred
    to dispatch on subtypes of an abstract type:
    https://docs.julialang.org/en/v1/manual/style-guide/index.html#Avoid-confusion-about-whether-something-is-an-instance-or-a-type-1
    we can dispatch on the instances using Val{instance}
    NB in Julia v0.7 we can use the syntax @enum begin ... end

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import DataStructures.OrderedDict
import StaticArrays: SVector
import Base.string


## used in dispatch.jl
@enum Action amplification meltcurve standard_curve loadscript optical_cal thermal_performance_diagnostic thermal_consistency optical_test_single_channel optical_test_dual_channel # your_own_analyze_functionality
const ACTIONS = instances(Action)
const ACT = zip(map(String ∘ Symbol, ACTIONS), ACTIONS) |> OrderedDict
string(action ::Action) = replace(string(action), r"_", " ")

## used in various functions
@enum OutputFormat full_output json_output pre_json_output

## used in calibration.jl
@enum DataFormat array dict both

## used in get_k() in calibration.jl
@enum KMethod well_proc_mean well_proc_vec

## used in finite_diff() in shared_functions.jl
@enum FiniteDiffMethod central forward backward

## used in AmpInput.jl
@enum CqMethod cp_dr1 cp_dr2 Cy0 ct max_eff
# const CQ = instances(CqMethod) |> mold(fan([Symbol, identity])) |> OrderedDict
const CQ_METHODS = instances(CqMethod)
const CQ = zip(map(Symbol, CQ_METHODS), CQ_METHODS) |> OrderedDict
CqMethod(m ::String) = CQ[Symbol(m)]

## used in AmpInput.jl
@enum AmpOutputOption long short cq_fluo
AmpOutputOption(option ::OutputFormat) =
    option == full_output ? long : short

## used in allelic_discrimination.jl
@enum ClusteringMethod k_means k_means_medoids k_medoids


## overloaded index methods for enums
import Base: to_index
to_index(A, ind ::Enum) = to_index(A, Int(ind))
# import Base.to_indices
# enum2int(idx) = idx
# enum2int(idx ::Enum) = Int(idx)
# to_indices(A, inds...) = to_indices(A, map(enum2int, inds)...)
# import Base.getindex
# getindex(A, inds...) = getindex(A, map(enum2int, inds)...)