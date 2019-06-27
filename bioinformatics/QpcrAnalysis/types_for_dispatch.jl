## types_for_dispatch.jl
#
## Author: Tom Price
## Date: Dec 2018

abstract type  Action                                 end
struct         Amplification                <: Action end
struct         MeltCurve                    <: Action end
struct         StandardCurve                <: Action end
struct         LoadScript                   <: Action end
struct         OpticalCal                   <: Action end
struct         ThermalPerformanceDiagnostic <: Action end
struct         ThermalConsistency           <: Action end
struct         YourOwnAnalyzeFunctionality  <: Action end
struct         OpticalTestSingleChannel     <: Action end
struct         OpticalTestDualChannel       <: Action end

global const Action_DICT = Dict(
    "amplification"                  => Amplification,
    "meltcurve"                      => MeltCurve,
    "standard_curve"                 => StandardCurve,
    "loadscript"                     => LoadScript,
    "optical_cal"                    => OpticalCal,
    "thermal_performance_diagnostic" => ThermalPerformanceDiagnostic,
    "thermal_consistency"            => ThermalConsistency,
    "optical_test_single_channel"    => OpticalTestSingleChannel,
    "optical_test_dual_channel"      => OpticalTestDualChannel
  # "your_own_analyze_functionality" => YourOwnAnalyzeFunctionality
)


#
