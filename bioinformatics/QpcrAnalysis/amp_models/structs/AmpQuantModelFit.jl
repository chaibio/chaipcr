## AmpQuantOutput.jl
##
## output from fit_quant_model()
##
## Author: Tom Price
## Date:   July 2019

import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver


abstract type AmpQuantOutput                            end
abstract type AmpQuantLongOutput    <: AmpQuantOutput   end
abstract type AmpQuantShortOutput   <: AmpQuantOutput   end
abstract type AmpQuantCqOnlyOutput  <: AmpQuantOutput   end

struct AmpSFCQuantLongOutput <: AmpQuantLongOutput
    quant_fit       ::AmpModelFit
    quant_status    ::Symbol
    coefs           ::Vector{Float_T}
    d0              ::Float_T
    quant_fluos     ::Array{Float_T,3}
    dr1_pred        ::Array{Float_T,3}
    dr2_pred        ::Array{Float_T,3}
    max_dr1         ::Array{Float_T,2}
    max_dr2         ::Array{Float_T,2}
    cyc_vals_4cq    ::Array{OrderedDict{Symbol,Float_T},2}
    eff_vals_4cq    ::Array{OrderedDict{Symbol,Float_T},2}
    cq_raw          ::Array{Float_T,2}
    cq              ::Array{Float_T,2}
    eff             ::Array{Float_T,2}
    cq_fluo         ::Array{Float_T,2}
end

struct AmpDFCQuantLongOutput <: AmpQuantLongOutput
    quant_fit       ::AmpModelFit
    quant_status    ::Symbol
    coefs           ::Vector{Float_T}
    d0              ::Float_T
    quant_fluos     ::Vector{Float_T}
end

struct AmpSFCQuantShortOutput <: AmpQuantShortOutput
    cq              ::Array{Float_T,2} ## cq values, applicable to sigmoid models but not to MAK models
end

struct AmpDFCQuantShortOutput <: AmpQuantShortOutput
    d0              ::Float_T
end

struct AmpCqOnlyQuantOutput <: AmpQuantCqOnlyOutput
    cq_fluo         ::Array{Float_T,2}
end


## constants >>

## defaults for quantification model
const DEFAULT_AMP_QUANT_METHOD          = l4_enl
const DEFAULT_AMP_DENSER_FACTOR         = 3
const DEFAULT_AMP_CQ_METHOD             = Cy0
const DEFAULT_AMP_CT_FLUO               = NaN
const DEFAULT_AMP_CQ_ONLY               = false

## a value that cannot be obtained by normal calculation of Ct
const AMP_CT_VAL_DOMAINERROR = -99 


## methods >>

## DFC
function fit_quant_model(
    ::Type{Val{M}},
    bl                  ::AmpBaselineModelFit,
    solver              ::IpoptSolver;
) where M <: DFCModel
    debug(logger, "at fit_quant_model(Val{M}) where M <: DFCModel")
    ## baseline model = quantification model
    const quant_fit = bl.bl_fit
    const coefs = bl.coefs
    const d0 = coefs[find(isequal(:d0), quant_fit.coef_syms)[1]]
    AmpDFCQuantModelFit(
        quant_fit,
        quant_fit.status, ## quant_status
        coefs,
        d0,
        pred_from_cycs(Val{M}, cycs, coefs...)) ## blsub_fitted
end ## fit_quant_model(Val{M}) where M <: DFCModel


## SFC
function fit_quant_model(
    ::Type{Val{SFCModel}},
    bl                  ::AmpBaselineModelFit,
    solver              ::IpoptSolver;
    SFC_model_defs      ::OrderedDict{Symbol, SFCModelDef} = SFC_MDs,
    quant_method        ::Symbol = DEFAULT_AMP_QUANT_METHOD,
    cq_method           ::Symbol = DEFAULT_AMP_CQ_METHOD,
    ct_fluo             ::AbstractFloat = DEFAULT_AMP_CT_FLUO,
    denser_factor       ::Int = DEFAULT_AMP_DENSER_FACTOR,
    cq_only             ::Bool = DEFAULT_AMP_CQ_ONLY,
)
    function calc_cq_only()
        (cq_method == cp_dr1) && return begin
                const dr1_pred = funcs_pred[:dr1](cycs_denser, quant_coefs...)
                const idx_max_dr1= findmax(dr1_pred)[2]
                cycs_denser[idx_max_dr1]
            end
        (cq_method == cp_dr2) && return begin
                const dr2_pred = funcs_pred[:dr2](cycs_denser, quant_coefs...)
                const idx_max_dr2 = findmax(dr2_pred)[2]
                cycs_denser[idx_max_dr2]
            end
        (cq_method == Cy0) && return begin
                const dr1_pred = funcs_pred[:dr1](cycs_denser, quant_coefs...)
                const (max_dr1, idx_max_dr1) = findmax(dr1_pred)
                const cyc_max_dr1 = cycs_denser[idx_max_dr1]
                cyc_max_dr1 - funcs_pred[:f](cyc_max_dr1, quant_coefs...) / max_dr1
            end
        (cq_method == ct) && return try
                funcs_pred[:inv](ct_fluo, quant_coefs...)
            catch err
                isa(err, DomainError) ?
                    AMP_CT_VAL_DOMAINERROR :
                    rethrow()
            end ## try
        (cq_method == max_eff) && return begin
                const eff_pred = map(func_pred_eff, cycs_denser)
                const idx_max_eff = findmax(eff_pred)[2]
                cycs_denser[idx_max_eff]
            end
        ## fallthrough
        throw(ArgumentError("`cq_method` $cq_method not implemented"))
    end

    ## function needed because `Cy0` may not be in `cycs_denser`
    function func_pred_eff(cyc)
        try
            -(map([0.5, -0.5]) do epsilon
                log2(func_pred_f(cyc + epsilon, quant_coefs...))
            end...)
        catch err
            isa(err, DomainError) ?
                NaN :
                rethrow()
        end ## try
    end ## func_pred_eff()

    ## << end of function definitions nested within fit_quant_model() - SFC

    debug(logger, "at fit_quant_model(Val{SFCModel})")
    const num_cycs = length(fluos)
    const cycs = range(1.0, num_cycs)
    const len_denser = denser_factor * (num_cycs - 1) + 1
    const cycs_denser = Array(range(1.0, 1.0/denser_factor, len_denser))
    const qm = SFC_model_defs[quant_method]    
    const quant_coefs = quant_fit.coefs
    const funcs_pred = qm.funcs_pred
    cq_only && return calc_cq_only()
    ## else
    const quant_fit = qm.func_fit(cycs, bl.blsub_fluos, wts; solver = solver)
    const dr1_pred = funcs_pred[:dr1](cycs_denser, quant_coefs...)
    const (max_dr1, idx_max_dr1) = findmax(dr1_pred)
    const cyc_max_dr1 = cycs_denser[idx_max_dr1]
    const dr2_pred = funcs_pred[:dr2](cycs_denser, quant_coefs...)
    const (max_dr2, idx_max_dr2) = findmax(dr2_pred)
    const cyc_max_dr2 = cycs_denser[idx_max_dr2]
    const Cy0 = cyc_max_dr1 - funcs_pred[:f](cyc_max_dr1, quant_coefs...) / max_dr1
    const ct = try
        funcs_pred[:inv](ct_fluo, quant_coefs...)
    catch err
        isa(err, DomainError) ?
            AMP_CT_VAL_DOMAINERROR :
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
    const raw_cycs_index = colon(1, denser_factor, len_denser)
    return AmpSFCQuantModelFit(
        quant_fit,
        quant_status,
        quant_coefs,
        NaN, ## d0
        funcs_pred[:f](cycs, quant_coefs...), ## blsub_fitted
        dr1_pred[raw_cycs_index],
        dr2_pred[raw_cycs_index],
        max_dr1,
        max_dr2,
        cyc_vals_4cq,
        eff_vals_4cq,
        cq_raw,
        copy(cyc_vals_4cq[cq_method]), ## cq
        copy(eff_vals_4cq[cq_method]), ## eff
        funcs_pred[:f](cq_raw <= 0 ? NaN : cq_raw, quant_coefs...)) ## cq_fluo
end ## fit_quant_model(Val{SFCModel})
