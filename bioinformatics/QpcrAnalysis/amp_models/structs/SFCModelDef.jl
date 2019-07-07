## SFCModelDef.jl
##
## Author: Tom Price
## Date:   June 2019

import DataStructures.OrderedDict


@enum SFCModelName lin_1ft lin_2ft b4 l4 l4_hbl l4_lbl l4_qbl l4_enl l4_enl_hbl l4_enl_lbl l4_enl_qbl

@enum CqMethod cp_dr1 cp_dr2 Cy0 ct max_eff
CqMethod(m ::String) = CqMethod(findfirst(map(string, instances(CqMethod)), m) - 1)


mutable struct SFCModelDef ## non-linear model, one feature (`x`)
    ## included in SFC_MODEL_BASE
    name            ::SFCModelName
    linear          ::Bool
    _x_strs         ::AbstractVector
    X_strs          ::AbstractVector
    coef_strs       ::AbstractVector
    coef_cnstrnts   ::AbstractVector ## assume all linear
    func_init_coefs ::Function
    pred_strs       ::OrderedDict
    ## added by `add*!`` functions
    func_pred_strs  ::OrderedDict
    funcs_pred      ::OrderedDict
    func_fit_str    ::String
    func_fit        ::Function
end
