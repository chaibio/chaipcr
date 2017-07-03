#

abstract type Analyze end

immutable ThermalPerformanceDiagnostic <: Analyze end
immutable OpticalTestSingleChannel <: Analyze end
immutable OpticalTestDualChannel <: Analyze end
immutable OpticalCal <: Analyze end
immutable ThermalConsistency <: Analyze end
# immutable YourOwnAnalyzeFunctionality <: Analyze end

const GUID2Analyze_DICT = OrderedDict(
    "thermal_performance_diagnostic" => ThermalPerformanceDiagnostic,
    "optical_test_single_channel" => OpticalTestSingleChannel,
    "optical_test_dual_channel" => OpticalTestDualChannel,
    "optical_cal" => OpticalCal,
    "thermal_consistency" => ThermalConsistency,
    # "your_own_analyze_functionality" => YourOwnAnalyzeFunctionality, # in the format of `GUID => a_DataType_whose_supertype_is_Analyze`
)



#
