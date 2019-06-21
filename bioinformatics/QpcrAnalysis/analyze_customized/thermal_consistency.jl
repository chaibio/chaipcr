## thermal_consistency.jl
## 72°C thermal consistency test

import Dierckx: Spline1D, derivative

function act(
    ::ThermalConsistency,
    ## remove MySql dependency
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # stage_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict};
    req_dict            ::Associative;
    out_format          ::Symbol = :pre_json,
    
    ## the following options are never used
    well_nums           ::AbstractVector =[],
    auto_span_smooth    ::Bool =false,
    span_smooth_default ::Real =0.015,
    span_smooth_factor  ::Real =7.2,
    dye_in              ::Symbol =:FAM,
    dyes_2bfild         ::AbstractVector =[],
    dcv                 ::Bool =true, ## if true, perform multi-channel deconvolution
	max_tmprtr          ::Real =1000, ## maximum temperature to analyze
)
    log_debug("at act(::ThermalConsistency)")
 
    ## calibration data is required
    if !haskey(req_dict, CALIBRATION_INFO_KEY) || !(typeof(req_dict[CALIBRATION_INFO_KEY]) <: Associative)
        log_error("no calibration information found")
    end

    const kwdict_mc_tm_pw = OrderedDict{Symbol,Any}(
        map(keys(MC_TM_PW_KEYWORDS)) do key
            key => req_dict[MC_TM_PW_KEYWORDS[key]]
        end) ## do key
    
    ## process data as melting curve
    mc_w72c = process_mc(
        ## remove MySql dependency
        # db_conn,
        # exp_id,
        # stage_id,
        # calib_info;
        req_dict[RAW_DATA_KEY],
        req_dict[CALIBRATION_INFO_KEY];
        well_nums = well_nums,
        auto_span_smooth = auto_span_smooth,
        span_smooth_default = span_smooth_default,
        span_smooth_factor = span_smooth_factor,
        dye_in = dye_in,
        dyes_2bfild = dyes_2bfild,
        dcv = dcv,
        max_tmprtr = max_tmprtr,
        out_format = :full,
        kwdict_mc_tm_pw = kwdict_mc_tm_pw
    )
    ## process the data from only one channel
    channel_proc = 1
    channel_proc_i = find(mc_w72c.channel_nums) do channel_num
        channel_num == channel_proc
    end[1] ## do channel_num
    #
    mc_tm = map(
        mc_bywl -> mc_bywl.Ta_fltd,
        mc_w72c.mc_bychwl[:, channel_proc_i]
    )
    #
    tm_check_vec = []
    min_Tm = max_tmprtr + 1
    max_Tm = 0
    for Ta in mc_tm
        if size(Ta)[1] == 0
            tm_check_1w = TmCheck1w((NaN, false), NaN)
        else
            top1_Tm = Ta[1,1]
            if top1_Tm < min_Tm
                min_Tm = top1_Tm
            end
            if top1_Tm > max_Tm
                max_Tm = top1_Tm
            end
            tm_check_1w = TmCheck1w(
                (top1_Tm, MIN_TM_VAL <= top1_Tm <= MAX_TM_VAL),
                Ta[1,2]
            )
        end ## if size
        push!(tm_check_vec, tm_check_1w)
    end ## for
    #
    delta_Tm_val = max_Tm - min_Tm
    if (out_format == :full)
        return ThermalConsistencyOutput(
            tm_check_vec,
            (delta_Tm_val, delta_Tm_val <= MAX_DELTA_TM_VAL),
            true)
    end
    ## out_format != :full
    mc_w72c_out = OrderedDict(
        :tm_check => tm_check_vec,
        :delta_Tm => (round(delta_Tm_val, JSON_DIGITS), delta_Tm_val <= MAX_DELTA_TM_VAL),
        :valid    => true)
    return (out_format == :json) ?
        JSON.json(mc_w72c_out) :
        mc_w72c_out
end


#
