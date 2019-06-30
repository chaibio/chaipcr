## Actions.jl
##
## Author: Tom Price
## Date:   Dec 2018

import DataStructures.OrderedDict


## Enumerated instances of type Action
## are preferred to subtypes of an abstract type:
## https://docs.julialang.org/en/v1/manual/style-guide/index.html#Avoid-confusion-about-whether-something-is-an-instance-or-a-type-1
## we can dispatch on the instances using Val{instance}
## NB in Julia v0.7 we can use the syntax @enum begin ... end
@enum Action amplification meltcurve standard_curve load_script optical_calibration thermal_performance_diagnostic thermal_consistency optical_test_single_channel optical_test_dual_channel # your_own_analyze_functionality

const actions = instances(Action)
const Action_DICT = OrderedDict(
    zip(map(Symbol, actions), actions))
