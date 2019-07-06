## fit_quant.jl
##
## Author: Tom Price
## Date:   July 2019

## DFC
function fit_quant(
	::Type{Val{M}} where M <: DFCModel,
    fluos               ::AbstractVector,
    kwargs_jmp_model    ::Associative;
    baseline_model_fit  ::AmpBaselineModelFitOutput
) 
    ## baseline model = quantification model
    const fitted_postbl = baseline_model_fit.fitted_prebl
    const coefs_pob = fitted_postbl.coefs
    const d0_i_vec = find(isequal(:d0), fitted_postbl.coef_syms)
        fitted_postbl,
        fitted_postbl.status,
        coefs_pob, ## coefs
        coefs_pob[d0_i_vec[1]], ## d0
        pred_from_cycs(Val{amp_model}, cycs, coefs_pob...)) ## blsub_fitted


## used in calc_ct_fluos()
function find_idc_useful(postbl_stata ::AbstractVector)
    idc_useful = find(postbl_stata .== :Optimal)
    (length(idc_useful) > 0) && return idc_useful
    idc_useful = find(postbl_stata .== :UserLimit)
    (length(idc_useful) > 0) && return idc_useful
    return 1:length(postbl_stata)
end ## find_idc_useful()

            m_postbl,
            denser_factor,
    m_postbl            ::Symbol = DEFAULT_AMP_MODEL_NAME,



## function needed because `Cy0` may not be in `cycs_denser`
function func_pred_eff(cyc)
    try
        -(map([0.5, -0.5]) do epsilon
            log2(func_pred_f(cyc + epsilon, coefs_pob...))
        end...)
    catch err
        isa(err, DomainError) ?
            NaN :
            throw(ErrorException("unhandled error in func_pred_eff()"))
    end ## try
end


## quantification for SFC models
function quantify(
    fit                 ::AmpModelFitOutput,
    amp_model           ::AmpModel, ## SFC, MAKx, MAKERGAULx
    ## parameters that apply only when fitting SFC models
    SFC_model           ::SFCModelDef = DEFAULT_AMP_MODEL_DEF,
    denser_factor       ::Int,
    cq_method           ::Symbol,
    ct_fluo             ::AbstractFloat,
    cq_fluo_only        ::Bool
)
    const num_cycs = length(fluos)
    const cycs = range(1.0, num_cycs)
    const len_denser = denser_factor * (num_cycs - 1) + 1
    const cycs_denser = Array(range(1, 1/denser_factor, len_denser))
    const raw_cycs_index = colon(1, denser_factor, len_denser)
    const funcs_pred = SFC_model.funcs_pred
    const funcs_pred_f = funcs_pred[:f]
    #
    const fitted_postbl = SFC_model.func_fit(
        cycs, blsub_fluos, wts; kwargs_jmp_model...)
    const dr1_pred = fit.funcs_pred[:dr1](cycs_denser, fit.coefs...)
    const (max_dr1, idx_max_dr1) = findmax(dr1_pred)
    const cyc_max_dr1 = cycs_denser[idx_max_dr1]
    const dr2_pred = fit.funcs_pred[:dr2](cycs_denser, fit.coefs...)
    const (max_dr2, idx_max_dr2) = findmax(dr2_pred)
    const cyc_max_dr2 = cycs_denser[idx_max_dr2]
    const Cy0 = cyc_max_dr1 - fit.funcs_pred[:f](cyc_max_dr1, fit.coefs...) / max_dr1
    const ct = try
        fit.funcs_pred[:inv](ct_fluo, fit.coefs...)
    catch err
        isa(err, DomainError) ?
            CT_VAL_DOMAINERROR :
            rethrow()
    end ## try
    const eff_pred = map(func_pred_eff, cycs_denser)
    const (eff_max, idx_max_eff) = findmax(eff_pred)
    const cyc_vals_4cq = OrderedDict(
        :cp_dr1  => cyc_max_dr1,
        :cp_dr2  => cyc_max_dr2,
        :Cy0     => Cy0,
        :ct      => ct,
        :max_eff => cycs_denser[idx_max_eff])
    const cq_raw = cyc_vals_4cq[cq_method]
    const eff_vals_4cq =
        OrderedDict(
            map(keys(cyc_vals_4cq)) do key
                key => (key == :max_eff) ?
                    eff_max :
                    func_pred_eff(cyc_vals_4cq[key])
            end)
    return AmpQuantOutput(
        fitted_postbl,
        fitted_postbl.status, ## postbl_status
        fitted_postbl.coefs, ## coefs
        NaN) ## d0
        funcs_pred[:f](cycs, coefs_pob...), ## blsub_fitted
        dr1_pred[raw_cycs_index],
        dr2_pred[raw_cycs_index],
        max_dr1,
        max_dr2,
        cyc_vals_4cq,
        eff_vals_4cq,
        cq_raw,
        copy(cyc_vals_4cq[cq_method]), ## cq
        copy(eff_vals_4cq[cq_method]), ## eff
        funcs_pred[:f](cq_raw <= 0 ? NaN : cq_raw, coefs_pob...)) ## cq_fluo
end ## quantify()
