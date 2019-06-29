## meltcrv.jl
#
## melt curve analysis

import DataStructures.OrderedDict
import DataArrays.DataArray
import StatsBase: rle
import Dierckx: Spline1D, derivative
import Base: start, next, done, eltype, collect, iteratorsize, SizeUnknown
import FunctionalData: @p, id
import Memento: debug, info, warn, error


## called by QpcrAnalyze.dispatch
function act(
    ::Val{meltcurve},
    req_dict    ::Associative;
    out_format  ::Symbol = :pre_json
)
    debug(logger, "at act(::Val{meltcurve})")

    ## calibration data is required    
    @unless(req_key(CALIBRATION_INFO_KEY) &&
        typeof(req_dict[CALIBRATION_INFO_KEY]) <: Associative,
            return fail(logger,
                        ArgumentError("no calibration information found"),
                        out_format))

    # kwdict_pmc = OrderedDict{Symbol,Any}()
    # for key in ["channel_nums"]
    #     if key in keys_req_dict
    #         kwdict_pmc[parse(key)] = req_dict[key]
    #     end
    # end
    const kwdict_mc_tm_pw = OrderedDict{Symbol,Any}(
        map(keys(MC_TM_PW_KEYWORDS)) do key
            key => req_dict[MC_TM_PW_KEYWORDS[key]]
        end) ## do key
    #
    ## pass call through to process_mc
    ## which will perform the analysis for the entire dataset
    const response =
        try process_mc(
                req_dict[RAW_DATA_KEY],
                req_dict[CALIBRATION_INFO_KEY];
                out_format = out_format,
                # kwdict_pmc...,
                kwdict_mc_tm_pw = kwdict_mc_tm_pw)
        catch err
            return fail(logger, err, out_format; bt=true)
        end ## try
    return (out_format == :json) ? JSON.json(response) : response
end ## act()


## Top-level function: get melting curve data and Tm for a melt curve experiment
function process_mc(
    mc_data             ::Associative,
    calib_data          ::Associative;
    ## start: arguments that might be passed by upstream code
    well_nums           ::AbstractVector =[],
    auto_span_smooth    ::Bool =false,
    span_smooth_default ::Real =0.015,
    span_smooth_factor  ::Real =7.2,
    ## end: arguments that might be passed by upstream code
    dye_in              ::Symbol = :FAM,
    dyes_2bfild         ::AbstractVector =[],
    dcv                 ::Bool =true, ## logical, whether to perform multi-channel deconvolution
	max_tmprtr          ::Real =1000, ## maximum temperature to analyze
    out_format          ::Symbol = :pre_json, ## :full, :pre_json, :json
    kwdict_mc_tm_pw     ::Associative =OrderedDict() ## keyword arguments passed onto `mc_tm_pw`
)
    ## function: get raw melt curve data by channel and perform optical calibration
    function get_mc_data(channel_num ::Integer)

        ## subset melting curve data by channel (curried)
        select_mcdata_by_channel(channel_num ::Integer) =
            mc_data ::Associative ->
                Dict(
                    map([TEMPERATURE_KEY, FLUORESCENCE_VALUE_KEY, WELL_NUM_KEY]) do key
                        Symbol(key) => mc_data[key][mc_data[CHANNEL_KEY] .== channel_num]
                    end)

        ## split temperature and fluorescence data by well
        split_tf_by_well(fluo_sel ::Associative) =
            map(fluo_well_nums) do well_num
                Dict(
                    map(TF_KEYS) do key
                        key => fluo_sel[key][fluo_sel[:well_num] .== well_num]
                    end)
            end

        ## extend data vectors with NaN values where necessary to make them equal in length
        extend_tf_vecs(tf_dict_vec ::AbstractArray) =
            map(tf_dict_vec) do tf_dict
                Dict(
                    map(TF_KEYS) do key
                        key => extend_NaN(map(x -> length(x[:temperature]), tf_dict_vec) |> maximum)(tf_dict[key])
                    end)
            end

        ## convert to MeltCurveTF object
        toMeltCurveTF(tf_nv_adj ::AbstractArray) =
            MeltCurveTF(
                ## @p id tf_nv_adj | map index(:temperature)        | reduce hcat,
                ## @p id tf_nv_adj | map index(:fluorescence_value) | reduce hcat)
                map(TF_KEYS) do key
                    mapreduce(tf_dict -> tf_dict[key], hcat, tf_nv_adj)
                end...)
    ## end of function definitions nested in get_mc_data()

        mc_data |>
            select_mcdata_by_channel(channel_num) |>
            split_tf_by_well |>
            extend_tf_vecs |>
            toMeltCurveTF
    end ## get_mc_data

    normalize_tf(channel_i ::Integer, i ::Integer) =
        normalize_fluos(
            remove_when_NaN_in_first(
                mc_data_bych[channel_i].t_da[:, i],
                faw_ary3[:, i, channel_i])...)

    remove_when_NaN_in_first(x...) =
        map(y -> y[broadcast(!isnan, first(x))], x)

    normalize_fluos(
        tmprtrs     ::DataArray{S} where S <: AbstractFloat,
        fluos_raw   ::AbstractVector{T} where T <: Real) =
            Dict(
                :tmprtrs => tmprtrs,
                :fluos   => sweep(minimum)(-)(fluos_raw))
    ## end of function definitions nested in process_mc()

    debug(logger, "at process_mc()")
    const (channel_nums, fluo_well_nums) =
        map((CHANNEL_KEY, WELL_NUM_KEY)) do key
            mc_data[key] |> unique |> sort
        end ## do key
    const num_channels   = length(channel_nums)
    const num_fluo_wells = length(fluo_well_nums)
    #
    ## get data arrays by channel
    ## output is Vector{MeltCurveTF}
    const mc_data_bych  = map(get_mc_data, channel_nums)
    #
    ## reshape raw fluorescence data to 3-dimensional array
    ## dimensions 1,2,3 = temperature,well,channel
    ## `fr` - fluo_raw
    const fr_ary3       = cat(3, map(mc_data -> mc_data.fluo_da, mc_data_bych)...)
    #
    ## perform deconvolution and adjust well-to-well variation in absolute fluorescence
    const (mw_ary3, k4dcv, fdcvd_ary3, wva_data, wva_well_nums, faw_ary3) =
        dcv_aw(
            fr_ary3,
            num_channels == 1 ? false : dcv,
            channel_nums,
            calib_data,
            fluo_well_nums,
            dye_in,
            dyes_2bfild;
            aw_out_format = :array)
    #
    ## ignore dummy well_nums from dcv_aw
    const wva_well_nums_alt = fluo_well_nums
    #
    ## subset temperature/fluorescence data by channel then by well
    ## then smooth the fluorescence/temperature data and calculate Tm peak, area
    ## bychwl = by channel then by well_nums
    const mc_bychwl =
        mapreduce(
            channel_i ->
                map(wva_well_nums_alt) do oc_well_num
                    if oc_well_num in fluo_well_nums
                        mc_tm_pw(
                            normalize_tf(
                                channel_i,
                                indexin([oc_well_num], fluo_well_nums)[1]);
                            auto_span_smooth = auto_span_smooth,
                            span_smooth_default = span_smooth_default,
                            span_smooth_factor = span_smooth_factor,
                            kwdict_mc_tm_pw...)
                    else
                        EMPTY_mc_tm_pw_out
                    end ## if
                end, ## do oc_well_num
            hcat,
            range(1, num_channels))
    #
    if (out_format == :full)
        return MeltCurveOutput(
            mc_bychwl,
            channel_nums,
            fluo_well_nums,
            fr_ary3,
            mw_ary3,
            k4dcv,
            fdcvd_ary3,
            wva_data,
            wva_well_nums_alt,
            faw_ary3)
    else
        mc_out = OrderedDict{Symbol,Any}(map(keys(MC_OUT_FIELDS)) do f
            MC_OUT_FIELDS[f] =>
                [   (getfield(mc_bychwl[well_i, channel_i], f))
                    for well_i in range(1, num_fluo_wells), channel_i in range(1, num_channels) ]
        end) ## do f
        mc_out[:valid] = true
        return mc_out
    end ## if out_format
end ## process_mc()


## function: get melting curve data and Tm peaks for each well
function mc_tm_pw(
    #
    ## input data
    ## `tf` - temperature and fluorescence
    tf_dict             ::Associative;
    #
    ## The maximum fraction of median temperature interval to be considered narrow
    ## `nti` - narrow temperature interval
    nti_frac            ::AbstractFloat =0.05,
    #
    ## smoothing -df/dt curve and if `smooth_fluo`, fluorescence curve too
    auto_span_smooth    ::Bool =true,
    span_css_tmprtr     ::Real =1.0, ## css = choose `span_smooth`. fluorescence fluctuation with the temperature range of approximately `span_css_tmprtr * 2` is considered for choosing `span_smooth`
    span_smooth_default ::AbstractFloat =0.05, ## unit: fraction of data points for smoothing
    span_smooth_factor  ::Real =7.2,
    #
    ## get a denser temperature sequence to get fluorescence and -df/dt from it and fitted spline function
    denser_factor       ::Integer =10,
    smooth_fluo_spl     ::Bool =false,
    #
    ## identify Tm peaks and calculate peak area
    peak_span_tmprtr    ::Real =2.0, ## Within the smoothed -df/dt sequence spanning the temperature range of approximately `peak_span_tmprtr`, if the maximum -df/dt value equals that at the middle point of the sequence, identify this middle point as a peak summit. Similar to `span.peaks` in qpcR code. Combined with `peak_shoulder` (similar to `Tm.border` in qpcR code).
    ## peak_shoulder ::Real =1, ## 1/2 width of peak in temperature when calculating peak area  # consider changing from 1 to 2, or automatically determined (max and min d2)?
    #
    ## filter Tm peaks
    qt_prob_range_lb    ::AbstractFloat =0.21, ## quantile probability point for the lower bound of the range considered for number of crossing points
    ncp_ub              ::Integer =10, ## upper bound of number of data points crossing the mid range value (line parallel to x-axis) of smoothed -df/dt (`ndrv_smu`)
    noisy_factor        ::AbstractFloat =0.2, ## `num_cross_points` must also <= `noisy_factor * len_raw`
    qt_prob_flTm        ::AbstractFloat =0.64, ## quantile probability point for normalized -df/dT (range 0-1)
    normd_qtv_ub        ::AbstractFloat =0.8, ## upper bound of normalized -df/dt values (range 0-1) at the quantile probablity point
    top1_from_max_ub    ::Real =1.0, ## upper bound of temperature difference between top-1 Tm peak and maximum -df/dt
    top_N               ::Integer =4, ## top number of Tm peaks to report
    frac_report_lb      ::AbstractFloat =0.1, ## lower bound of area fraction of the Tm peak to be reported in regards to the largest real Tm peak
    #
    json_digits         ::Integer =JSON_DIGITS,
)
    ## functions to parse input data

    ## filter out data points separated by narrow temperature intervals
    ## `nti` - narrow temperature interval
    filter_nti(tf_dict ::Associative) =
        Dict(key => tf_dict[key][(tf_dict[:tmprtrs] |> tmprtr_intvls |> no_nti)]
            for key in keys(tf_dict))

    ## temperature intervals
    tmprtr_intvls(tmprtrs_ori ::DataArray{T,1} where T <: AbstractFloat) =
        vcat(diff(tmprtrs_ori), Inf)

    ## flag datapoints
    no_nti(tmprtr_intvls ::DataArray{T,1} where T <: AbstractFloat) =
        tmprtr_intvls .> nti_frac * median(tmprtr_intvls)

    ## functions used to calculate `span_smooth`

    ## choose the value for `span_smooth`
    choose_span_smooth() =
        if auto_span_smooth
            info(logger, "automatic selection of `span_smooth`...")
            calc_span_smooth(fu_rle())
        else
            info(logger, "no automatic selection, use span_smooth_default $span_smooth_default as `span_smooth`")
            span_smooth_default
        end ## if

    ## calculate the smoothing parameter
    function calc_span_smooth(fu_rle ::Tuple{Vector{Bool},Vector{T} where T <: Integer})

        larger_span(span_smooth_product ::Real) =
        if span_smooth_product > span_smooth_default
            info(logger, "`span_smooth` was selected as $span_smooth")
            return span_smooth_product(tmprtrs, fluos, fu_rle)
        else
            info(logger, "`span_smooth_product` $span_smooth_product < `span_smooth_default`, " *
                "use `span_smooth_default` $span_smooth_default")
            return span_smooth_default
        end ## if

        ## `span_smooth_product` = the longest temperature span
        ## where fluorescence increases as temperature increases
        span_smooth_product() =
            span_smooth_factor * max_fu_tp_span(fu_idc()) / whole_tp_span

        max_fu_tp_span(fu_idc ::AbstractVector{Int}) =
            maximum(tmprtrs[fu_idc[2:2:end]] .- tmprtrs[fu_idc[1:2:end]])

        fu_idc() =
            (cumsum(fu_rle[1][1] ? vcat(0,fu_rle[2]) : fu_rle[2]) .+ 1)[1:2*sum(fu_rle[1])]
        #
        ## end of function definitions nested within calc_span_smooth()

        if fu_rle[1] == [false]
            info(logger, "no fluo increase as temperature increase was detected: " *
                "using `span_smooth_default` $span_smooth_default")
            return span_smooth_default
        else
            info(logger, "fluorescence increase with temperature increase was detected")
            return larger_span(span_smooth_product())
        end ## if
    end ## calc_span_smooth()

    ## find the region(s) where there is a positive gradient
    ## such that fluorescence increases as the temperature increases
    ## `fu_rle` - fluo_up run length encoding
    fu_rle() = calc_fu_rle(giis_tp(max_fluo_dcrs()))

    calc_fu_rle(css_idc ::AbstractVector{Int}) =
        rle(is_increasing(fluos[css_idc]))

    ## find the region of length 2 * span_css_tmprtr
    ## showing the steepest fluo decrease (`fluo_dcrs`) between start and end
    max_fluo_dcrs() =
        indmax(
            fluo_dcrs(giis_tp(i))
            for i in 1:len_raw)

    fluo_dcrs(sel_idc_int ::AbstractVector{Int}) =
        fluos[sel_idc_int[1]] - fluos[sel_idc_int[end]]

    giis_tp(i ::Int) =
        giis_uneven(tmprtrs, i, span_css_tmprtr)

    ## smoothing functions

    ## fit cubic spline to fluos ~ tmprtrs using Dierckx
    ## default parameter s=0.0 interpolates without smoothing
    spline_model(x) = Spline1D(shorten(x)...; k=3)

    ## smooth raw fluo values
    smooth_raw_fluo() =
        (tmprtrs, supsmu(tmprtrs, fluos, span_smooth / denser_factor))

    ## fit cubic spline to fluos ~ tmprtrs, re-calculate fluorescence,
    ## and calculate -df/dt using `tp_denser` (a denser sequence of temperatures)
    smoothing_process() =
        hcat(
            ## collate processed, interpolated data into matrix
            ## note: memory intensive
            tp_denser,
            fluo_spl_blsub(spl(tp_denser)),
            ndrv_smu(-derivative(spl, tp_denser)))

    ## baseline-subtracted spline-smoothed fluorescence data
    fluo_spl_blsub(fluo_spl ::AbstractVector{T} where T <: AbstractFloat) =
        ## assumes constant baseline == minimum fluorescence value
        sweep(minimum)(-)(
            ## optionally, smooth the output of the spline function
            smooth_fluo_spl ?
                supsmu(tp_denser, fluo_spl, span_smooth) :
                fluo_spl)

    ## calculate negative derivative at interpolated temperatures
    ## smooth output using `supsmu`
    ndrv_smu(ndrv ::AbstractVector{T} where T <: AbstractFloat) =
        supsmu(tp_denser, ndrv, span_smooth)

    ## create denser array of interpolated temperature values
    ## note: DataArray format doesn't work for `derivative` by "Dierckx"
    interpolated_temperatures() =
        Array(colon(
            min_tp,
            whole_tp_span / (len_raw * denser_factor - 1),
            max_tp))

    ## peak finding functions

    ## `dp` - data point
    # half_peak_span_tmprtr = (peak_span_tmprtr / 2.0)
    span_peaks_dp() =
        Int(round(
            (peak_span_tmprtr / 2.0) / (max_tp - min_tp) * len_denser,
            0))

    ## find summit and nadir indices of Tm peaks in `ndrv_smu`
    find_sn() =
        map(x -> find_mid_sumr_bysw(ndrv_smu, span_peaks_dp(), x),
            [maximum, minimum])

    summits_and_nadirs(sn_idc...) =
        OrderedDict(
            zip([:summit_pre, :nadir],
                map(idc -> mc_denser[idc, :],
                    sn_idc)))

    function find_peaks(
        summit_pre_idc  ::AbstractVector{Int},
        nadir_idc       ::AbstractVector{Int}
    )
        const pi =
            PeakIndices(
                ndrv_smu[summit_pre_idc],
                summit_pre_idc,
                nadir_idc)
        # const Ta_raw = @p collect pi | map peak_Ta | filter thing
        # return thing(Ta_raw) ? Vector{Peak}(Ta_raw) : Peak([]) 
        Vector{Peak}(@p collect pi | map peak_Ta | filter thing)
    end ## find_peaks()

    ## calculate peak area
    peak_Ta(peak_idc ::Tuple{I, I, I} where I <: Integer) =
        peak_idc == nothing ?
            nothing :
            Peak(
                peak_idc[2],                                ## summit_idx
                tp_denser[peak_idc[2]],                     ## Tm = temperature at peak
                peak_bounds(peak_idc...) |> calc_area)      ## area

    ## find shoulders of peak
    function peak_bounds(
        left_nadir_idx  ::Integer,
        summit_idx      ::Integer,
        right_nadir_idx ::Integer
    )
        # nadir_vec = [left_nadir_idx, right_nadir_idx]
        # low_nadir_idx, high_nadir_idx = map(
        #     func -> nadir_vec[func(ndrv_smu[nadir_vec])[2]],
        #     [findmin, findmax])
        const (low_nadir_idx, high_nadir_idx) =
            (ndrv_smu[left_nadir_idx] < ndrv_smu[right_nadir_idx]) ?
                (left_nadir_idx, right_nadir_idx) :
                (right_nadir_idx, left_nadir_idx)
        const hn_ns = ndrv_smu[high_nadir_idx]
        #
        ## find the nearest location to `summit_idx`
        ## on the `low_nadir_idx` side of the peak
        ## where the line `ndrv = ndrv_smu[high_nadir_idx]`
        ## is crossed by the `ndrv_smu` curve
        idx_step = -1 + 2 * (summit_idx < low_nadir_idx)
        about2cross_idx = low_nadir_idx - idx_step ## peak slightly narrower than using actual crossing point
        idx = summit_idx
        ndrv_smu1 = ndrv_smu[summit_idx]
        limit_idx = low_nadir_idx - 2 * idx_step
        while (idx != limit_idx)
            ndrv_smu0 = ndrv_smu1
            idx1 = idx + idx_step
            ndrv_smu1 = ndrv_smu[idx1]
            if ndrv_smu1 <= hn_ns <= ndrv_smu0
                about2cross_idx = idx
                break
            end ## if
            idx = idx1
        end ## while
        return (high_nadir_idx, about2cross_idx)
    end ## peak_bounds()

    ## peak area elevated from baseline ==
    ## integrated -df/dT peak area elevated from x-axis -
    ## trapezium-shaped baseline area elevated from x-axis
    ## Issue: ??? function looks wrong, does not match R algorithm
    ## Proposed solution: recode using Dierckx.integrate
    ## requires tp_denser, ndrv_smu, ndrv ???
    function calc_area(peak_bound_idc ::Tuple{Integer, Integer})
        #
        area_func(tp_low_end ::Real, tp_high_end ::Real) =
            -sum(ndrv_smu[[peak_bound_idc...]]) * (tp_high_end - tp_low_end) / 2.0 -
                (spl(tp_high_end) - spl(tp_low_end))
        ## end of function definition nested in peak_area()

        # tp_low_end, tp_high_end = map(
        #     func -> func(tp_denser[peak_bound_idc]),
        #     [minimum, maximum])
        return area_func(ordered_tuple(tp_denser[[peak_bound_idc...]]...)...)
    end ## calc_area()

    ## count cross points
    function count_cross_points()
        ## vectorized version
        # num_cross_points = sum(map(1:(len_denser-1)) do i
        #     (ndrv_smu[i] - ns_range_mid) * (ndrv_smu[i+1] - ns_range_mid) <= 0
        # end)
        #
        ## devectorized version
        num_cross_points = 0
        ndrv_smu_centred1 = sign(ndrv_smu[1] - ns_range_mid)
        i = 0
        while (i < len_denser)
            i += 1
            ndrv_smu_centred0 = ndrv_smu_centred1
            ndrv_smu_centred1 = sign(ndrv_smu[i] - ns_range_mid)
            @when(ndrv_smu_centred0 != ndrv_smu_centred1,
                num_cross_points += 1)
        end ## while
        return num_cross_points
    end ## count_cross_points()
    #
    ## filter in real Tm peaks and out those due to random fluctuation
    ## `fltd` - filtered
    ## note: top1_Tm_idx calculated incorrectly in original code
    function real_peaks(
        tmprtr_max_ndrv     ::AbstractFloat,
        areas_raw           ::AbstractVector{F} where F <: AbstractFloat,
        top1_Tm_idx         ::Integer,
        fn_mc_slope         ::Function,         ## linear regression fluos ~ tmprtrs
        fn_num_cross_points ::Function
    )
        top_peaks(fltd_idc_topNp1 ::AbstractVector{I} where I <: Integer) =
            length(fltd_idc_topNp1) > top_N ? [] : fltd_idc_topNp1

        if  (split_vector_and_return_larger_quantile(
                normalize_range(ndrv_smu), ## originally normalize_range(ndrv), but why ???
                len_denser,
                top1_Tm_idx, ## index of peak with largest area
                qt_prob_flTm) ## larger_normd_qtv_of_two_sides
                    > normd_qtv_ub) ||
            (fn_num_cross_points() > min(ncp_ub, len_raw * noisy_factor)) ||
            (fn_mc_slope() >= 0.0)
            return []
        end ## if
        ## else
        #
        ## Disabled because it caused false suppression of Tm peak reporting for
        ## `db_name_ = "20160309_chaipcr"; exp_id_ = 7`, well A2.
        ## Needs to be enabled because it is the only criterion that
        ## suppress false reporting of not-real peaks in
        ## `db_name_ = "20161103_chaipcr_ip152"; exp_id_ = 45`, well A1
        # top1_Tm_idx = summit_idc[indmax(areas_raw)] ## peak with largest area
        # top1_from_max = abs(tp_denser[top1_Tm_idx] - tmprtr_max_ndrv)
        # if (top1_from_max > top1_from_max_ub)
        #     return EMPTY_Ta
        # end
        #
        ## original code (equivalent to below):
        # seq_topNp1 = range(1, min(top_N+1, len_Tms))
        # idc_topNp1 = idc_sb_area[seq_topNp1]
        # area_report_lb = areas_raw[idc_topNp1[1]] * frac_report_lb
        # fltd_idc = find(idc_topNp1) do idx
        #     areas_raw[idx] >= area_report_lb
        # end
        # if length(fltd_idc) > top_N
        #    return EMPTY_Ta
        # end
        # return Ta_raw[idc_topNp1[fltd_idc], :]
        #
        ## when all the Tm peaks are noises, no peak is expected
        ## to have a substantially larger area than the other peaks.
        ## Provided `top_N+1 <= len_Tms`, this is observed as
        ## `areas_raw[idc_sb_area[top_N+1]] >= area_report_lb`
        ## implying `length(fltd_idc_topNp1) > top_N`
        return top_peaks(
            filter(
                idx -> areas_raw[idx] >= areas_raw[idc_sb_area[1]] * frac_report_lb,
                idc_sb_area[range(1, min(top_N+1, len_Tms))]))
    end ## real_peaks()
    #
    ## end of function definitions nested in mc_tm_pw()

    debug(logger, "at mc_tm_pw()")
    ## filter out data points separated by narrow temperature intervals
    ## `nti` - narrow temperature interval
    const (tmprtrs, fluos) =
        tf_dict |> filter_nti |> tf -> (mutate_dups(tf[:tmprtrs]), tf[:fluos])
    const len_raw = length(tmprtrs)
    #
    ## negative derivative by central finite differencing (cfd)
    ## only used if the data array is too short to find peaks
    if (len_raw <= 3)
        const slope = finite_diff(tmprtrs, fluos; nu = 1, method = :central)
        return MeltCurveTa(
            report(json_digits,
                hcat(tmprtrs, fluos, -slope)),  ## mc_raw
            EMPTY_Ta,                           ## Ta_fltd
            EMPTY_mc,                           ## mc_denser
            NaN,                                ## ns_range_mid
            Dict(
                :tmprtrs => EMPTY_Ta,
                :fluos   => EMPTY_Ta),          ## sn_dict
            EMPTY_Ta,                           ## Ta_raw
            :No                                 ## Ta_reported
        )
    end ## if
    #
    ## else
    const min_tp        = minimum(tmprtrs)
    const max_tp        = maximum(tmprtrs)
    const whole_tp_span = max_tp - min_tp
    #
    ## choose smoothing parameter
    const span_smooth   = choose_span_smooth()
    #
    ## fit a cubic spline model in order to interpolate data points
    ## then smooth data and calculate slope at denser sequence of temperatures
    const spl           = spline_model(smooth_raw_fluo())
    const tp_denser     = interpolated_temperatures()
    const mc_denser     = smoothing_process()
    const ndrv_smu      = mc_denser[:,3]
    const max_ndrv_smu  = findmax(ndrv_smu)
    const ns_range_mid  = mean([quantile(ndrv_smu, qt_prob_range_lb), max_ndrv_smu[1]])
    #
    ## extract data at observed temperatures
    const len_denser    = length(tp_denser)
    const mc_raw        = mc_denser[1:denser_factor:len_denser, :]
    #
    ## find peak and trough locations
    ## `sn` - summits and nadirs
    const sn_idc        = find_sn()
    const sn_dict       = summits_and_nadirs(sn_idc...)
    #
    ## estimate area of peaks above baseline
    const Ta_raw        = find_peaks(sn_idc...)
    const len_Tms       = length(Ta_raw)
    #
    ## return smoothed data if no peaks
    if (len_Tms == 0)
        return MeltCurveTa(
            report(json_digits, mc_raw),
            EMPTY_Ta,   ## Ta_fltd
            mc_denser,
            ns_range_mid,
            sn_dict,
            EMPTY_Ta,   ## Ta_raw
            :No)
    end ## if
    #
    ## else
    ## peak indices sorted by area
    ## `idc_sb` - indices sorted by
    const idc_sb_area = sortperm(map(p -> p.area, Ta_raw), rev=true)
    #
    ## keep only the biggest peak(s)
    ## passes functions instead of values for mc_slope & num_cross_points
    ## so that the values are only calculated if needed
    ## `fltd` - filtered
    # const Ta_fltd_ind =
    #     real_peaks(
    #         tp_denser[max_ndrv_smu[2]],         ## tmprtr_max_ndrv
    #         map(x -> x.area, Ta_raw),           ## areas_raw
    #         Ta_raw[idc_sb_area[1]].idx,         ## idx of peak with largest area
    #         () -> linreg(tmprtrs, fluos)[2],    ## () -> mc_slope
    #         count_cross_points)                 ## () -> num_cross_points
    # const Ta_fltd = length(Ta_fltd_ind) > 0 ? Ta_raw[Ta_fltd_ind] : Peak([])
    const Ta_fltd =
        Ta_raw[ 
            real_peaks(
                tp_denser[max_ndrv_smu[2]],         ## tmprtr_max_ndrv
                map(p -> p.area, Ta_raw),           ## areas_raw
                Ta_raw[idc_sb_area[1]].idx,         ## idx of peak with largest area
                () -> linreg(tmprtrs, fluos)[2],    ## () -> mc_slope
                count_cross_points)]                ## () -> num_cross_points
    #
    return MeltCurveTa(
        report(json_digits, mc_raw),
        report(json_digits, Ta_fltd),
        mc_denser,          ## do we want to round this to json_digits as well?
        ns_range_mid,
        sn_dict,
        report(json_digits, Ta_raw[idc_sb_area]),
        length(Ta_fltd) == 0 ? :No : :Yes)
end ## mc_tm_pw()

## functions called by mc_tm_pw()

## jitter duplicated elements in a numeric vector
## so that all the elements become unique
## used to eliminate duplicate values in temperature data
function mutate_dups(
    vec_2mut ::AbstractVector,
    frac2add ::Real =0.01
)
    debug(logger, "at mutate_dups()")
    const vec_len       = vec_2mut |> length
    const vec_uniq      = vec_2mut |> unique |> sort
    const vec_uniq_len  = vec_uniq |> length
    #
    ## return if no ties
    @when (vec_len == vec_uniq_len) return vec_2mut
    #
    ## find ties
    const order_to = sortperm(vec_2mut)
    const order_back = sortperm(order_to)
    vec_sorted = (vec_2mut + 0.0)[order_to]
    const dups = find(diff(vec_sorted) .== 0.0) .+ 1
    #
    ## calculate value of jitter constant
    const add1 = frac2add * median(diff(vec_uniq))
    #
    ## break ties
    accumulator1 = 0
    accumulator2 = 0
    for i in range(1, length(dups)) 
        multiway_tie  = i > 1 && dups[i] - dups[i-1] == 1
        accumulator1 += multiway_tie
        accumulator2  = multiway_tie ? accumulator2 : accumulator1
        rank = accumulator1 - accumulator2 + 1
        vec_sorted[dups[i]] += add1 * rank
    end
    #
    return vec_sorted[order_back]
end ## mutate_dups

## finite differencing function
function finite_diff(
    X       ::AbstractVector,
    Y       ::AbstractVector; ## X and Y must be of same length
    nu      ::Integer =1, ## order of derivative
    method  ::Symbol = :central
)
    debug(logger, "at finite_diff()")
    const dlen = length(X)
    if dlen != length(Y)
        throw(DimensionError, "X and Y must be of same length")
    end ## if
    @when dlen == 1 return zeros(1)
    if (nu == 1)
        const (range1, range2) =
            if      (method == :central)  tuple(3:dlen+2, 1:dlen)
            elseif  (method == :forward)  tuple(3:dlen+2, 1:dlen+1)
            elseif  (method == :backward) tuple(2:dlen+1, 1:dlen)
            else
                throw(ArgmentError, "method \"$method\" not recognized")
            end ## if
        const (X_p2, Y_p2) = map((X, Y)) do ori
            vcat(
                ori[2] * 2 - ori[1],
                ori,
                ori[dlen-1] * 2 - ori[dlen])
            end ## do ori
        return (Y_p2[range1] .- Y_p2[range2]) ./ (X_p2[range1] .- X_p2[range2])
    end ## nu == 1
    return finite_diff(
        X,
        finite_diff(X, Y; nu = nu - 1, method = method),
        nu = 1;
        method = method)
end ## finite_diff()

## PeakIndices methods
## iterator functions to find peaks and flanking nadirs

Base.start(iter ::PeakIndices) = (0, 0, 0)

Base.done(iter ::PeakIndices, state) =
    state == nothing || state[1] > iter.len_summit_idc

Base.iteratorsize(::PeakIndices) = SizeUnknown()

Base.eltype(iter ::PeakIndices) = Tuple{Int, Int, Int}

Base.collect(iter ::PeakIndices) =
    [peak for peak in iter if thing(peak)]

function Base.next(iter ::PeakIndices, state ::Tuple{Int, Int, Int})
    ## fail if state == nothing
    @when state == nothing return (nothing, nothing)
    ## state != nothing
    left_nadir_ii, summit_ii, right_nadir_ii = state
    ## next summit
    while (summit_ii < iter.len_summit_idc)
        ## summit_ii < iter.len_summit_idc
        ## increment the summit index
        summit_ii += 1
        ## extend nadir range to the right
        while
            (right_nadir_ii < iter.len_nadir_idc)
                right_nadir_ii += 1
                (iter.summit_idc[summit_ii] < iter.nadir_idc[right_nadir_ii]) && break
        end
        ## decrease nadir range to the left, if possible
        while
            (left_nadir_ii < iter.len_nadir_idc) &&
            (iter.nadir_idc[left_nadir_ii + 1] < iter.summit_idc[summit_ii])
                left_nadir_ii += 1
        end
        ## if there is a nadir to the left, break out of loop
        @when left_nadir_ii > 0 break
        ## otherwise try the next summit
    end
    ## fail if no more summits or no flanking nadirs
    if  (summit_ii >= iter.len_summit_idc) ||
       !(iter.nadir_idc[left_nadir_ii] < iter.summit_idc[summit_ii] < iter.nadir_idc[right_nadir_ii])
            return (nothing, nothing)
    end
    ## find duplicate summits
    right_summit_ii = summit_ii
    while
        (right_summit_ii < iter.len_summit_idc) &&
        (iter.summit_idc[right_summit_ii + 1] < iter.nadir_idc[right_nadir_ii])
            right_summit_ii += 1
    end
    ## remove duplicate summits by choosing highest summit
    if right_summit_ii > summit_ii
        summit_ii = (iis -> iis[indmax(iter.summit_heights[iis])])(summit_ii:right_summit_ii)
    end
    ## return value
    ((iter.nadir_idc[left_nadir_ii], iter.summit_idc[summit_ii], iter.nadir_idc[right_nadir_ii]), ## element
        (left_nadir_ii, summit_ii, right_nadir_ii)) ## state
end ## next()

## report methods
report(digits ::Integer, x) = round.(x, digits)

## do not report indices for each peak, only Tm and area
report(digits ::Integer, p ::Peak) =
    round.([p.Tm, p.area], digits) |> transpose

report(digits ::Integer, peaks ::Vector{Peak}) =
    length(peaks) == 0 ?
        EMPTY_Ta :
        mapreduce(p -> round.([p.Tm, p.area], digits),
            hcat,
            peaks) |> transpose

#
