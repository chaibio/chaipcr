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


## used in dispatch.jl
@enum Action amplification meltcurve standard_curve load_script optical_calibration thermal_performance_diagnostic thermal_consistency optical_test_single_channel optical_test_dual_channel # your_own_analyze_functionality
const ACTIONS = instances(Action)
const ACT = OrderedDict(
    zip(map(Symbol, ACTIONS), ACTIONS))

## used in various functions
@enum OutputFormat full_output json_output pre_json_output
const OUTPUTFORMATS = instances(OutputFormat)

## used in calibration.jl
@enum DataFormat array dict both
const DATAFORMATS = instances(DataFormat)

## used in get_k() in calibration.jl
@enum WellProc well_proc_mean well_proc_vec

## used in finite_diff() in shared_functions.jl
@enum FiniteDiffMethod central forward backward

## used in AmpInput.jl
@enum CqMethod cp_dr1 cp_dr2 Cy0 ct max_eff
CqMethod(m ::String) = CqMethod(findfirst(map(string, instances(CqMethod)), m) - 1)

## used in AmpInput.jl
@enum AmpOutputOption long short cq_fluo
AmpOutputOption(option ::OutputFormat) =
    option == full_output ? long : short

## used in allelic_discrimination.jl
@enum ClusteringMethod k_means k_means_medoids k_medoids
const CLUSTERINGMETHODS = instances(ClusteringMethod)
