#===============================================================================

    CalibrationParameters.jl

    macro-generated struct of parameters
    for use in calibration analysis

    Author: Tom Price
    Date:   July 2019

===============================================================================#



#===============================================================================
    constants >>
===============================================================================#

## channel descriptors
# const CHANNELS = DYES = SVector(1,2)
# const DYE_SYMBOLS = SVector(:FAM, :HEX)



#===============================================================================
    defaults >>
===============================================================================#

const DEFAULT_CAL_DCV               = true
const DEFAULT_CAL_DYE_IN            = :FAM
const DEFAULT_CAL_DYES_TO_FILL      = Vector{Symbol}()
const DEFAULT_NORM_SUBTRACT_WATER   = false
const DEFAULT_DCV_K_METHOD          = well_proc_vec



#===============================================================================
    field definitions >>
===============================================================================#

const CAL_ARGS_FIELD_DEFS = [
    Field(:dcv,                     Bool,               DEFAULT_CAL_DCV),
    Field(:dye_in,                  Symbol,             Meta.quot(DEFAULT_CAL_DYE_IN)),
    Field(:dyes_to_fill,            Vector{Symbol},     DEFAULT_CAL_DYES_TO_FILL),
    Field(:subtract_water,          Bool,               DEFAULT_NORM_SUBTRACT_WATER),
    Field(:k_method,                KMethod,            DEFAULT_DCV_K_METHOD)]



#===============================================================================
    macro calls >>
===============================================================================#

## generate struct and constructor
SCHEMA = CAL_ARGS_FIELD_DEFS
# println(@macroexpand @make_struct_from_SCHEMA CalibrationParameters)
# println(@macroexpand @make_constructor_from_SCHEMA CalibrationParameters)
@make_struct_from_SCHEMA CalibrationParameters
@make_constructor_from_SCHEMA CalibrationParameters
