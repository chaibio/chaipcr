#===============================================================================

    amp_analysis.jl

    amplification analysis

    issue:
    the code assumes only 1 step/ramp because the current data format
    does not allow us to break the fluorescence data down by step_id/ramp_id

===============================================================================#

import DataStructures.OrderedDict
import StaticArrays: SVector, SMatrix
import Memento: debug, warn
using Ipopt


#===============================================================================
    function definitions >>
===============================================================================#

"Analyse amplification data via calls to `calibrate` and `get_fit_results`."
function amp_analysis(i ::AmpInput) # ; asrp ::AmpStepRampProperties)
    debug(logger, "at amp_analysis()")
    #
    ## deconvolute and normalize
    calibration_results =
        calibrate(i, i.calibration_data, i.calibration_args, i.raw, array)
    #
    ## initialize output
    o = AmpOutput(
        Val{i.amp_output},
        i,
        calibration_results...,
        # cq_method,
        default_ct_fluos(i))
    #
    ## fit amplification models and report results
    if i.num_cycles <= 2
		num_cycles = i.num_cycles
        warn(logger, "number of cycles $num_cycles <= 2: baseline subtraction " *
            "and Cq calculation will not be performed")
    else ## num_cycles > 2
        baseline_cyc_bounds = check_bl_cyc_bounds(i, DEFAULT_AMP_BL_CYC_BOUNDS)
        try
            set_ct_fluos!(o, i, baseline_cyc_bounds)
        catch e
            warn(logger, "set_ct_fluos catch error: " * sprint(showerror, e))
        end
        try
            set_output_fields!(o, i, get_fit_results(o, i, baseline_cyc_bounds))
        catch e
            warn(logger, "get_fit_results catch error: " * sprint(showerror, e))
        end
        set_qt_fluos!(o, i)
        set_report_cq!(o, i)
    end ## if
    #
    ## allelic discrimination
    # if dcv
    #     o.assignments_adj_labels_dict, o.agr_dict =
    #         process_ad(i, o)
    # end # if dcv
    #
    # serialize('/home/ali/ali/cq/output',o=o)
    # file_=open("/home/ali/ali/cq/output", "w")
    # serialize(file_, o)
    # close(file_)
    return o
end ## amp_analysis()


#==============================================================================#


"Set the amplification output field `ct_fluos`."
function set_ct_fluos!(
    o                       ::AmpOutput,
    i                       ::AmpInput,
    baseline_cyc_bounds     ::AbstractArray,
)
    debug(logger, "at calc_ct_fluos()")
    (length(o.ct_fluos) > 0) && return nothing
    o.ct_fluos = default_ct_fluos(i)
    (i.cq_method != :ct)     && return nothing
    (i.amp_model != :SFC)    && return nothing
    ## else
    o.ct_fluos =
        map(1:i.num_channels) do channel_i
            fits =
                map(1:i.num_wells) do well_i
                    fluos = o.rbbs_ary3[:, well_i, channel_i]
                    amp_fit_model(
                        Val{SFCModel},
                        AmpCqFluoModelResults,
                        i,
                        fluos,
                        bl_cyc_bounds[well_i, channel_i],
                        DEFAULT_AMP_CT_FLUO_METHOD, ## cq_method
                        NaN_T) ## i.ct_fluo
                end ## do well_i
            fits |>
                their(:quant_status) |>
                find_idc_useful |>
                curry(getindex)(fits) |>
                their(:cq_fluo) |>
                median
        end ## do channel_i
    return nothing ## side effects only
end ## calc_ct_fluos()

## called by calc_ct_fluos() >>

@inline function find_idc_useful(postbl_stata ::AbstractVector)
    idc_useful = find(postbl_stata .== :Optimal)
    (length(idc_useful) > 0) && return idc_useful
    idc_useful = find(postbl_stata .== :UserLimit)
    (length(idc_useful) > 0) && return idc_useful
    return eachindex(postbl_stata)
end ## find_idc_useful()

default_ct_fluos(i ::AmpInput) =
    SVector{i.num_channels, Float_T}(fill(NaN_T, i.num_channels))


#==============================================================================#


"Fit amplification model to data for each well and channel."
function get_fit_results(
    o                       ::AmpOutput,
    i                       ::AmpInput,
    bl_cyc_bounds           ::AbstractArray,
)
    function do_model_fit(wi ::Int_T, ci ::Int_T)
        debug(logger, "at do_model_fit($wi, $ci)")
        if isa(solver, Ipopt.IpoptSolver) && length(prefix) > 0
            ipopt_file = string(join([prefix, ci, wi], '_')) * ".txt"
            push!(solver.options, (:output_file, ipopt_file))
        end
        fluos = o.rbbs_ary3[:, wi, ci]
        amp_fit_model(
            Val{i.amp_model},
            i.amp_model_results,
            i,
            fluos,
            bl_cyc_bounds[wi, ci],
            i.cq_method,
            o.ct_fluos[ci])
    end ## fit model()

    ## << end of function definition nested within set_fit_results!()

    debug(logger, "at set_fit_results!()")
    solver = i.solver
    prefix = i.ipopt_print_prefix
    fit_results =
        SMatrix{i.num_wells, i.num_channels, i.amp_model_results}([
            do_model_fit(wi, ci)
            for wi in 1:i.num_wells, ci in 1:i.num_channels])
end ## set_fit_results!()


#==============================================================================#


"Format the results of the amplification analyses."
@inline function set_output_fields!(
    o                       ::AmpOutput,
    i                       ::AmpInput,
    results                 ::AbstractArray,
)
    debug(logger, "at set_output_fields!()")
    foreach(fieldnames(first(results))) do fieldname
        output_field = getfield(o, fieldname)
        T = output_field |> eltype
        vector_output_field = ndims(output_field) == 3
        if vector_output_field
            setfield!(o, fieldname,
                results |>
                moose(bless(Vector{T}) ∘ field(fieldname), hcat) |>
                morph(:, i.num_wells, i.num_channels))
        else
            setfield!(o, fieldname,
                results |> mold(bless(T) ∘ field(fieldname)) |>
                bless(SMatrix{i.num_wells, i.num_channels, T}))
        end ## if
    end ## next fieldname
    return nothing ## side effects only
end ## set_output_fields!()


#==============================================================================#


"Calculate the amplification analysis fields `qt_fluos` and `max_qt_fluo`, when
the output format is `long`."
function set_qt_fluos!(
    o                       ::AmpLongOutput,
    i                       ::AmpInput,
)
    debug(logger, "at set_qt_fluos!()")
    o.qt_fluos =
        [   quantile(o.blsub_fluos[:, well_i, channel_i], i.qt_prob)
            for well_i in 1:i.num_wells, channel_i in 1:i.num_channels ]
    o.max_qt_fluo = maximum(o.qt_fluos)
    return nothing ## side effects only
end ## set_qt_fluos!()


"Do nothing when the output format is `short`."
set_qt_fluos!(
    o                       ::AmpShortOutput,
    i                       ::AmpInput,
) = nothing


#==============================================================================#


"Call `report_cq!` for each well and channel, when the output format is `long`."
function set_report_cq!(
    o                       ::AmpLongOutput,
    i                       ::AmpInput,
)
    debug(logger, "at set_report_cq!()")
    for well_i in 1:i.num_wells, channel_i in 1:i.num_channels
        report_cq!(i, o, well_i, channel_i)
    end
    return nothing ## side effects only
end ## set_report_cq!()


"Do nothing when the output format is `short`."
function set_report_cq!(
    o                       ::AmpShortOutput,
    i                       ::AmpInput,
) 
    debug(logger, "at set_report_cq!() SHORT FORMAT")
    temp_cq=fill(NaN_T,size(o.cq)[1],size(o.cq)[2])
    
    max_dr1_lb, max_dr2_lb, max_bsf_lb = i.max_dr1_lb, i.max_dr2_lb, i.max_bsf_lb
    qt_fluos_ =
        [   quantile(o.blsub_fluos_flb[:, well_i, channel_i], i.qt_prob)
            for well_i in 1:i.num_wells, channel_i in 1:i.num_channels ]
    max_qt_fluo_ = maximum(qt_fluos_)
    for well_i in 1:i.num_wells, channel_i in 1:i.num_channels
        b_ = o.coefs[1, well_i, channel_i]
        postbl_status =o.quant_status[well_i, channel_i]
        max_dr1=maximum(o.dr1_pred[:,well_i,channel_i])
        max_dr2=maximum(o.dr2_pred[:,well_i,channel_i])
        max_bsf = maximum(o.blsub_fluos_flb[:, well_i, channel_i])
        max_bsf_ = maximum(o.blsub_fluos[(end-Int(floor((size(o.blsub_fluos)[1])/4))):end, well_i, channel_i])
        (scaled_max_dr1, scaled_max_dr2, scaled_max_bsf) =
        [max_dr1, max_dr2, max_bsf] ./ max_qt_fluo_


        if (max_bsf < i.max_bsf_lb || scaled_max_bsf < i.scaled_max_bsf_lb ||
            max_dr2 < max_dr2_lb || max_dr1 < max_dr1_lb  || 
            scaled_max_dr2 < i.scaled_max_dr2_lb || 
            scaled_max_dr1 < i.scaled_max_dr1_lb || o.cq[well_i, channel_i]>i.num_cycles || 
            o.cq[well_i, channel_i]<i.min_reliable_cyc || postbl_status == :Error ||
            b_ > 0 || max_bsf_ < i.max_bsf_lb)
            
            o.blsub_fluos[:,well_i, channel_i]=o.blsub_fluos_flb[:,well_i, channel_i]
            o.dr1_pred[:,well_i, channel_i]=o.dr1_pred1[:,well_i, channel_i]
            o.dr2_pred[:,well_i, channel_i]=o.dr2_pred1[:,well_i, channel_i]
            
        else
            temp_cq[well_i, channel_i] = o.cq[well_i, channel_i]
        end
    end
    o.cq=convert(typeof(o.cq),temp_cq)
    return nothing
end

"Report amplification output fields relating to the calculation of `cq`."
function report_cq!(
    o                       ::AmpLongOutput,
    i                       ::AmpInput,
    well_i                  ::Int_T,
    channel_i               ::Int_T,
)
    if i.before_128x
        max_dr1_lb, max_dr2_lb, max_bsf_lb = [i.max_dr1_lb, i.max_dr2_lb, i.max_bsf_lb] ./ 128
    else
        max_dr1_lb, max_dr2_lb, max_bsf_lb = i.max_dr1_lb, i.max_dr2_lb, i.max_bsf_lb
    end
    #
    num_cycles = size(o.raw_data, 1)
    (postbl_status, cq_raw, max_dr1, max_dr2) =
        map([ :postbl_status, :cq_raw, :max_dr1, :max_dr2 ]) do fieldname
            fieldname -> getfield(o, fieldname)[well_i, channel_i]
        end
    max_bsf = maximum(o.blsub_fluos[:, well_i, channel_i])
    b_ = o.coefs[1, well_i, channel_i]
    (scaled_max_dr1, scaled_max_dr2, scaled_max_bsf) =
        [max_dr1, max_dr2, max_bsf] ./ o.max_qt_fluo
    why_NaN =
        if postbl_status == :Error
            "postbl_status == :Error"
        elseif b_ > 0
            "b > 0"
        elseif o.cq_method == ct && o.cq_raw == AMP_CT_VAL_DOMAINERROR
            "DomainError when calculating Ct"
        elseif o.cq_raw <= 0.1 || o.cq_raw >= num_cycles
            "cq_raw <= 0.1 || cq_raw >= num_cycles"
        elseif max_dr1 < max_dr1_lb
            "max_dr1 $max_dr1 < max_dr1_lb $max_dr1_lb"
        elseif max_dr2 < max_dr2_lb
            "max_dr2 $max_dr2 < max_dr2_lb $max_dr2_lb"
        elseif max_bsf < max_bsf_lb
            "max_bsf $max_bsf < max_bsf_lb $max_bsf_lb"
        elseif scaled_max_dr1 < i.scaled_max_dr1_lb
            "scaled_max_dr1 $scaled_max_dr1 < scaled_max_dr1_lb $(i.scaled_max_dr1_lb)"
        elseif scaled_max_dr2 < i.scaled_max_dr2_lb
            "scaled_max_dr2 $scaled_max_dr2 < scaled_max_dr2_lb $(i.scaled_max_dr2_lb)"
        elseif scaled_max_bsf < i.scaled_max_bsf_lb
            "scaled_max_bsf $scaled_max_bsf < scaled_max_bsf_lb $(i.scaled_max_bsf_lb)"
        else
            ""
        end ## why_NaN
    (why_NaN != "") && (o.cq[well_i, channel_i] = NaN_T)
    #
    for tup in (
        (:max_bsf,        max_bsf),
        (:scaled_max_dr1, scaled_max_dr1),
        (:scaled_max_dr2, scaled_max_dr2),
        (:scaled_max_bsf, scaled_max_bsf),
        (:why_NaN,        why_NaN))
        getfield(o, tup[1])[well_i, channel_i] = tup[2]
    end
    return nothing ## side effects only
end ## report_cq!



#===============================================================================
    helper functions >>
===============================================================================#

amp_init(i ::AmpInput, x) =
    SMatrix{i.num_wells, i.num_channels, typeof(x)}(
        fill(x, i.num_wells, i.num_channels))


function check_bl_cyc_bounds(
    i               ::AmpInput,
    bl_cyc_bounds   ::Union{Vector{I},Array{Vector{I},2}} where {I <: Int_T},
)
    debug(logger, "at check_bl_cyc_bounds()")
    (i.num_cycles <= 2) && return bl_cyc_bounds
    size_bcb = size(bl_cyc_bounds)
    if size_bcb == (0,) || size_bcb == (2,)
        return amp_init(i, bl_cyc_bounds)
    elseif size_bcb == (i.num_wells, i.num_channels) &&
        eltype(bl_cyc_bounds) <: AbstractVector ## final format of `baseline_cyc_bounds`
            return bl_cyc_bounds
    end
    throw(ArgumentError("`baseline_cyc_bounds` is not in the right format"))
end ## check_bl_cyc_bounds()


## baseline estimation parameters
# kwargs_bl(i ::AmpInput) =
#     Dict{Symbol,Any}(
#         :bl_method          => i.bl_method,
#         :bl_fallback_func   => i.bl_fallback_func,
#         :min_reliable_cyc   => i.min_reliable_cyc,
#     )

## quantitation parameters
# kwargs_quant(i ::AmpInput) =
#     Dict{Symbol,Any}(
#         :cq_method          => i.cq_method,
#         :denser_factor      => i.denser_factor,
#     )

## arguments for process_ad()
# kwargs_ad(i ::AmpInput) =
#     Dict{Symbol,Any}(
#         :ctrl_well_dict     => i.ctrl_well_dict,
#         # :cluster_method     => i.cluster_method,
#         # :norm_l             => i.norm_l,
#         # :encgr              => i.encgr,
#         # :categ_well_vec     => i.categ_well_vec
#     )
