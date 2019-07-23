#===============================================================================

    thermal_consistency.jl

    72°C thermal consistency test

===============================================================================#

import Dierckx: Spline1D, derivative
import Memento: debug, warn, error



#===============================================================================
    constants >>
===============================================================================#

## preset values
# const MIN_FLUORESCENCE_VAL = 8e5 ## not used
const MIN_TM_VAL = 77
const MAX_TM_VAL = 81
const MAX_DELTA_TM_VAL = 2



#===============================================================================
    function >>
===============================================================================#

## called by dispatch()
##
## NB default values supplied to mc_analysis()
## are the same as for melting curve experiments
function act(
    ::Type{Val{thermal_consistency}},
    ## remove MySql dependency
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # stage_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict};
    req_dict            ::Associative;
    dcv                 ::Bool = DEFAULT_CAL_DCV, ## if true, perform multi-channel deconvolution
    auto_span_smooth    ::Bool = DEFAULT_MC_AUTO_SPAN_SMOOTH,
    span_smooth_default ::Real = DEFAULT_MC_SPAN_SMOOTH_DEFAULT,
    span_smooth_factor  ::Real = DEFAULT_MC_SPAN_SMOOTH_FACTOR,
    max_temperature     ::Real = DEFAULT_MC_MAX_TEMPERATURE, ## maximum temperature to analyze
    out_format          ::OutputFormat = pre_json_output,
    reporting           ::Function = roundoff(JSON_DIGITS) ## reporting function
)
    debug(logger, "at act(::Type{Val{thermal_consistency}})")
    #
    ## calibration data is required
    if has_calibration_info(req_dict)
        return fail(logger, ArgumentError(
            "no calibration information found")) |> out(out_format)
    end
    const get_calibration_data(req_dict)
    #
    ## parse melting curve data into DataFrame
    const mc_parsed_raw_data = mc_parse_raw_data(req_dict[RAW_DATA_KEY])
    #
    ## parse analysis parameters from request
    const kw_pa = OrderedDict{Symbol,Any}(
        map(keys(MC_PEAK_ANALYSIS_KEYWORDS)) do key
            key => req_dict[MC_PEAK_ANALYSIS_KEYWORDS[key]]
        end)
    #
    ## create container for data and parameter values
    interface = McInput(
            mc_parsed_raw_data...,
            calibration_data;
            calibration_args = CalibrationParameters(dcv = dcv),
            auto_span_smooth = auto_span_smooth,
            span_smooth_default = span_smooth_default,
            span_smooth_factor = span_smooth_factor,
            max_temperature = max_temperature,
            out_format = full_output,
            reporting = reporting,
            kw_pa...)
    #
    ## analyse data as melting curve
    const mc_w72c = try
        mc_analysis(interface)
    catch err
        return fail(logger, err; bt=true) |> out(out_format)
    end ## try
    #
    ## process the data from only one channel
    ## PROBLEM >> this does not seem appropriate for dual channel analysis
    const mc_tm = map(
        field(:peaks_filtered),
        mc_w72c.peak_output[:, CHANNELS[1]]) ## mc_matrix
    println(mc_tm)
    min_Tm = max_temperature + 1
    max_Tm = 0
    const tm_check_vec = map(mc_tm) do Ta
        if size(Ta, 1) == 0
            TmCheck1w((NaN, false), NaN)
        else
            const top1_Tm = Ta[1,1]
            (top1_Tm < min_Tm) && (min_Tm = top1_Tm)
            (top1_Tm > max_Tm) && (max_Tm = top1_Tm)
            TmCheck1w(
                (top1_Tm, MIN_TM_VAL <= top1_Tm <= MAX_TM_VAL),
                Ta[1,2])
        end ## if size
    end ## do Ta
    #
    ## return values
    const delta_Tm_val = max_Tm - min_Tm
    full_out() =
        ThermalConsistencyOutput(
            tm_check_vec,
            (delta_Tm_val, delta_Tm_val .<= MAX_DELTA_TM_VAL),
            true) 
    pre_json_out() =
        OrderedDict(
            :tm_check => tm_check_vec,
            :delta_Tm => (reporting(delta_Tm_val),
                            delta_Tm_val .<= MAX_DELTA_TM_VAL),
            :valid    => true)
    (out_format == full_output) && return full_out()
    ## else
    return pre_json_out() |> out(out_format)
end ## act(::Type{Val{thermal_consistency}})
