## thermal_consistency.jl
##
## 72°C thermal consistency test

import Dierckx: Spline1D, derivative
import Memento: debug, warn, error


## constants 

## preset values
const MIN_FLUORESCENCE_VAL = 8e5
const MIN_TM_VAL = 77
const MAX_TM_VAL = 81
const MAX_DELTA_TM_VAL = 2


## called by dispatch()
## NB default values supplied to process_mc()
##    are the same as for melting curve experiments
function act(
    ::Type{Val{thermal_consistency}},
    ## remove MySql dependency
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # stage_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict};
    req_dict            ::Associative;
    out_format          ::Symbol = :pre_json,
    well_nums           ::AbstractVector = DEFAULT_MC_WELL_NUMS,
    auto_span_smooth    ::Bool = DEFAULT_MC_AUTO_SPAN_SMOOTH,
    span_smooth_default ::Real = DEFAULT_MC_SPAN_SMOOTH_DEFAULT,
    span_smooth_factor  ::Real = DEFAULT_MC_SPAN_SMOOTH_FACTOR,
    dcv                 ::Bool = DEFAULT_MC_DCV, ## if true, perform multi-channel deconvolution
    max_temperature     ::Real = DEFAULT_MC_MAX_TEMPERATURE, ## maximum temperature to analyze
    reporting           =roundoff(JSON_DIGITS) ## reporting function
)
    debug(logger, "at act(::Type{Val{thermal_consistency}})")

    ## calibration data is required
    if !(haskey(req_dict, CALIBRATION_INFO_KEY) &&
        typeof(req_dict[CALIBRATION_INFO_KEY]) <: Associative)
            return fail(logger, ArgumentError(
                "no calibration information found")) |> out(out_format)
    end
    const calibration_data = CalibrationData(req_dict[CALIBRATION_INFO_KEY])

    ## parse melting curve data into DataFrame
    # const mc_data = MeltCurveRawData(req_dict[RAW_DATA_KEY])
    const mc_data = DataFrame()
    foreach(keys(MC_RAW_FIELDS)) do key
        mc_data[key] = mc_data[RAW_DATA_KEY][MC_RAW_FIELDS[key]]
    end

    const kwargs_mc_tm_pw = OrderedDict{Symbol,Any}(
        map(keys(MC_TM_PW_KEYWORDS)) do key
            key => req_dict[MC_TM_PW_KEYWORDS[key]]
        end)
    
    ## process data as melting curve
    const mc_w72c = try
        process_mc(
            ## remove MySql dependency
            # db_conn,
            # exp_id,
            # stage_id,
            # calib_info;
            mc_data,
            calibration_data;
            well_nums = well_nums,
            auto_span_smooth = auto_span_smooth,
            span_smooth_default = span_smooth_default,
            span_smooth_factor = span_smooth_factor,
            dcv = dcv,
            max_temperature = max_temperature,
            out_format = :full,
            kwargs_mc_tm_pw = kwargs_mc_tm_pw)
    catch err
        return fail(logger, err; bt=true) |> out(out_format)
    end ## try
    ## process the data from only one channel
    const channel_proc = 1
    const channel_proc_i = find(channel_proc .== mc_w72c.channel_nums)[1]
    const mc_tm = map(
        field(:Ta_fltd),
        mc_w72c.mc_array[:, channel_proc_i]) ## mc_bychwl
    min_Tm = max_temperature + 1
    max_Tm = 0
    const tm_check_vec = map(mc_tm) do Ta
        if size(Ta)[1] == 0
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
    (out_format == :full) && return full_out()
    ## else
    return pre_json_out() |> out(out_format)
end ## act(::Type{Val{thermal_consistency}})
