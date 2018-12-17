# models with same formula for each cycle (Sfc models)

import DataStructures.OrderedDict;
import JuMP: Model, @variable, @constraint, @NLconstraint, @NLobjective,
    solve, getvalue, getobjectivevalue

mutable struct SFCModelDef # non-linear model, one feature (`x`)

# included in SFC_MODEL_BASE

    name::String
    linear::Bool

    _x_strs::AbstractVector
    X_strs::AbstractVector
    coef_strs::AbstractVector
    coef_cnstrnts::AbstractVector # assume all linear

    func_init_coefs::Function

    pred_strs::OrderedDict

# added by `add*!`` functions

    func_pred_strs::OrderedDict
    funcs_pred::OrderedDict

    func_fit_str::String
    func_fit::Function

end

# function empty_func() end
function empty_func(args...; kwargs...) end
# function empty_func(arg1::Any=0, args...; kwargs...) end


const MD_func_keys = ["f", "inv", "bl", "dr1", "dr2"] # when `num_fts > 1`, "d*" are partial derivatives in vector of length `num_fts`

# `EMPTY_fp` for `func_pred_strs` and `funcs_pred`
const EMPTY_fp = map(("", empty_func)) do empty_val
    # OrderedDict(map(MD_func_keys) do func_key # v0.4, `supertype` not defined, `typeof(some_function) == Function`
    OrderedDict{String,supertype(typeof(empty_val))}(map(MD_func_keys) do func_key # v0.5, `super` becomes `supertype`, `typeof(some_function) == #some_function AND supertype(typeof(some_function)) == Function`
        func_key => empty_val
    end) # do func_key
end # do empty_val

const MD_EMPTY_vals = (
    EMPTY_fp..., # :func_pred_strs, :funcs_pred
    "", # func_fit_str
    empty_func # func_fit
)


const SFC_MODEL_BASES = [ # vector of tuples

# generic

    (
    "lin_1ft",
    true,
    ["_x"],
    ["X"],
    ["c0", "c1"],
    [],
    function lin_1ft_func_init_coefs(args...; kwargs...)
        OrderedDict("c0"=>0, "c1"=>0)
    end,
    OrderedDict(
        "f" => "c0 + c1 * _x",
        "inv" => "(_x - c0) / c1",
        "bl" => "0",
        "dr1" => "c1",
        "dr2" => "0"
    )
    ),

    (
    "lin_2ft",
    true,
    ["_x1", "_x2"],
    ["X1", "X2"],
    ["c0", "c1", "c2"],
    [],
    function lin_2ft_func_init_coefs(args...; kwargs...)
        OrderedDict("c0"=>0, "c1"=>0, "c2"=>0)
    end,
    OrderedDict(
        "f" => "c0 + c1 * _x1 + c2 * _x2",
        "inv" => "0", # not applicable
        "bl" => "0",
        "dr1" => "[c1, c2]",
        "dr2" => "[0, 0]"
    )
    ),


# amplification curve

    (
    "b4",
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_"],
    [],
    function b4_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.001
        )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(X[idc_4be], Y_logit)
        b_ = lin1_coefs[2]
        e_ = -lin1_coefs[1] / b_
        return OrderedDict("b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_)
    end,
    OrderedDict(
        "f" => "c_ + (d_ - c_) / (1 + exp(b_ * (_x - e_)))",
        "inv" => "log((-d_ + _x) / (c_ - _x)) / b_ + e_",
        "bl" => "c_",
        "dr1" =>
            "(b_ * (c_ - d_) * exp(b_ * (e_ + _x)))/(exp(b_ * e_) + exp(b_ * _x))^2",
        "dr2" =>
            "(b_^2 * (c_ - d_) * exp(b_ * (e_ + _x)) * (exp(b_ * e_) - exp(b_ * _x)))/(exp(b_ * e_) + exp(b_ * _x))^3"
    )
    ),

    (
    "l4", # name
    false, # linear
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_"], # coef_strs
    ["e_ >= 1e-100"], # removing bound did not improve Cq accuracy
    function l4_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        return OrderedDict("b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_)
    end,
    OrderedDict( # pred_strs
        "f" => "c_ + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "((e_^b_ * (-d_ + _x))/(c_ - _x))^(1/b_)",
        "bl" => "c_",
        "dr1" => "(b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
        "dr2" =>
            "(b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
    )
    ),

    (
    "l4_hbl", # hyperbolic baseline: increase before log-phase then minimal at plateau (most simple version is -1/x). baseline model `c + bl_k / (e_ - x)` model caused "Ipopt finished with status Restoration_Failed"
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "bl_k", "bl_o"],
    ["e_ >= 1e-100"],
    function l4_hbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        bl_k = 0
        bl_o = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "bl_k"=>bl_k, "bl_o"=>bl_o
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + bl_k / (_x + bl_o) + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + bl_k / (_x + bl_o)",
        "dr1" =>
            "-bl_k / (_x + bl_o)^2 + (b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
        "dr2" =>
            "bl_k / (_x + bl_o)^3 + (b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
    )
    ),

    (
    "l4_lbl", # linear baseline
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "k1"],
    ["e_ >= 1e-100"],
    function l4_lbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        k1 = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "k1"=>k1
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + k1 * _x + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + k1 * _x",
        "dr1" =>
            "k1 + (b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
        "dr2" =>
            "(b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
    )
    ),

    (
    "l4_qbl", # quadratic baseline
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "k1", "k2"],
    ["e_ >= 1e-100"],
    function l4_qbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        k1 = 0
        k2 = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "k1"=>k1, "k2"=>k2
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + k1 * _x + k2 * _x^2 + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + k1 * _x + k2 * _x^2",
        "dr1" =>
            "k1 + 2 * k2 * _x + (b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
        "dr2" =>
            "2 * k2 + (b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
    )
    ),

    (
    "l4_enl", # name
    false, # linear
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_"], # coef_strs
    [], # coef_cnstrnts
    function l4_enl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = -lin1_coefs[1] / b_
        return OrderedDict("b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_)
    end,
    OrderedDict( # pred_strs
        "f" => "c_ + (d_ - c_) / (1 + exp(b_ * (log(_x) - e_)))",
        "inv" => "((exp(e_ * b_) * (-d_ + _x))/(c_ - _x))^(1/b_)",
        "bl" => "c_",
        "dr1" => "(b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
        "dr2" =>
            "(b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
    )
    ),

    (
    "l4_enl_hbl", # hyperbolic baseline: increase before log-phase then minimal at plateau (most simple version is -1/x). baseline model `c + bl_k / (e_ - x)` model caused "Ipopt finished with status Restoration_Failed"
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "bl_k", "bl_o"],
    [],
    function l4_enl_hbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        bl_k = 0
        bl_o = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "bl_k"=>bl_k, "bl_o"=>bl_o
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + bl_k / (_x + bl_o) + (d_ - c_) / (1 + exp(b_ * (log(_x) - e_)))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + bl_k / (_x + bl_o)",
        "dr1" =>
            "-bl_k / (_x + bl_o)^2 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
        "dr2" =>
            "bl_k / (_x + bl_o)^3 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
    )
    ),

    (
    "l4_enl_lbl", # linear baseline
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "k1"],
    [],
    function l4_enl_lbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        k1 = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "k1"=>k1
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + k1 * _x + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + k1 * _x",
        "dr1" =>
            "k1 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
        "dr2" =>
            "(b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
    )
    ),

    (
    "l4_enl_qbl", # quadratic baseline
    false,
    ["_x"],
    ["X"],
    ["b_", "c_", "d_", "e_", "k1", "k2"],
    [],
    function l4_enl_qbl_func_init_coefs(
        X::AbstractVector,
        Y::AbstractVector,
        epsilon::Real=0.01
    )
        Y_min, Y_min_idx = findmin(Y)
        c_ = Y_min - epsilon
        d_ = maximum(Y) + epsilon
        idc_4be = Y_min_idx:length(Y)
        Y_4be = Y[idc_4be]
        Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
        lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
        b_ = lin1_coefs[2]
        e_ = exp(-lin1_coefs[1] / b_)
        k1 = 0
        k2 = 0
        return OrderedDict(
            "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
            "k1"=>k1, "k2"=>k2
        )
    end,
    OrderedDict( # pred_strs
        "f" =>
            "c_ + k1 * _x + k2 * _x^2 + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
        "inv" => "0", # not calculated yet
        "bl" => "c_ + k1 * _x + k2 * _x^2",
        "dr1" =>
            "k1 + 2 * k2 * _x + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
        "dr2" =>
            "2 * k2 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
    )
    )
]


function add_funcs_pred!(
    md::SFCModelDef,
    verbose::Bool=false
    )

    _x_args_str = join(map(_x_str -> "$_x_str::Real", md._x_strs), ", ")
    coefs_str = join(map(str -> "$str::Real", md.coef_strs), ", ")

    for func_key in MD_func_keys
        func_name = "$(md.name)_$func_key"
        func_str = join([
            "function $func_name($_x_args_str, $coefs_str)", # In v0.4.5, `;` can't be parsed correctly for anonymous function lambda, because the signature will be parsed as a tuple not allowing `;`; default values are not allowed either. Heard it'll be fixed in v0.5
                md.pred_strs[func_key],
            "end",
            "function $func_name(X_cases::AbstractVector, $coefs_str)", # X_cases is a vector (indexed by cases) of vectors (indexed by features)
                "map(X_case -> $func_name(X_case..., $coefs_str), X_cases)",
            "end"
        ], "; ")
        md.func_pred_strs[func_key] = func_str
        func_expr = parse(func_str)
        md.funcs_pred[func_key] = @eval $func_expr
    end

    return nothing

end


function add_func_fit!( # vco = variable constraints objective
    md::SFCModelDef;
    Y_str::String="Y",
    obj_algrt::String="RSS",
    sense::String="Min", # "Min", "Max"
    )

    # X_strs
    X_strs = md.X_strs
    num_fts = length(X_strs)
    X_args_str = join(map(X_str -> "$X_str::AbstractVector", X_strs), ", ")

    # function signature
    sig_str = "function $(md.name)_func_fit(
        $X_args_str,
        $Y_str::AbstractVector,
        wts::AbstractVector=ones(length($Y_str));
        kwargs_Model...
    )"

    # initiate model
    mod_init_str = "jmp_model = Model(;kwargs_Model...)"

    # define coefficients as variables
    coef_init_str = "$X_args_str, $Y_str = map(abs_vec -> Array(abs_vec), ($X_args_str, $Y_str)); init_coefs = $(md.name)_func_init_coefs($X_args_str, $Y_str)" # `Array` because `linreg` doesn't work on `DataArray`
    var_str = join(
        map(md.coef_strs) do coef_str
            "@variable(
                jmp_model,
                $coef_str,
                start=init_coefs[\"$coef_str\"])"
        end,
        "; "
    )

    # add constraints for the coefficents
    cnstrnts_str = join(
        map(md.coef_cnstrnts) do coef_constrnt
            "@constraint(jmp_model, $coef_constrnt)"
        end,
        "; "
    )

    # set objective

    obj_macro_str = md.linear ? "@objective" : "@NLobjective" # `a1 = :(@some_macro); :($a1(arg1, arg2))` is equivalent to :((@some_macro()(arg1,arg2))), both of which raises "syntax: invalid macro use \"@($a1)\"". This why obj_macro need to be string, and other expressions are started as strings too for convenience.

    func_str_replaced = md.pred_strs["f"]
    for j in 1:num_fts
        func_str_replaced = replace(
            func_str_replaced,
            md._x_strs[j],
            "$(X_strs[j])[i]"
        )
    end

    residual_str = "($func_str_replaced - $Y_str[i])"
    iter_str = "for i in 1:length($(X_strs[1]))" # assuming X and Y have the same length

    if obj_algrt == "RSS"
        obj_expr_str = "sum(wts[i] * $residual_str^2 $iter_str)"
        # sumabs2(map(eval(x_symbol) -> eval(func_expr), X) .- Y)
    elseif obj_algrt == "l1_norm"
        obj_expr_str = "sum(abs($residual_str) $iter_str)" # `abs()` may cause "Ipopt finished with status Restoration_Faild"
    end

    obj_str = "$obj_macro_str(jmp_model, $sense, $obj_expr_str)"


    # return
    return_str = join([
        "status = solve(jmp_model)",
        "coef_strs = [\"$(join(md.coef_strs, "\", \""))\"]",
        "coefs = map(getvalue, [$(join(md.coef_strs, ", "))])",
        "obj_val = getobjectivevalue(jmp_model)",
        "return SfcFitted(coef_strs, coefs, status, obj_val, jmp_model, init_coefs); end"
    ], "; ")


    # add definition of func_fit

    func_str = join(
        [sig_str, mod_init_str, coef_init_str, var_str, cnstrnts_str, obj_str, return_str],
        "; "
    )
    md.func_fit_str = func_str

    func_expr = parse(func_str)
    md.func_fit = @eval $func_expr

    return nothing

end


# generate generic md objects
const MDs = OrderedDict(map(SFC_MODEL_BASES) do sfc_model_base
    sfc_model_base[1] => SFCModelDef(
        sfc_model_base...,
        deepcopy(MD_EMPTY_vals)...
    )
end) # do generic_sfc_model_base

for md_ in collect(values(MDs))
    add_funcs_pred!(md_)
    add_func_fit!(md_)
end


# choose model for amplification curve fitting
const AMP_MODEL_NAME = "l4_enl"
const AMP_MD = MDs[AMP_MODEL_NAME]




#
