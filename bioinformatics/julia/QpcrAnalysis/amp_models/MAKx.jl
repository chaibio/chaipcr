
# different formula for each cycle (dfc)

# write functions to fit MAKx (MAK2 and MAK3) model here, which will be called in `mod_bl_q` in "amp.jl"


const MAK_d0_START = 0 # 0 good, 1 bad
const k_START = 10 # used: 10 better, 2 good, 1e-10 bad, 1 bad


function pred_from_d_nm1(::Union{MAK2, MAK3}, d_nm1::Real, k::Real)
    d_nm1 + k * log(1+ d_nm1 / k)
end


function pred_from_cycs( # 0.7to1.2e-5 sec for 40 cycles on PC
    ::MAK2,
    cycs::AbstractVector,
    fb::Real, d0::Real, k::Real
    )
    max_cyc = maximum(cycs)
    pred_ds = [AbstractFloat(d0)]
    i = 1
    while i <= max_cyc
        push!(pred_ds, pred_from_d_nm1(MAK2(), pred_ds[i], k))
        i += 1
    end
    return fb + pred_ds[2:end][map(Int, cycs)]
end

function pred_from_cycs( #  sec for 40 cycles on PC
    ::MAK3,
    cycs::AbstractVector,
    fb::Real, bl_k::Real, d0::Real, k::Real
    )
    max_cyc = maximum(cycs)
    pred_ds = [AbstractFloat(d0)]
    i = 1
    while i <= max_cyc
        push!(pred_ds, pred_from_d_nm1(MAK2(), pred_ds[i], k))
        i += 1
    end
    return fb + bl_k * cycs .+ pred_ds[2:end][map(Int, cycs)]
end


function fit(
    ::MAK2,
    cycs::AbstractVector, # continous integers or not
    obs_fluos::AbstractVector,
    wts::AbstractVector=ones(length(obs_fluos));
    kwargs_Model... # argument for `JuMP.Model`
    )

    # find approximate `max_d` by `finite_diff` from "shared.jl"
    d_vec = finite_diff(cycs, obs_fluos; nu=1) # should use `nu=2` per Boggy 2010 paper (because MAK2 is no longer valid at max_d1), but use `nu=1` to increase the number of data points used for fit and seems to provide better fitting results
    max_d, max_d_idx = findmax(d_vec)
    idc2fit = 1:max_d_idx
    obs2fit = obs_fluos[idc2fit]
    cycs2fit = 1:cycs[max_d_idx]

    jmp_model = Model(;kwargs_Model...)

    @variable(jmp_model, fb, start=minimum(obs2fit))
    @variable(jmp_model, d0 >= 0, start=MAK_d0_START)
    @variable(jmp_model, k >= 1e-10, start=k_START)
    # @variable(jmp_model, bl_k, start=0)
    @variable(jmp_model, f[cycs2fit])
    @variable(jmp_model, d[cycs2fit]) # change_a1
    # @variable(jmp_model, d[cycs2fit] >= 0) # change_a2 # didn't work as well as "change_a1", see "20170312_0302_ip137_exp187_ch1_mak2_ylims_obs_*.png"

    @constraint(jmp_model, f_constr[cyc in cycs2fit], f[cyc] == fb + d[cyc])
    @NLconstraint(jmp_model, d_constr_01, d[1] == d0 + k * log(1 + d0 / k))
    @NLconstraint(
        jmp_model,
        d_constr_2p[cyc in cycs2fit[2:end]],
        d[cyc] == d[cyc-1] + k * log(1 + d[cyc-1] / k)
    )

    @NLobjective(
        jmp_model, Min,
        sum((f[cycs[idx]] - obs_fluos[idx]) ^ 2 for idx in idc2fit)
    )

    # @NLobjective(
    #     jmp_model, Min,
    #     @eval $(parse(get_mak2_rsq_str(obs_fluos[1:max_d_idx]))) # `OutOfMemoryError()`
    # )

    status = solve(jmp_model)
    coef_strs = ["fb", "d0", "k"]
    coefs = map(getvalue, [fb, d0, k])
    obj_val = getobjectivevalue(jmp_model)

    return MAK2Fitted(
        max_d_idx,
        coef_strs,
        coefs,
        status,
        obj_val,
        jmp_model,
        # init_coefs
    )

end


function fit(
    ::MAK3,
    cycs::AbstractVector, # continous integers or not
    obs_fluos::AbstractVector,
    wts::AbstractVector=ones(length(obs_fluos));
    kwargs_Model... # argument for `JuMP.Model`
    )

    # find approximate `max_d` by `finite_diff` from "shared.jl"
    d_vec = finite_diff(cycs, obs_fluos; nu=1) # should use `nu=2` per Boggy 2010 paper (because MAK2 is no longer valid at max_d1), but use `nu=1` to increase the number of data points used for fit and seems to provide better fitting results
    max_d, max_d_idx = findmax(d_vec)
    idc2fit = 1:max_d_idx
    cycs2fit = 1:cycs[max_d_idx]

    # fit a linear model to the estimated baseline portion of the curve
    d2_vec = finite_diff(cycs, obs_fluos; nu=2)
    max_d2, max_d2_idx = findmax(d2_vec)
    idc2fit_4bl = 1:(max(1, max_d2_idx - 1))
    fb_start, bl_k_start = linreg(cycs[idc2fit_4bl], obs_fluos[idc2fit_4bl])

    jmp_model = Model(;kwargs_Model...)

    @variable(jmp_model, fb, start=fb_start)
    @variable(jmp_model, bl_k, start=bl_k_start)
    @variable(jmp_model, d0 >= 0, start=MAK_d0_START)
    @variable(jmp_model, k >= 1e-10, start=k_START)
    # @variable(jmp_model, bl_k, start=0)
    @variable(jmp_model, f[cycs2fit])
    @variable(jmp_model, d[cycs2fit])

    @constraint(jmp_model,
        f_constr[cyc in cycs2fit],
        f[cyc] == fb + bl_k * cyc + d[cyc]
    )
    @NLconstraint(jmp_model, d_constr_01, d[1] == d0 + k * log(1 + d0 / k))
    @NLconstraint(
        jmp_model,
        d_constr_2p[cyc in cycs2fit[2:end]],
        d[cyc] == d[cyc-1] + k * log(1 + d[cyc-1] / k)
    )

    @NLobjective(
        jmp_model, Min,
        sum((f[cycs[idx]] - obs_fluos[idx]) ^ 2 for idx in idc2fit)
    )

    # @NLobjective(
    #     jmp_model, Min,
    #     @eval $(parse(get_mak2_rsq_str(obs_fluos[1:max_d_idx]))) # `OutOfMemoryError()`
    # )

    status = solve(jmp_model)
    coef_strs = ["fb", "bl_k", "d0", "k"]
    coefs = map(getvalue, [fb, bl_k, d0, k])
    obj_val = getobjectivevalue(jmp_model)

    return MAK3Fitted(
        max_d_idx,
        fb_start,
        bl_k_start,
        coef_strs,
        coefs,
        status,
        obj_val,
        jmp_model,
        # init_coefs
    )


end




# # need `@eval`, not used
#
#
# const d_nm1_STR = "d_nm1"
# const k_STR = "k"
# const d0_STR = "d0"
# const fb_STR = "fb"
#
#
# # associated with "get_mak2_pff"
# function get_mak2_psf(
#     num_cycs::Integer;
#     d_nm1_str::String=d_nm1_STR,
#     k_str::String=k_STR,
#     d0_str::String=d0_STR
#     )
#     pred_str_d_nm1_n = "($d_nm1_str + $k_str * log(1 + $d_nm1_str / $k_str))"
#     pred_strs_d_w0 = [d0_str]
#     wo0_range = 2:num_cycs+1
#     for cyc_n in wo0_range
#         push!(
#             pred_strs_d_w0,
#             replace(pred_str_d_nm1_n, d_nm1_str, pred_strs_d_w0[cyc_n - 1])
#         )
#     end # for
#     pred_strs_fluo = map(pred_strs_d_w0[wo0_range]) do pred_str_d
#         "fb + $pred_str_d"
#     end
#     return pred_strs_fluo
# end # get_mak2_psf
#
#
# # `OutOfMemoryError()` upon macro expansion
# function get_mak2_pff( # return an array whose each element is a prediction function for each cycle.
#     num_cycs::Integer;
#     d_nm1_str::String=d_nm1_STR,
#     k_str::String=k_STR,
#     d0_str::String=d0_STR,
#     fb_str::String=fb_STR
#     )
#     pred_strs_fluo = get_mak2_psf(num_cycs;
#         d_nm1_str=d_nm1_str,
#         k_str=k_str,
#         d0_str=d0_str
#     )
#     return map(1:num_cycs) do cyc_n
#         func_expr = parse("function pred_$cyc_n($fb_str::Real, $d0_str::Real, $k_str::Real) return $(pred_strs_fluo[cyc_n]) end")
#         @eval $func_expr # `OutOfMemoryError()`
#     end # do pred_str_fluo
# end
#
#
# # for `@NLobjective(jmp_model, Min, @eval ...)` from `fit_mak2`
# function get_mak2_rsq_str(
#     obs_fluos::AbstractVector;
#     kwdict_gmp::Associative=OrderedDict(), # keyword arguments passed onto `get_mak2_psf`
#     )
#     num_cycs = length(obs_fluos)
#     pred_strs_fluo = get_mak2_psf(num_cycs; kwdict_gmp...)
#     rsq_str = join(map(1:num_cycs) do cyc_n
#         "($(pred_strs_fluo[cyc_n]) - $(obs_fluos[cyc_n])) ^ 2"
#     end, " + ") # do cyc_n
#     return rsq_str
# end # get_mak2_rsq_str




# # for later use
# pred_funcs = get_mak2_pff(num_cycs)
# preds = map(func -> func(fb, d0, k), funcs)
#




#
