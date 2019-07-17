#===============================================================================

    CalibrationParameters.jl

    struct of calibration analysis parameters
    to be included in AmpInput and McInput structs

    Author: Tom Price
    Date:   July 2019

===============================================================================#


struct CalibrationParameters
    dcv                     ::Bool
    dye_in                  ::Symbol
    dyes_to_fill            ::AbstractVector
    subtract_water          ::Bool
    k_method                ::KMethod
end
