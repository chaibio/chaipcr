## thermal_consistency.jl
## 72°C thermal consistency test

import Dierckx: Spline1D, derivative
import Match.@match
import Memento: debug, error


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
    debug(logger, "at act(::ThermalConsistency)")
 
    ## calibration data is required
    if !haskey(req_dict, CALIBRATION_INFO_KEY) || !(typeof(req_dict[CALIBRATION_INFO_KEY]) <: Associative)
        error(logger, "no calibration information found")
    end

    const kwdict_mc_tm_pw = OrderedDict{Symbol,Any}(
        map(keys(MC_TM_PW_KEYWORDS)) do key
            key => req_dict[MC_TM_PW_KEYWORDS[key]]
        end)
    
    ## process data as melting curve
    const mc_w72c = process_mc(
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
    const channel_proc = 1
    const channel_proc_i = find(channel_proc .== mc_w72c.channel_nums)[1]
    #
    const mc_tm = map(
        field(Ta_fltd),
        mc_w72c.mc_bychwl[:, channel_proc_i])
    #
    min_Tm = max_tmprtr + 1
    max_Tm = 0
    const tm_check_vec = map(mc_tm) do Ta
        if size(Ta)[1] == 0
            TmCheck1w((NaN, false), NaN)
        else
            top1_Tm = Ta[1,1]
            if top1_Tm < min_Tm
                min_Tm = top1_Tm
            end
            if top1_Tm > max_Tm
                max_Tm = top1_Tm
            end
            TmCheck1w(
                (top1_Tm, MIN_TM_VAL <= top1_Tm <= MAX_TM_VAL),
                Ta[1,2])
        end ## if size
    end ## do Ta
    #
    ## return values
    const delta_Tm_val = max_Tm - min_Tm
    mc_w72c_out() = OrderedDict(
        :tm_check => tm_check_vec,
        :delta_Tm => (round(delta_Tm_val, JSON_DIGITS), delta_Tm_val .<= MAX_DELTA_TM_VAL),
        :valid    => true)
    @match out_format begin
        :full   =>  ThermalConsistencyOutput(
                        tm_check_vec,
                        (delta_Tm_val, delta_Tm_val .<= MAX_DELTA_TM_VAL),
                        true)
        :json   =>  JSON.json(mc_w72c_out())
        _       =>  mc_w72c_out()
    end
end ## act()


#
