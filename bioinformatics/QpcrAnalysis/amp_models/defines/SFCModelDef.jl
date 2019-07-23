#===============================================================================

    SFCModelDef.jl

    struct containing SFC model definition

    Author: Tom Price
    Date:   June 2019

===============================================================================#

import DataStructures.OrderedDict


mutable struct SFCModelDef ## non-linear model, one feature (`x`)
    ## included in SFC_MODEL_BASE
    name            ::SFCModelName
    linear          ::Bool
    _x_strs         ::Vector{String}
    X_strs          ::Vector{String}
    coef_strs       ::Vector{String}
    coef_cnstrnts   ::AbstractVector ## assume all linear
    func_init_coefs ::Function
    pred_strs       ::OrderedDict{Symbol,String}
    ## added by `add*!`` functions
    func_pred_strs  ::OrderedDict{Symbol,String}
    funcs_pred      ::OrderedDict{Symbol,Function}
    func_fit_str    ::String
    func_fit        ::Function
end
