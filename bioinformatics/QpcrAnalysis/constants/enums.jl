#========================

    enums.jl

    Author: Tom Price
    Date:   July 2019

=========================#

import DataStructures.OrderedDict


## Enumerated instances of type Action
## are preferred to subtypes of an abstract type:
## https://docs.julialang.org/en/v1/manual/style-guide/index.html#Avoid-confusion-about-whether-something-is-an-instance-or-a-type-1
## we can dispatch on the instances using Val{instance}
## NB in Julia v0.7 we can use the syntax @enum begin ... end
@enum Action amplification meltcurve standard_curve load_script optical_calibration thermal_performance_diagnostic thermal_consistency optical_test_single_channel optical_test_dual_channel # your_own_analyze_functionality
const ACTIONS = instances(Action)
const ACT = OrderedDict(
    zip(map(Symbol, ACTIONS), ACTIONS))


@enum DataFormat array dict both
const DATAFORMATS = instances(DataFormat)


@enum OutputFormat full_output json_output pre_json_output
const OUTPUTFORMATS = instances(OutputFormat)