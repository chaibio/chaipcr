#===============================================================================

    CalibrationInput.jl

    macro-generated struct of data and parameters
    intended for use in calibration analysis

    Author: Tom Price
    Date:   July 2019

===============================================================================#


#===============================================================================
    defaults >>
===============================================================================#

const DEFAULT_CAL_ARGS = CalibrationParameters()



#===============================================================================
    field definitions >>
===============================================================================#

const CAL_FIELD_DEFS = [
    Field(:data,        CalibrationData),
    Field(:args,        CalibrationParameters,      DEFAULT_CAL_ARGS)]



#===============================================================================
    macro calls >>
===============================================================================#

## generate struct and constructor
SCHEMA = CAL_FIELD_DEFS
@make_struct_from_SCHEMA CalibrationInput
@make_constructor_from_SCHEMA CalibrationInput
