# models with same formula for each cycle (Sfc models)

import DataStructures.OrderedDict;
import JuMP: Model, @variable, @constraint, @NLconstraint, @NLobjective,
    solve, getvalue, getobjectivevalue



function add_funcs_pred!(
    md          ::SFCModelDef,
    verbose     ::Bool=false
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
        func_expr = Base.parse(func_str) # not JSON.parse
        md.funcs_pred[func_key] = @eval $func_expr
    end

    return nothing

end


function add_func_fit!( # vco = variable constraints objective
    md          ::SFCModelDef;
    Y_str       ::String = "Y",
    obj_algrt   ::Symbol = :RSS,
    sense       ::Symbol = :Min, # :Min, :Max
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

    func_str_replaced = md.pred_strs[:f]
    for j in 1:num_fts
        func_str_replaced = replace(
            func_str_replaced,
            md._x_strs[j],
            "$(X_strs[j])[i]"
        )
    end

    residual_str = "($func_str_replaced - $Y_str[i])"
    iter_str = "for i in 1:length($(X_strs[1]))" # assuming X and Y have the same length

    if obj_algrt == :RSS
        obj_expr_str = "sum(wts[i] * $residual_str^2 $iter_str)"
        # sumabs2(map(eval(x_symbol) -> eval(func_expr), X) .- Y)
    elseif obj_algrt == :l1_norm
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

    func_expr = Base.parse(func_str) # not JSON.parse
    md.func_fit = @eval $func_expr

    return nothing

end



# generate generic md objects
for md_ in collect(values(MDs))
    add_funcs_pred!(md_)
    add_func_fit!(md_)
end




#
