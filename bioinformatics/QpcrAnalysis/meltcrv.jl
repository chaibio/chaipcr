# melt curve analysis

import DataArrays.DataArray
import StatsBase.countmap

const EMPTY_mc = zeros(1,3)[1:0,:]
const EMPTY_Ta = zeros(1,2)[1:0,:]
const EMPTY_mc_tm_pw_out = OrderedDict(
    "mc" => EMPTY_mc,
    "Ta_raw" => EMPTY_Ta,
    "Ta_fltd" => EMPTY_Ta
)


struct MeltCurveTF # temperature and fluorescence
    t_da_vec ::Vector{DataArray{Float64,1}}
    fluo_da ::DataArray{Float64,2}
end

struct MeltCurveTa # Tm and area
    mc ::Array{Float64,2}
    Ta_fltd ::Array{Float64,2}
    mc_denser ::Array{Float64,2}
    ns_range_mid ::Real
    sn_dict ::OrderedDict{String,Array{Float64,2}}
    Ta_raw ::Array{Float64,2}
    Ta_reported ::String
end

struct MeltCurveOutput
    mc_bychwl ::Matrix{MeltCurveTa} # dim1 is well and dim2 is channel
    channel_nums ::Vector{Int}
    fluo_well_nums ::Vector{Int}
    fr_ary3 ::Array{Float64,3}
    mw_ary3 ::Array{Float64,3}
    k4dcv ::K4Deconv
    fdcvd_ary3 ::Array{Float64,3}
    wva_data ::OrderedDict{String,OrderedDict{Int,Vector{Float64}}}
    wva_well_nums ::Vector{Int}
    faw_ary3 ::Array{Float64,3}
    tf_bychwl ::OrderedDict{Int,Vector{OrderedDict{String,Vector{Float64}}}}
end



# Top-level function: get melting curve data and Tm for a melt curve experiment
function process_mc(

    # remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # stage_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict};

    # new >>
    exp_id ::Integer,
    stage_id ::Integer,
    mc_data ::OrderedDict{String,Any},
    calib_data ::OrderedDict{String,Any};
    channel_nums ::AbstractVector =[1],
    # << new

    # start: arguments that might be passed by upstream code
    well_nums ::AbstractVector =[],
    auto_span_smooth ::Bool =false,
    span_smooth_default ::Real =0.015,
    span_smooth_factor ::Real =7.2,
    # end: arguments that might be passed by upstream code

    dye_in ::String ="FAM",
    dyes_2bfild ::AbstractVector =[],
    dcv ::Bool =true, # logical, whether to perform multi-channel deconvolution
	max_tmprtr ::Real =1000, # maximum temperature to analyze
    out_format ::String ="json", # "full", "pre_json", "json"
    verbose ::Bool =false,
    kwdict_mc_tm_pw ::OrderedDict =OrderedDict() # keyword arguments passed onto `mc_tm_pw`
    )

    # print_v(println, verbose,
    #     "db_conn: ", db_conn, "\n",
    #     "experiment_id: $exp_id\n",
    #     "stage_id: $stage_id\n",
    #     "calib_info: $calib_info\n",
    #     "max_tmprtr: $max_tmprtr"
    # )
    
    ## remove MySql dependency
    #
    # calib_info = ensure_ci(db_conn, calib_info, exp_id)
    #
    # mcd_qry_2b = "
    #     SELECT well_num, channel
    #         FROM melt_curve_data
    #             WHERE
    #                 experiment_id = $exp_id AND
    #                 stage_id = $stage_id AND
    #                 temperature <= $max_tmprtr
    #                 well_constraint
    # "
    # mcd_nt, fluo_well_nums = get_mysql_data_well(
    #     well_nums, mcd_qry_2b, db_conn, verbose
    # )

    # new >>
    # not implemented yet
    calib_data = ensure_ci(calib_data, exp_id)
    # << new

    # pre-deconvolution, can process multiple channels
    # channel_nums = sort(unique(mcd_nt[:channel])) # process all available channels in the database
    num_channels = length(channel_nums)
    if num_channels == 1
        dcv = false
    end

    # pre-deconvolution, process only channel 1
    # channel_nums = [1]
    # num_channels = 1
    # dcv = false

    ## remove MySql dependency
    #
    # mc_data_bych = map(channel_nums) do channel_num
    #     get_mc_data(
    #         channel_num,
    #         db_conn,
    #         exp_id,
    #         stage_id,
    #         well_nums,
    #     	max_tmprtr
    #     )
    # end
    #
    # fr_ary3 = cat(3, map(mc_data -> mc_data.fluo_da, mc_data_bych)...) # fr = fluo_raw

    # new >>
    # reshape raw fluorescence data to 3-dimensional array
    #
    fluo_well_nums  = sort(unique(mc_data["well_num"]))
    num_fluo_wells  = length(fluo_well_nums)
    num_channels    = length(channel_nums)
    #
    # truncate data where necessary so it fits in 3d matrix
    channel_x_well = mc_data["channel"] * num_fluo_wells + mc_data["well_num"]
    counts = StatsBase.countmap(channel_x_well)
    id = channel_x_well .== collect(keys(counts))'
    shortest = minimum(values(counts))
    keep = mapslices(x -> reduce(|,x), id .& map(x -> x <= shortest, mapslices(cumsum, id, 1)), 2)
    for var in keys(mc_data)
        filter!(keep, mc_data[var])
    end
    # << new

    fr_ary3 = reshape(
        mc_data["fluorescence_value"],
        shortest, num_fluo_wells, num_channels
    )
    # << new

    mw_ary3, k4dcv, fdcvd_ary3, wva_data, wva_well_nums, faw_ary3 = dcv_aw(
        fr_ary3,
        dcv,
        channel_nums,

        ## remove MySql dependency
        #
        # db_conn,
        # calib_info,
        # fluo_well_nums, 
        # well_nums,

        # new >>
        calib_data,
        fluo_well_nums, 
        # << new

        dye_in, 
        dyes_2bfild;
        aw_out_format="array"
    )

    # post-deconvolution, process for only 1 channel
    # channel_only1 = 1 # used: 1, 2
    # fc_bych = OrderedDict(channel_only1 => fc_bych[channel_only1])

    tf_bychwl = OrderedDict( # bychwl = by channel then by well
        map(1:num_channels) do channel_i
            tf = map(wva_well_nums) do wva_well_num
                if wva_well_num in fluo_well_nums
                    i = indexin([wva_well_num], fluo_well_nums)[1]
                    tmprtrs_wNaN = mc_data_bych[channel_i].t_da_vec[i]
                    fluos_wNaN = faw_ary3[:,i,channel_i]
                    idc_not_NaN = find(tmprtrs_wNaN) do tmprtr
                        !isnan(tmprtr)
                    end
                    tmprtrs = tmprtrs_wNaN[idc_not_NaN]
                    fluos_raw = fluos_wNaN[idc_not_NaN]
                    fluos = fluos_raw - minimum(fluos_raw) # where "normalized" came from
                    OrderedDict(
                        "tmprtrs" => tmprtrs,
                        "fluos" => fluos
                    ) # note: selecting one column of a 2-D array results in a vector (1-D array), but selecting one row of it results in a 1-row 2-D array.
                else
                    nothing
                end # if
            end # do oc_well_num
            return channel_nums[channel_i] => tf
        end) # do channel_i

    mc_bychwl = hcat(map(collect(values(tf_bychwl))) do tf_bywl
        map(tf_bywl) do tf_dict
            mc_tm_pw(
                tf_dict;
                auto_span_smooth=auto_span_smooth,
                span_smooth_default=span_smooth_default,
                span_smooth_factor=span_smooth_factor,
                verbose=verbose,
                kwdict_mc_tm_pw...
            )
        end # do tf_dict
    end...)

    if out_format[end-3:end] == "json"
        fns = [:mc, :Ta_fltd]
        keys = ["melt_curve_data", "melt_curve_analysis"]
        mc_out = OrderedDict(map(1:length(keys)) do fk_i
            keys[fk_i] => [getfield(mc_bychwl[well_i, channel_i], fns[fk_i])
                for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
            ]
        end) # do key_i
        if out_format == "json"
            mc_out = json(mc_out)
        end
    elseif out_format == "full"
        mc_out = MeltCurveOutput(
            mc_bychwl,
            channel_nums,
            fluo_well_nums,
            fr_ary3,
            mw_ary3,
            k4dcv,
            fdcvd_ary3,
            wva_data,
            wva_well_nums,
            faw_ary3,
            tf_bychwl
        )
    end # out_format

    return mc_out

end # process_mc


# functions called by `process_mc`

# function: get raw melt curve data and perform optical calibration
function get_mc_data(
    channel_num ::Integer,

    # remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer, stage_id ::Integer,
    # well_nums ::AbstractVector,

	max_tmprtr ::Real
    )

    # remove MySql dependency
    #
    # get fluorescence data for melting curve
    # fluo_qry_2b = "
    #     SELECT well_num, temperature, fluorescence_value
    #         FROM melt_curve_data
    #         WHERE
    #             experiment_id = $exp_id AND
    #             stage_id = $stage_id AND
    #             channel = $channel_num AND
	# 			temperature <= $max_tmprtr
    #             well_constraint
    #         ORDER BY well_num, temperature
    # "
    # fluo_sel, fluo_well_nums = get_mysql_data_well(
    #     well_nums, fluo_qry_2b, db_conn, false
    # )

    # split temperature and fluo data by well_num
    tf_names = [:temperature, :fluorescence_value]
    tf_dict_vec = map(fluo_well_nums) do well_num
        well_bool_vec = fluo_sel[:well_num] .== well_num
        OrderedDict(
            name => fluo_sel[name][well_bool_vec]
            for name in tf_names
        )
    end # do well_num

    # add NaN to the end if not enough data
    ori_len_vec = map(tf_dict -> length(tf_dict[tf_names[1]]), tf_dict_vec)
    max_len = maximum(ori_len_vec)
    tf_nv_adj = map(1:length(tf_dict_vec)) do i
        tf_dict = tf_dict_vec[i]
        ori_len = ori_len_vec[i]
        nan_da = ones(max_len - ori_len) * NaN
        OrderedDict(
            name => vcat(tf_dict[name], nan_da)
            for name in tf_names
        )
    end # do i

    # temperature DataArray vector, with rows as temperature points and columns as wells
    t_da_vec = map(tf_dict -> tf_dict[:temperature], tf_nv_adj)

    # fluorescence DataArray
    fluo_da = hcat(map(tf_dict -> tf_dict[:fluorescence_value], tf_nv_adj)...)

    return MeltCurveTF(t_da_vec, fluo_da)

end # get_mc_data


# function: get melting curve data and Tm peaks for each well

function mc_tm_pw(fake_input ::Void; kwargs...)
    EMPTY_mc_tm_pw_out
end

function mc_tm_pw(

    # input data
    tf_dict ::OrderedDict; # temperature and fluorescence

    # The maximum fraction of median temperature interval to be considered narrow
    nti_frac ::AbstractFloat=0.05,

    # smoothing -df/dt curve and if `smooth_fluo`, fluorescence curve too
    auto_span_smooth ::Bool=true,
    span_css_tmprtr ::Real=1, # css = choose `span_smooth`. fluorescence fluctuation with the temperature range of approximately `span_css_tmprtr * 2` is considered for choosing `span_smooth`
    span_smooth_default ::Real=0.05, # unit: fraction of data points for smoothing
    span_smooth_factor ::Real=7.2,

    # get a denser temperature sequence to get fluorescence and -df/dt from it and fitted spline function
    denser_factor ::Real=10,
    smooth_fluo_spl ::Bool=false,

    # identify Tm peaks and calculate peak area
    peak_span_tmprtr ::Real=2, # Within the smoothed -df/dt sequence spanning the temperature range of approximately `peak_span_tmprtr`, if the maximum -df/dt value equals that at the middle point of the sequence, identify this middle point as a peak summit. Similar to `span.peaks` in qpcR code. Combined with `peak_shoulder` (similar to `Tm.border` in qpcR code).
    # peak_shoulder ::Real=1, # 1/2 width of peak in temperature when calculating peak area  # consider changing from 1 to 2, or automatically determined (max and min d2)?

    # filter Tm peaks
    qt_prob_range_lb ::AbstractFloat=0.21, # quantile probability point for the lower bound of the range considered for number of crossing points
    ncp_ub ::Integer=10, # upper bound of number of data points crossing the mid range value (line parallel to x-axis) of smoothed -df/dt (`ndrv_smu`)
    noisy_factor ::AbstractFloat=0.2, # `num_cross_points` must also <= `noisy_factor * len_raw`
    qt_prob_flTm ::AbstractFloat=0.64, # quantile probability point for normalized -df/dT (range 0-1)
    normd_qtv_ub ::Real=0.8, # upper bound of normalized -df/dt values (range 0-1) at the quantile probablity point
    top1_from_max_ub ::Real=1, # upper bound of temperature difference between top-1 Tm peak and maximum -df/dt
    top_N ::Integer=4, # top number of Tm peaks to report
    frac_report_lb ::Real=0.1, # lower bound of area fraction of the Tm peak to be reported in regards to the largest real Tm peak

    json_digits ::Integer=JSON_DIGITS,

    verbose ::Bool=false,
    )

    # parse input data
    tmprtrs_ori = tf_dict["tmprtrs"]
    tmprtr_intvls = vcat(tmprtrs_ori[2:end], Inf .- tmprtrs_ori[end]) .- tmprtrs_ori
    nti = nti_frac * median(tmprtr_intvls) # nti = narrow temperature interval
    no_nti = find(tmprtr_intvl -> tmprtr_intvl > nti, tmprtr_intvls)
    tmprtrs = mutate_dups(tmprtrs_ori[no_nti]) # duplication may cause spline interpolation failure by Dierckx
    fluos = tf_dict["fluos"][no_nti]

    len_raw = length(tmprtrs)

    if len_raw <= 3
        ndrv_cfd = -finite_diff(
            tmprtrs, fluos;
            nu=1, method="central"
        ) # negative derivative by central finite differencing (cfd)
        mc_raw = hcat(tmprtrs, fluos, ndrv_cfd)
        Ta_raw = Ta_fltd = EMPTY_Ta # 0x2 Array{Float,2}

    else
        # start: choose span_smooth value

        min_tp = minimum(tmprtrs)
        max_tp = maximum(tmprtrs)
        whole_tp_span = max_tp - min_tp

        if auto_span_smooth

            print_v(println, verbose, "Automatic selection of `span_smooth`...")

            # find the region of length 2 * span_css_tmprtr showing the steepest fluo decrease (dcrs) between start and end
            fluo_dcrs_vec = map(1:len_raw) do i
                sel_idc_int = giis_uneven(tmprtrs, i, span_css_tmprtr)
                return fluos[sel_idc_int[1]] - fluos[sel_idc_int[end]]
            end # do i
            css_i = indmax(fluo_dcrs_vec)
            css_idc = giis_uneven(tmprtrs, css_i, span_css_tmprtr)

            tp_css = tmprtrs[css_idc]
            len_css = length(tp_css)
            fluo_css = vcat(fluos[css_idc], -Inf) # make sure the last element in `fluo_up_vec` is `false`, so that all the `fu_grp` will be pushed to `fu_grp_vec` as soon as `for` loop is done.

            # find the region(s) where fluorescence increase as temperature increase
            fluo_up_vec = fluo_css[1:end-1] .< fluo_css[2:end]
            fu_grp_vec = Vector{Vector{Int}}() # fu_grp = fluo_up group
            fu_grp = Vector{Int}()
            grp_ongoing = false
            for i in 1:len_css
                if fluo_up_vec[i]
                    grp_ongoing = true
                    push!(fu_grp, i)
                else
                    if grp_ongoing
                        grp_ongoing = false
                        push!(fu_grp_vec, fu_grp)
                        fu_grp = Vector{Int}()
                    end # if
                end # if else
            end # for
            # # below not necessary because `-Inf` was concatenated to the end of `fluo_css`
            # if length(fu_grp) > 0 # if `fluo_up_vec` ends with `true`
            #     push!(fu_grp_vec, fu_grp) # add the last group
            # end

            if length(fu_grp_vec) == 0
                print_v(println, verbose, "No fluo increase as temperature increase was detected, use `span_smooth_default` $span_smooth_default.")
                span_smooth = span_smooth_default
            else
                # println("Fluorescence increase with temperature increase was detected.")
                # calculate the longest temperature span where fluorescence increase as temperature increase
                fu_tp_span_vec = map(fu_grp_vec) do fu_grp
                    tmprtrs[fu_grp[end] + 1] - tmprtrs[fu_grp[1]]
                end
                max_fu_tp_span = maximum(fu_tp_span_vec)
                span_smooth_product = span_smooth_factor * max_fu_tp_span / whole_tp_span
                if span_smooth_product > span_smooth_default
                    span_smooth = span_smooth_product
                    print_v(println, verbose, "`span_smooth` was selected as $span_smooth.")
                else
                    span_smooth = span_smooth_default
                    print_v(println, verbose, "`span_smooth_product` $span_smooth_product < `span_smooth_default`, use `span_smooth_default` $span_smooth_default.")
                end
            end
            # end: choose span_smooth value

        else
            span_smooth = span_smooth_default
            print_v(println, verbose, "No automatic selection, use span_smooth_default $span_smooth as `span_smooth`.")
        end # if auto_span_smooth


        # start: fit cubic spline to fluos ~ tmprtrs, re-calculate fluorescence and calculate -df/dt using `tp_denser` (a denser sequence of temperatures)

        # smooth raw fluo values
        smooth_fluos = supsmu(tmprtrs, fluos, span_smooth / denser_factor)
        tf_tuple = (tmprtrs, smooth_fluos)
        shorter_length_raw = minimum(map(length, tf_tuple))

        spl = Spline1D(map(ele -> ele[1:shorter_length_raw], tf_tuple)..., k=3)

        len_denser = length(tmprtrs) * denser_factor
        tp_denser = Array(colon(
            min_tp,
            whole_tp_span / (len_denser - 1),
            max_tp
        )) # DataArray format doesn't work for `derivative` by "Dierckx"
        len_denser = length(tp_denser) # prevent discrepancy between len_denser and length(tp_denser) possibly caused by rounding errors

        fluo_spl = spl(tp_denser)
        if smooth_fluo_spl
            fluo_spl = supsmu(tp_denser, fluo_spl, span_smooth)
        end
        fluo_spl_blsub = fluo_spl - minimum(fluo_spl) # assuming baseline is a constant == minimum fluorescence value

        ndrv = -derivative(spl, tp_denser) #  derivative(splin ::Dierckx.Spline1D, x ::Array{Float61, 1})
        ndrv_smu = supsmu(tp_denser, ndrv, span_smooth) # using default for the rest of `supsmu` parameters

        mc_denser = hcat(tp_denser, fluo_spl_blsub, ndrv_smu)
        mc_raw = mc_denser[1:denser_factor:len_denser, :]

        # end: fit cubic spline ...

        half_peak_span_tmprtr = peak_span_tmprtr / 2

        # find summit indices of Tm peaks in `ndrv`
        span_peaks_dp = Int(round(half_peak_span_tmprtr / (max_tp - min_tp) * length(tp_denser), 0)) # dp = data point
        # min_ns_vec = fill(minimum(ndrv_smu), span_peaks_dp) # ns = ndrv_smu
        # ns_wms = [min_ns_vec; ndrv_smu; min_ns_vec] # wms = with min values
        # summit_idc = find_mid_sumr_bysw(ns_wms, span_peaks_dp, maximum)
        # summit_idc = find(1:len_denser) do i
        #     ndrv_iw = ns_wms[i : i + span_peaks_dp * 2] # iw = in window
        #     return maximum(ndrv_iw) == ndrv_iw[span_peaks_dp + 1]
        # end # do i

        # # calculate peak area
        # Tms = tp_denser[summit_idc]
        # len_Tms = length(Tms)
        # Ta_raw = vcat(map(Tms) do Tm # Ta = Tm_area
        #     a_idc_bool = map(tp_denser) do tp
        #         Tm - half_peak_span_tmprtr < tp < Tm + half_peak_span_tmprtr
        #     end
        #     a_idc_int = (1:len_denser)[a_idc_bool]
        #     base_end_idc = [a_idc_int[1], a_idc_int[end]]
        #     tp_denser_bes = tp_denser[base_end_idc] # be = base_end
        #     ndrv_bes = ndrv[base_end_idc]
        #     # baseline_coefs = *(inv([ones(2) tp_denser_bes]), ndrv_bes) # coefficients (solved by linear algebra) for baseline (the line connecting the two ends of curve -df/dT against temperature)
        #     # baseline = *([ones(length(a_idc_int)) tp_denser[a_idc_int]], baseline_coefs)
        #     area = spl(tp_denser_bes[1]) - spl(tp_denser_bes[2])    - sum(ndrv_bes) * (tp_denser_bes[2] - tp_denser_bes[1]) / 2
        #     #      integrated -df/dT peak area elevated from x-axis - trapezium-shaped baseline area elevlated from x-axis == peak area elevated from baseline (pa)
        #     # pa_vec[i] = OrderedDict("Tm"=>Tm, "pa"=>pa)
        #     return round.([Tm area], json_digits)
        # end...) # do Tm

        summit_idc_pre, nadir_idc = map([maximum, minimum]) do sumr_func
            find_mid_sumr_bysw(ndrv_smu, span_peaks_dp, sumr_func)
        end
        summit_idc = summit_idc_pre[map(summit_idc_pre) do summit_idc_pre
            summit_idc_pre > minimum(nadir_idc) && summit_idc_pre < maximum(nadir_idc)
        end]

        sn_dict = OrderedDict( # sn = summit nadir
            "summit_pre" => mc_denser[summit_idc_pre, :],
            "nadir" => mc_denser[nadir_idc, :]
        )


        Ta_raw_wdup = vcat(map(summit_idc) do summit_idx

            Tm = tp_denser[summit_idx]

            left_nadir_idx = maximum(nadir_idc[nadir_idc .< summit_idx])
            right_nadir_idx = minimum(nadir_idc[nadir_idc .> summit_idx])
            nadir_vec = [left_nadir_idx, right_nadir_idx]
            low_nadir_idx, high_nadir_idx = map(func -> nadir_vec[func(ndrv_smu[nadir_vec])[2]], [findmin, findmax])
            hn_ns = ndrv_smu[high_nadir_idx]

            # find the nearest location to `summit_idx` where line `ndrv = ndrv_smu[high_nadir_idx]`` is crossed by `ndrv_smu` curve
            idx_lb, idx_ub = map(func -> func([summit_idx, low_nadir_idx]), [minimum, maximum])
            idx_step = -1 + 2 * (summit_idx < low_nadir_idx)
            about2cross_idx = low_nadir_idx - idx_step # peak slightly narrower than using actual crossing point
            for idx in colon(summit_idx, idx_step, low_nadir_idx - 2 * idx_step)
                if ndrv_smu[idx] >= hn_ns && ndrv_smu[idx + idx_step] <= hn_ns
                    about2cross_idx = idx
                    break
                end # if
            end # for
            peak_bound_idc = [high_nadir_idx, about2cross_idx]

            # calculate peak area
            tp_low_end, tp_high_end = map(func -> func(tp_denser[peak_bound_idc]), [minimum, maximum])
            area = -(spl(tp_high_end) - spl(tp_low_end))            - sum(ndrv_smu[peak_bound_idc]) * (tp_high_end - tp_low_end) / 2
            #      integrated -df/dT peak area elevated from x-axis - trapezium-shaped baseline area elevlated from x-axis == peak area elevated from baseline (pa)

            # pa_vec[i] = OrderedDict("Tm"=>Tm, "pa"=>pa)
            return round.([Tm area], json_digits)

        end...) # do summit_idx


        summit_ii_grps = map(1:length(nadir_idc)-1) do nadir_ii
            find(summit_idc) do summit_idx
                summit_idx > nadir_idc[nadir_ii] && summit_idx < nadir_idc[nadir_ii + 1]
            end # do summit_idx
        end # do nadir_ii

        Ta_raw = vcat(map(summit_ii_grps) do summit_ii_grp
            if length(summit_ii_grp) == 0
                real_summit_ii_range = 1:0
            else
                real_summit_ii = summit_ii_grp[findmax(ndrv_smu[summit_idc[summit_ii_grp]])[2]]
                real_summit_ii_range = real_summit_ii:real_summit_ii
            end # if
            return Ta_raw_wdup[real_summit_ii_range, :]
        end...) # do summit_ii_grp

        len_Tms = size(Ta_raw)[1]

        if len_Tms == 0
            Ta_raw = EMPTY_Ta # otherwise `Ta_raw` will be an `Array{Any,1}`
        end


        # filter in real Tm peaks and out those due to random fluctuation. fltd = filtered


        ns_range_mid = mean([quantile(ndrv_smu, qt_prob_range_lb), maximum(ndrv_smu)])
        num_cross_points = sum(map(1:(len_denser-1)) do i
            (ndrv_smu[i] - ns_range_mid) * (ndrv_smu[i+1] - ns_range_mid) <= 0
        end) # do i

        larger_normd_qtv_of_two_sides = NaN
        top1_from_max = NaN
        tmprtr_max_ndrv = tp_denser[findmax(ndrv_smu)[2]]
        area_report_lb = NaN
        area_topNp1 = NaN
        # smallest_abs_area_within_topNp1 = NaN
        mc_slope = linreg(tmprtrs, fluos)[2]

        Ta_fltd = EMPTY_Ta # 0x2 Array. On another note, 2x0 Array `Ta_raw[:, 1:0]` raised error upon `json`.
        Ta_reported = "No"

        if len_Tms > 0

            # larger_normd_qtv_of_two_sides
            areas_raw = Ta_raw[:, end]
            abs_areas_raw = abs.(areas_raw)
            ndrv_normd = (ndrv - minimum(ndrv)) / (maximum(ndrv) - minimum(ndrv))
            top1_Tm_idx = summit_idc[indmax(areas_raw)]
            larger_normd_qtv_of_two_sides = maximum(
                map((1:top1_Tm_idx, top1_Tm_idx:len_denser)) do idc
                    quantile(ndrv_normd[idc], qt_prob_flTm)
                end
            )

            # top1_from_max
            top1_from_max = abs(tp_denser[top1_Tm_idx] - tmprtr_max_ndrv)

            seq_topNp1 = 1 : min(top_N+1, len_Tms)

            # idc_topNp1, area_report_lb
            idc_sb_area = sortperm(areas_raw, rev=true) # idc_sb = indice sorted by
            idc_topNp1 = idc_sb_area[seq_topNp1]
            area_topNp1 = areas_raw[idc_topNp1[end]]
            area_report_lb = areas_raw[idc_topNp1[1]] * frac_report_lb

            # # absolute areas
            # idc_sb_abs_area = sortperm(abs_areas_raw, rev=true)
            # idc_abs_topNp1 = idc_sb_abs_area[seq_topNp1]
            # smallest_abs_area_within_topNp1 = top_N+1 <= len_Tms ? abs_areas_raw[idc_abs_topNp1[end]] : 0

            # reporting
            if (
                num_cross_points <= min(ncp_ub, len_raw * noisy_factor) &&
                larger_normd_qtv_of_two_sides <= normd_qtv_ub &&
                # top1_from_max <= top1_from_max_ub && # disabled because it caused false suppression of Tm peak reporting for `db_name_ = "20160309_chaipcr"; exp_id_ = 7`, well A2. Needs to be enabled because it is the only criterion that suppress false reporting of not-real peaks in `db_name_ = "20161103_chaipcr_ip152"; exp_id_ = 45`, well A1
                mc_slope < 0
                )

                fltd_idc = find(idc_topNp1) do idx
                    areas_raw[idx] >= area_report_lb
                end # do idx

                if length(fltd_idc) <= top_N # When all the Tm peaks are noises, no peak is expected to have a substantially larger area than the other peaks. This can be observed as `area_topNp1 >= area_report_lb`, and thus `length(fltd_idc) > top_N`
                # if smallest_abs_area_within_topNp1 < area_report_lb # When all the Tm peaks are noises, no peak is expected to have a substantially larger area than the other peaks; and absolute values of negative peak areas should not be much smaller than top-1 peak area.
                    Ta_fltd = Ta_raw[idc_topNp1[fltd_idc], :]
                    Ta_reported = "Yes"
                end # if length

            end # if (

        end # if len_Tms > 0

    end # if shorter_length_raw <= 3 ... else

    mc = round.(mc_raw, json_digits)

    return MeltCurveTa(
        mc,
        Ta_fltd,
        mc_denser,
        ns_range_mid,
        sn_dict,
        Ta_raw[idc_sb_area, :],
        join([
            "$Ta_reported. All of the following statements must be true for Tm to be reported",
            "The number of data points $num_cross_points crossing the middle point of the range of -df/dt ($ns_range_mid) is less than or equal to ncp_ub $ncp_ub and noisy_factor $noisy_factor multiplied by len_raw $len_raw",
            "The larger normalized quantile value of the left and right sides of the summit on the negative derivative curve $larger_normd_qtv_of_two_sides <= `normd_qtv_ub` $normd_qtv_ub",
            # "The top-1 Tm peak is $(top1_from_max)C (need to be <= top1_from_max_ub $(top1_from_max_ub)C) away from maximum -df/dt temperature $tmprtr_max_ndrv",
            "Has $len_Tms no more than $top_N (top_N) raw_tm peaks, or the top-$(top_N+1) (top_N+1) peak has an area $area_topNp1 < $area_report_lb ($frac_report_lb of the top-1 peak)", # ", or the peak with smallest absolute area within top-$(top_N+1) (top_N+1) has an absolute area $smallest_abs_area_within_topNp1 < $area_report_lb ($frac_report_lb of the top-1 peak)",
            "The slope of the straight line fit to the melt curve $mc_slope < 0."
        ], ". \n- ")
    )

end # mc_tm_pw




#
