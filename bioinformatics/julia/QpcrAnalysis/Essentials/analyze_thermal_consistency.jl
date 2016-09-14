# chaipcr/web/public/dynexp/thermal_consistency/analyze.R
# 72C thermal consistency test

# constants
const MIN_FLUORESCENCE_VAL = 8e5
const MIN_TM_VAL = 77
const MAX_TM_VAL = 81
const MAX_DELTA_TM_VAL = 2


ANALYZE_DICT["thermal_consistency"] = function thermal_consistency(
    # copy over the whole signature of `meltcrv`, comment out `stage_id`
    db_conn::MySQL.MySQLHandle,
    exp_id::Integer, # stage_id::Integer,
    calib_info::Union{Integer,OrderedDict};
    # start: arguments that might be passed by upstream code
    well_nums::AbstractVector=[],
    auto_span_smooth::Bool=false,
    span_smooth_default::Real=0.015,
    span_smooth_factor::Real=7.2,
    # end: arguments that might be passed by upstream code
    dye_in::AbstractString="FAM", dyes_2bfild::AbstractVector=[],
    dcv::Bool=true, # logical, whether to perform multi-channel deconvolution
	max_tmprtr::Real=1000, # maximum temperature to analyze
    # out_format::AbstractString="json", # "full", "pre_json", "json"
    verbose::Bool=false,
    kwdict_mc_tm_pw::OrderedDict=OrderedDict() # keyword arguments passed onto `mc_tm_pw`
    )

    # hard-coded arguments
    stage_id = 4
    # passed onto `mc_tm_pw`, different than default
    qt_prob_flTm = 0.1
    max_normd_qtv = 0.9

    mc_w72c = process_mc(
        db_conn,
        exp_id, stage_id,
        calib_info;
        well_nums=well_nums,
        auto_span_smooth=auto_span_smooth,
        span_smooth_default=span_smooth_default,
        span_smooth_factor=span_smooth_factor,
        dye_in=dye_in, dyes_2bfild=dyes_2bfild,
        dcv=dcv,
        max_tmprtr=max_tmprtr,
        out_format="full",
        verbose=verbose,
        kwdict_mc_tm_pw=OrderedDict(
            :qt_prob_flTm=>qt_prob_flTm,
            :max_normd_qtv=>max_normd_qtv
        )
    )

    # process the data from only one channel
    channel_proc = 1
    channel_proc_i = find(mc_w72c["channels"]) do channel
        channel == channel_proc
    end[1] # do channel

    mc_tm = map(
        mc_bywl -> mc_bywl["Ta_fltd"],
        mc_w72c["mc_bychwl"][:, channel_proc_i]
    )

    tm_check_vec = []
    min_Tm = max_tmprtr + 1
    max_Tm = 0

    for Ta in mc_tm
        if size(Ta)[1] == 0
            tm_check_1w = OrderedDict("Tm" => (NaN, false), "area" => NaN)
        else
            top1_Tm = Ta[1,1]
            if top1_Tm < min_Tm
                min_Tm = top1_Tm
            end
            if top1_Tm > max_Tm
                max_Tm = top1_Tm
            end
            tm_check_1w = OrderedDict(
                "Tm" => (
                    top1_Tm,
                    MIN_TM_VAL <= top1_Tm <= MAX_TM_VAL),
                "area" => Ta[1,2] )
        end # if size
        push!(tm_check_vec, tm_check_1w)
    end # for

    delta_Tm = max_Tm - min_Tm

    mc_w72c_out = OrderedDict(
        "tm_check" => tm_check_vec,
        "delta_Tm" => (round(delta_Tm, JSON_DIGITS), delta_Tm <= MAX_DELTA_TM_VAL)
    )

    return json(mc_w72c_out)

end




# # testing
# module thermal_consistency
# using QpcrAnalysis
# analyze = QpcrAnalysis.analyze_thermal_consistency
# end




#
