#=============================================
    MAKERGAULx.jl

    different formula for each cycle (dfc)

=============================================#

## write functions to fit MAKERGAUL model here, which will be called in `mod_bl_q` in "amp.jl"

import JuMP: Model, @variable, @constraint, @NLconstraint, @NLobjective,
    solve, getvalue, getobjectivevalue


## bounds
const fb_B_MULTIPLE     = 1.9
const d0_LB             = 1e-14
const d0_UB             = Inf ## used: 0.1 (Bultmann 2013)
const eu0_inh_LB        = 0.0001
const eu0_UB_MULTIPLE   = 10
const inh_UB_MULTIPLE   = 10

## start values
const eu0_START             = 7e3  ## used: eu0_inh_LB, 0.01, 1, 50
const MAKERGAUL_d0_START    = 1    ## used: 0, 1e-14 (change_d3), 0.01, 1 (change_d2), 50 (change_d1)
const inh_START             = 4e-6 ## used: eu0_inh_LB (Infeasible for flat line), 0, 0.05, 1, (Invalid_Number_Detected for flat line), 10 (Infeasible for flat line), 50 `:Optimal` when `max_of_idx == 1`, "Invalid_Number_Detected" for the rest: eu0_START = 0.01, inh_START = 0; eu0_START = 50, inh_START = 0.05; eu0_START = 50, inh_START = 1; eu0_START = 50, inh_START = 50;


## function definitions

function pred_from_nm1(
    ::Union{Type{Val{MAKERGAUL3}}, Type{Val{MAKERGAUL4}}},
    eu_nm1      ::Real,
    d_nm1       ::Real,
    inh         ::Real
)
    eu_n = eu_nm1 / (1 + inh * d_nm1)
    d_n = d_nm1 + d_nm1 * eu_n / (eu_n + d_nm1)
    return [eu_n d_n]
end ## pred_from_nm1()


function pred_from_cycs( ## 0.7to1.2e-5 sec for 40 cycles on PC
    ::Type{Val{MAKERGAUL3}},
    cycs2fit    ::AbstractVector,
    fb          ::Real,
    eu0         ::Real,
    d0          ::Real,
    inh         ::Real
)
    max_cyc = maximum(cycs)
    pred_ary_eu_d_w0 = [eu0 d0]
    i = 1
    while i <= max_cyc
        pred_ary_eu_d_w0 = vcat(
            pred_ary_eu_d_w0,
            pred_from_nm1(MAKERGAUL3(), pred_ary_eu_d_w0[i,:]..., inh)
        )
        i += 1
    end
    fs_w0 = pred_ary_eu_d_w0[:, 2] + fb
    return fs_w0[2:end][map(Int, cycs)]
end ## pred_from_cycs(::Type{Val{MAKERGAUL3}})

function pred_from_cycs(
    ::Type{Val{MAKERGAUL4}},
    cycs        ::AbstractVector,
    fb          ::Real,
    bl_k        ::Real,
    eu0         ::Real,
    d0          ::Real,
    inh         ::Real
)
    max_cyc = maximum(cycs)
    pred_ary_eu_d_w0 = [eu0 d0]
    i = 1
    while i <= max_cyc
        pred_ary_eu_d_w0 = vcat(
            pred_ary_eu_d_w0,
            pred_from_nm1(MAKERGAUL4(), pred_ary_eu_d_w0[i,:]..., inh)
        )
        i += 1
    end
    return fb + bl_k * cycs .+ pred_ary_eu_d_w0[:, 2][2:end][map(Int, cycs)]
end ## pred_from_cycs(:MAKERGAUL4)

function fit(
    ::Type{Val{MAKERGAUL3}},
    cycs        ::AbstractVector, ## continous integers or not
    obs_fluos   ::AbstractVector,
    wts         ::AbstractVector =ones(length(obs_fluos));
    kwargs_Model... ## argument for `JuMP.Model`
)
    ## find maximum observed fluorescence
    max_of, max_of_idx = findmax(obs_fluos)
    idc2fit = 1:max_of_idx
    obs2fit = obs_fluos[idc2fit]
    cycs2fit = 1:cycs[max_of_idx]

    jmp_model = Model(;kwargs_Model...)

    min_of = minimum(obs_fluos)
    of_diff = max_of - min_of
    fb_b_abs = fb_B_MULTIPLE * of_diff

    @variable(jmp_model,
        # min_of - fb_b_abs <= fb <= min_of + fb_b_abs,
        fb,
        start=min_of)
    @variable(jmp_model, # eu0
        # eu0_inh_LB <= eu0 <= eu0_UB_MULTIPLE * of_diff,
        eu0 >= 0,
        start=eu0_START)
    # @variable(jmp_model, d0_LB <= d0 <= d0_UB, start=MAKERGAUL_d0_START) ## change_a1
    @variable(jmp_model, d0 >= 0, start=MAKERGAUL_d0_START) ## change_a2
    @variable(jmp_model, ## inh
        # eu0_inh_LB <= inh <= inh_UB_MULTIPLE * of_diff,
        inh >= 0,
        start=inh_START)
    @variable(jmp_model, f[cycs2fit])
    # @variable(jmp_model, eu[cycs2fit]) ## change_b1
    @variable(jmp_model, eu[cycs2fit] >= 0) ## change_b2
    # @variable(jmp_model, d[cycs2fit]) ## change_c1
    @variable(jmp_model, d[cycs2fit] >= 0) ## change_c2

    @constraint(jmp_model, f_constr[cyc in cycs2fit], f[cyc] == fb + d[cyc])
    # change_e1: with division
    @NLconstraint(jmp_model, eu_constr_01, eu[1] == eu0 / (1 + inh * d0))
    @NLconstraint(jmp_model, d_constr_01, d[1] == d0 + d0 * eu[1] / (eu[1] + d0))
    @NLconstraint(jmp_model, eu_constr_2p[cyc in cycs2fit[2:end]], eu[cyc] == eu[cyc-1] / (1 + inh * d[cyc-1]))
    # @NLconstraint(jmp_model, d_constr_2p[cyc in cycs2fit[2:end]], d[cyc] == d[cyc-1] + d[cyc-1] * eu[cyc] / (eu[cyc] + d[cyc-1])) # "Invalid_Number_Detected"
    @NLconstraint(jmp_model, d_constr_2p[cyc in cycs2fit[2:end]], d[cyc] == d[cyc-1] + 1 / (1 / d[cyc-1] + 1 / eu[cyc]))
    #
    ## change_e2: get rid of division by multiplying both sides by denominator
    # @NLconstraint(jmp_model, eu_constr_01, eu[1] * (1 + inh * d0) == eu0)
    # @NLconstraint(jmp_model, d_constr_01, d[1] * (eu[1] + d0) == d0 * (d0 + 2 * eu[1]))
    # @NLconstraint(jmp_model, eu_constr_2p[cyc in cycs2fit[2:end]], eu[cyc] * (1 + inh * d[cyc-1]) == eu[cyc-1])
    # # @NLconstraint(jmp_model, d_constr_2p[cyc in cycs2fit[2:end]], d[cyc] == d[cyc-1] + d[cyc-1] * eu[cyc] / (eu[cyc] + d[cyc-1])) # "Invalid_Number_Detected"
    # @NLconstraint(jmp_model, d_constr_2p[cyc in cycs2fit[2:end]], d[cyc] * (eu[cyc] + d[cyc-1]) == d[cyc-1] * (d[cyc-1] + 2 * eu[cyc]))

    ## ssre by mean of predicted
    # len_cycs = length(cycs)
    # @NLobjective(
    #     jmp_model, Min,
    #     sum( ((f[cycs[idx]] - obs_fluos[idx]) / (sum(f[cycs[idx]] / len_cycs for idx in idc2fit) - obs_fluos[idx])) ^ 2 for idx in idc2fit )
    # )
    ## ssre by mean of observed
    # mean_of = mean(obs2fit)
    # @NLobjective(
    #     jmp_model, Min,
    #     sum( ((f[cycs[idx]] - obs_fluos[idx]) / (mean_of - obs_fluos[idx])) ^ 2 for idx in idc2fit )
    # )
    ## sse # the only one with optimal so far
    @NLobjective(jmp_model, Min, sum((f[cycs[idx]] - obs_fluos[idx]) ^ 2 for idx in idc2fit)) ## can solve to optimal when ssre can't

    # @NLobjective(
    #     jmp_model, Min,
    #     @eval $(parse(get_mak2_rsq_str(obs_fluos[1:max_d2_idx]))) ## `OutOfMemoryError()`
    # )

    status = solve(jmp_model)
    coef_strs = ["fb", "eu0", "d0", "inh"]
    coefs = map(getvalue, [fb, eu0, d0, inh])
    obj_val = getobjectivevalue(jmp_model)

    return MAKERGAUL3Fit(
        max_of_idx,
        coef_strs,
        coefs,
        status,
        obj_val,
        jmp_model,
        # init_coefs
    )
end ## fit(::Type{Val{MAKERGAUL3}})

function fit(
    ::Type{Val{MAKERGAUL4}},
    cycs        ::AbstractVector, ## continous integers or not
    obs_fluos   ::AbstractVector,
    wts         ::AbstractVector=ones(length(obs_fluos));
    kwargs_Model... ## argument for `JuMP.Model`
)
    ## find maximum observed fluorescence
    max_of, max_of_idx = findmax(obs_fluos)
    idc2fit = 1:max_of_idx
    obs2fit = obs_fluos[idc2fit]
    cycs2fit = 1:cycs[max_of_idx]

    ## fit a linear model to the estimated baseline portion of the curve
    d2_vec = finite_diff(cycs, obs_fluos; nu=2)
    max_d2_idx = indmax(d2_vec)
    idc2fit_4bl = 1:(max(1, max_d2_idx - 1))
    fb_start, bl_k_start = linreg(cycs[idc2fit_4bl], obs_fluos[idc2fit_4bl])

    jmp_model = Model(;kwargs_Model...)

    min_of = minimum(obs_fluos)
    of_diff = max_of - min_of
    fb_b_abs = fb_B_MULTIPLE * of_diff

    @variable(jmp_model,
        # min_of - fb_b_abs <= fb <= min_of + fb_b_abs,
        fb,
        start=fb_start)
    @variable(jmp_model,
        bl_k,
        start=bl_k_start)
    @variable(jmp_model, ## eu0
        # eu0_inh_LB <= eu0 <= eu0_UB_MULTIPLE * of_diff,
        eu0 >= 0,
        start=eu0_START)
    # @variable(jmp_model, d0_LB <= d0 <= d0_UB, start=MAKERGAUL_d0_START) ## change_a1
    @variable(jmp_model, d0 >= 0, start=MAKERGAUL_d0_START) ## change_a2
    @variable(jmp_model, ## inh
        # eu0_inh_LB <= inh <= inh_UB_MULTIPLE * of_diff,
        inh >= 0,
        start=inh_START)
    @variable(jmp_model, f[cycs2fit])
    # @variable(jmp_model, eu[cycs2fit])    ## change_b1
    @variable(jmp_model, eu[cycs2fit] >= 0) ## change_b2
    # @variable(jmp_model, d[cycs2fit])     ## change_c1
    @variable(jmp_model, d[cycs2fit] >= 0)  ## change_c2

    @constraint(jmp_model,
        f_constr[cyc in cycs2fit],
        f[cyc] == fb + bl_k * cyc + d[cyc])
    ## change_e1: with division
    @NLconstraint(jmp_model, eu_constr_01, eu[1] == eu0 / (1 + inh * d0))
    @NLconstraint(jmp_model, d_constr_01, d[1] == d0 + d0 * eu[1] / (eu[1] + d0))
    @NLconstraint(jmp_model, eu_constr_2p[cyc in cycs2fit[2:end]], eu[cyc] == eu[cyc-1] / (1 + inh * d[cyc-1]))
    # @NLconstraint(jmp_model, d_constr_2p[cyc in cycs2fit[2:end]], d[cyc] == d[cyc-1] + d[cyc-1] * eu[cyc] / (eu[cyc] + d[cyc-1])) # "Invalid_Number_Detected"
    @NLconstraint(jmp_model, d_constr_2p[cyc in cycs2fit[2:end]], d[cyc] == d[cyc-1] + 1 / (1 / d[cyc-1] + 1 / eu[cyc]))
    #
    ## change_e2: get rid of division by multiplying both sides by denominator
    # @NLconstraint(jmp_model, eu_constr_01, eu[1] * (1 + inh * d0) == eu0)
    # @NLconstraint(jmp_model, d_constr_01, d[1] * (eu[1] + d0) == d0 * (d0 + 2 * eu[1]))
    # @NLconstraint(jmp_model, eu_constr_2p[cyc in cycs2fit[2:end]], eu[cyc] * (1 + inh * d[cyc-1]) == eu[cyc-1])
    # # @NLconstraint(jmp_model, d_constr_2p[cyc in cycs2fit[2:end]], d[cyc] == d[cyc-1] + d[cyc-1] * eu[cyc] / (eu[cyc] + d[cyc-1])) # "Invalid_Number_Detected"
    # @NLconstraint(jmp_model, d_constr_2p[cyc in cycs2fit[2:end]], d[cyc] * (eu[cyc] + d[cyc-1]) == d[cyc-1] * (d[cyc-1] + 2 * eu[cyc]))

    ## ssre by mean of predicted
    # len_cycs = length(cycs)
    # @NLobjective(
    #     jmp_model, Min,
    #     sum( ((f[cycs[idx]] - obs_fluos[idx]) / (sum(f[cycs[idx]] / len_cycs for idx in idc2fit) - obs_fluos[idx])) ^ 2 for idx in idc2fit )
    # )
    ## ssre by mean of observed
    # mean_of = mean(obs2fit)
    # @NLobjective(
    #     jmp_model, Min,
    #     sum( ((f[cycs[idx]] - obs_fluos[idx]) / (mean_of - obs_fluos[idx])) ^ 2 for idx in idc2fit )
    # )
    ## sse ## the only one with optimal so far
    @NLobjective(jmp_model, Min, sum((f[cycs[idx]] - obs_fluos[idx]) ^ 2 for idx in idc2fit)) ## can solve to optimal when ssre can't

    # @NLobjective(
    #     jmp_model, Min,
    #     @eval $(parse(get_mak2_rsq_str(obs_fluos[1:max_d2_idx]))) ## `OutOfMemoryError()`
    # )

    status = solve(jmp_model)
    coef_strs = ["fb", "bl_k", "eu0", "d0", "inh"]
    coefs = map(getvalue, [fb, bl_k, eu0, d0, inh])
    obj_val = getobjectivevalue(jmp_model)

    return MAKERGAUL4Fit(
        max_of_idx,
        fb_start,
        bl_k_start,
        coef_strs,
        coefs,
        status,
        obj_val,
        jmp_model,
        # init_coefs
    )
end ## fit(::Type{Val{MAKERGAUL4}})
