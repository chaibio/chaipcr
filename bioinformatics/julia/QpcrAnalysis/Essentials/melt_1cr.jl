# melt curve data and fluorescence within 1C range

function melt_1cr(
    floor_tmprtr::Real,
    # copy over the whole signature of `process_mc` and comment out `out_format`
    db_conn::MySQL.MySQLHandle,
    exp_id::Integer, stage_id::Integer,
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

    mc_out = process_mc(
        db_conn,
        exp_id, stage_id, calib_info;
        well_nums=well_nums,
        auto_span_smooth=auto_span_smooth,
        span_smooth_default=span_smooth_default,
        span_smooth_factor=span_smooth_factor,
        dye_in=dye_in, dyes_2bfild=dyes_2bfild,
        dcv=dcv,
        max_tmprtr=max_tmprtr,
        out_format="full", # extra output
        verbose=verbose,
        kwdict_mc_tm_pw=kwdict_mc_tm_pw
    )

    channels = mc_out["channels"]
    fluo_well_nums = mc_out["fluo_well_nums"]
    num_fluo_wells, num_channels = size(mc_out["mc_bywell"])

    mc_tm = [
        mc_out["mc_bychwl"][well_i, channel_i]["Ta_fltd"]
        for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
    ] # an array of the same dimension as `mc_out["mc_bywell"]`

    # For each well, average the calibrated fluorescence values for the temperatures between `floor_tmprtr` and `floor_tmprtr + 1`
    fluo_1cr = [
        begin
            tf = mc_out["tf_bychwl"][channel][well_i]
            tmprtrs_1cr = find(tf["tmprtrs"]) do tmprtr
                floor_tmprtr <= tmprtr < floor_tmprtr + 1
            end # do tmprtr
            mean(tf["fluos"][tmprtrs_1cr])
        end # begin
        for well_i in 1:num_fluo_wells, channel in channels
    ]

    mc_w1cr = OrderedDict(
        "mc_tm"=>mc_tm,
        "fluo_1cr"=>fluo_1cr,
        "channels"=>channels,
        "fluo_well_nums"=>fluo_well_nums
    )

    return mc_w1cr
end
