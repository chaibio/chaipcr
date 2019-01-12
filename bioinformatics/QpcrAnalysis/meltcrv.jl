# melt curve analysis

import DataStructures.OrderedDict
import DataArrays.DataArray
import StatsBase: rle
import Dierckx: Spline1D, derivative


# called by QpcrAnalyze.dispatch
function act(
    ::MeltCurve,
    req_dict ::Associative;
    out_format ::String ="pre_json",
    verbose ::Bool =false
)
    # remove MySql dependency
    #
    # exp_id = req_dict["experiment_id"]
    # stage_id = req_dict["stage_id"]

    # kwdict_pmc = OrderedDict{Symbol,Any}()
    # for key in ["channel_nums"]
    #     if key in keys_req_dict
    #         kwdict_pmc[parse(key)] = req_dict[key]
    #     end
    # end

    const keys_req_dict = keys(req_dict)
    kwdict_mc_tm_pw = OrderedDict{Symbol,Any}()
    if "qt_prob" in keys_req_dict
        kwdict_mc_tm_pw[:qt_prob_flTm] = req_dict["qt_prob"]
    end
    if "max_normd_qtv" in keys_req_dict
        kwdict_mc_tm_pw[:normd_qtv_ub] = req_dict["max_normd_qtv"]
    end
    for key in ["top_N"]
        if key in keys_req_dict
            kwdict_mc_tm_pw[Symbol(key)] = req_dict[key]
        end
    end
    
    # pass call through to process_mc
    # which will perform the analysis for the entire dataset
    return process_mc(
        
        ## remove MySql dependency
        #
        # db_conn,
        # exp_id,
        # stage_id,
        # calib_info;

        # new >>
        req_dict["raw_data"],
        req_dict["calibration_info"];
        out_format=Symbol(out_format),
        verbose=verbose,
        # << new

        # kwdict_pmc...,
        kwdict_mc_tm_pw=kwdict_mc_tm_pw
    )
end # act()


# Top-level function: get melting curve data and Tm for a melt curve experiment
function process_mc(

    # remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # stage_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict};

    # new >>
    mc_data ::Associative,
    calib_data ::Associative;
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
    out_format ::Symbol =:pre_json, # :full, :pre_json, :json
    verbose ::Bool =false,
    kwdict_mc_tm_pw ::Associative =OrderedDict() # keyword arguments passed onto `mc_tm_pw`
)
    # function: get raw melt curve data by channel and perform optical calibration
    function get_mc_data(channel_num ::Integer)

        # subset melting curve data by channel (curried)
        select_mcdata_by_channel(channel_num ::Integer) = 
            mc_data ::Associative ->
                Dict(
                     Symbol(key) => mc_data[key][mc_data["channel"] .== channel_num]
                     for key in ["temperature","fluorescence_value","well_num"])

        # split temperature and fluorescence data by well
        split_tf_by_well(fluo_sel ::Associative) =
            map(fluo_well_nums) do well_num
                Dict(
                    key => fluo_sel[key][fluo_sel[:well_num] .== well_num]
                    for key in [:temperature, :fluorescence_value])
            end

        # extend data vectors with NaN values where necessary to make them equal in length
        extend_tf_vecs(tf_dict_vec ::AbstractArray) =
            map(tf_dict_vec) do tf_dict
                Dict(
                    key => extend_NaN(
                        tf_dict_vec |> map[(length ∘ index)[:temperature]] |> maximum,
                        tf_dict[key])
                    for key in [:temperature, :fluorescence_value])
            end

        # convert to MeltCurveTF object
        toMeltCurveTF(tf_nv_adj ::AbstractArray) =
            MeltCurveTF(
                tf_nv_adj |> map[index[:temperature]]        |> reduce[hcat],
                tf_nv_adj |> map[index[:fluorescence_value]] |> reduce[hcat])

    # end of function definitions nested in get_mc_data()

        mc_data |>
            select_mcdata_by_channel(channel_num) |>
            split_tf_by_well |>
            extend_tf_vecs |>
            toMeltCurveTF
    end # get_mc_data

    normalize_tf(channel_i ::Integer, i ::Integer) =
        normalize_fluos(
            remove_when_NaN_in_first(
                mc_data_bych[channel_i].t_da_vec[:,i],
                faw_ary3[:,i,channel_i])...)

    remove_when_NaN_in_first(x...) =
        map(y -> y[(x |> first |> broadcast[!isnan])],x)

    normalize_fluos(tmprtrs ::AbstractVector, fluos_raw ::AbstractVector) =
        Dict(
            :tmprtrs => tmprtrs,
            :fluos   => subtract_minimum(fluos_raw))

    # end of function definitions nested in process_mc()

    const channel_nums   = sort(unique(mc_data["channel"]))
    const num_channels   = length(channel_nums)
    const fluo_well_nums = sort(unique(mc_data["well_num"]))
    const num_fluo_wells = length(fluo_well_nums)

    # get data arrays by channel
    # output is Vector{MeltCurveTF}
    const mc_data_bych  = map(get_mc_data, channel_nums)

    # reshape raw fluorescence data to 3-dimensional array
    # dimensions 1,2,3 = temperature,well,channel
    # `fr` - fluo_raw
    const fr_ary3       = cat(3, map(mc_data -> mc_data.fluo_da, mc_data_bych)...)

    # perform deconvolution and adjust well-to-well variation in absolute fluorescence
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

    # ignore dummy well_nums from dcv_aw
    const wva_well_nums_alt = fluo_well_nums

    # subset temperature/fluorescence data by channel then by well
    # then smooth the fluorescence/temperature data and calculate Tm peak, area
    # bychwl = by channel then by well_nums
    const mc_bychwl = map(1:num_channels) do channel_i
        map(wva_well_nums_alt) do oc_well_num
            if oc_well_num in fluo_well_nums
                mc_tm_pw(
                    normalize_tf(
                        channel_i,
                        indexin([oc_well_num], fluo_well_nums)[1]);
                    auto_span_smooth = auto_span_smooth,
                    span_smooth_default = span_smooth_default,
                    span_smooth_factor = span_smooth_factor,
                    verbose = verbose,
                    kwdict_mc_tm_pw...
                )
            else
                EMPTY_mc_tm_pw_out
            end
        end
    end |> reduce[hcat]

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
            faw_ary3
        )
    else
        mc_out = OrderedDict{String,Any}(map(keys(MC_FIELDS)) do f
            MC_FIELDS[f] => [
                getfield(mc_bychwl[well_i, channel_i], f)
                for well_i in 1:num_fluo_wells, channel_i in 1:num_channels]
        end)
        mc_out["valid"] = true
        return out_format == :json ? JSON.json(mc_out) : mc_out
    end # out_format
end # process_mc()


# function: get melting curve data and Tm peaks for each well
function mc_tm_pw(

    # input data
    # `tf` - temperature and fluorescence
    tf_dict ::Associative;

    # The maximum fraction of median temperature interval to be considered narrow
    # `nti` - narrow temperature interval
    nti_frac ::AbstractFloat =0.05,

    # smoothing -df/dt curve and if `smooth_fluo`, fluorescence curve too
    auto_span_smooth ::Bool =true,
    span_css_tmprtr ::Real =1.0, # css = choose `span_smooth`. fluorescence fluctuation with the temperature range of approximately `span_css_tmprtr * 2` is considered for choosing `span_smooth`
    span_smooth_default ::AbstractFloat =0.05, # unit: fraction of data points for smoothing
    span_smooth_factor ::Real =7.2,

    # get a denser temperature sequence to get fluorescence and -df/dt from it and fitted spline function
    denser_factor ::Integer =10,
    smooth_fluo_spl ::Bool =false,

    # identify Tm peaks and calculate peak area
    peak_span_tmprtr ::Real =2.0, # Within the smoothed -df/dt sequence spanning the temperature range of approximately `peak_span_tmprtr`, if the maximum -df/dt value equals that at the middle point of the sequence, identify this middle point as a peak summit. Similar to `span.peaks` in qpcR code. Combined with `peak_shoulder` (similar to `Tm.border` in qpcR code).
    # peak_shoulder ::Real =1, # 1/2 width of peak in temperature when calculating peak area  # consider changing from 1 to 2, or automatically determined (max and min d2)?

    # filter Tm peaks
    qt_prob_range_lb ::AbstractFloat =0.21, # quantile probability point for the lower bound of the range considered for number of crossing points
    ncp_ub ::Integer =10, # upper bound of number of data points crossing the mid range value (line parallel to x-axis) of smoothed -df/dt (`ndrv_smu`)
    noisy_factor ::AbstractFloat =0.2, # `num_cross_points` must also <= `noisy_factor * len_raw`
    qt_prob_flTm ::AbstractFloat =0.64, # quantile probability point for normalized -df/dT (range 0-1)
    normd_qtv_ub ::AbstractFloat =0.8, # upper bound of normalized -df/dt values (range 0-1) at the quantile probablity point
    top1_from_max_ub ::Real =1.0, # upper bound of temperature difference between top-1 Tm peak and maximum -df/dt
    top_N ::Integer =4, # top number of Tm peaks to report
    frac_report_lb ::AbstractFloat =0.1, # lower bound of area fraction of the Tm peak to be reported in regards to the largest real Tm peak

    json_digits ::Integer =JSON_DIGITS,

    verbose ::Bool =false,
)
    # functions to parse input data

    # filter out data points separated by narrow temperature intervals
    # `nti` - narrow temperature interval
    filter_nti(tf_dict ::Associative) =
        Dict(
            key => (key == :tmprtrs ? mutate_dups : identity)(
                tf_dict[key][(
                    tf_dict[:tmprtrs] |>
                    tmprtr_intvls |>
                    no_nti)])
            for key in keys(tf_dict))

    # temperature intervals
    tmprtr_intvls(tmprtrs_ori ::AbstractVector) =
        vcat(diff(tmprtrs_ori), Inf)

    # flag datapoints
    no_nti(tmprtr_intvls ::AbstractVector) =
        tmprtr_intvls .> nti_frac * median(tmprtr_intvls)

    # functions used to calculate `span_smooth`

    # choose the value for `span_smooth`
    choose_span_smooth() =
        if auto_span_smooth
            print_v(println, verbose, "Automatic selection of `span_smooth`...")
            calc_span_smooth(fu_rle())
        else
            print_v(println, verbose, "No automatic selection, use span_smooth_default $span_smooth_default as `span_smooth`.")
            span_smooth_default
        end

    # calculate the smoothing parameter
    function calc_span_smooth(
        fu_rle ::Tuple{Vector{Bool},Vector{T} where T<:Integer}
    )
        larger_span(span_smooth_product ::Real) =
            if span_smooth_product > span_smooth_default
                print_v(println, verbose, "`span_smooth` was selected as $span_smooth.")
                return span_smooth_product
            else
                print_v(println, verbose, "`span_smooth_product` $span_smooth_product < `span_smooth_default`, use `span_smooth_default` $span_smooth_default.")
                return span_smooth_default
            end

        # calculate the longest temperature span
        # where fluorescence increases as temperature increases
        span_smooth_product() =
            span_smooth_factor * max_fu_tp_span(fu_idc()) / whole_tp_span

        fu_idc() =
            (cumsum(fu_rle[1][1] ? vcat(0,fu_rle[2]) : fu_rle[2]) .+ 1)[1:2*sum(fu_rle[1])]

        max_fu_tp_span(fu_idc ::AbstractVector) =
            maximum(tmprtrs[fu_idc[2:2:end]] .- tmprtrs[fu_idc[1:2:end]])

        # end of function definitions nested in auto_span_smooth()

        if fu_rle[1] == [false]
            print_v(println, verbose, "No fluo increase as temperature increase was detected, use `span_smooth_default` $span_smooth_default.")
            return span_smooth_default
        else
            # println("Fluorescence increase with temperature increase was detected.")
            return larger_span(span_smooth_product())
        end
    end # auto_span_smooth()

    # find the region(s) where there is a positive gradient
    # such that fluorescence increases as the temperature increases
    # `fu_rle` - fluo_up run length encoding
    fu_rle() =
        calc_fu_rle(giis_tp(max_fluo_dcrs()))

    calc_fu_rle(css_idc ::AbstractVector) =
        rle(is_increasing(fluos[css_idc]))

    giis_tp(i ::Integer) =
        giis_uneven(tmprtrs, i, span_css_tmprtr)

    # find the region of length 2 * span_css_tmprtr
    # showing the steepest fluo decrease (`fluo_dcrs`) between start and end
    max_fluo_dcrs() =
        indmax(
            fluo_dcrs(giis_tp(i))
            for i in 1:len_raw)

    fluo_dcrs(sel_idc_int ::AbstractVector) =
        fluos[sel_idc_int[1]] - fluos[sel_idc_int[end]]

    # smoothing functions

    # fit cubic spline to fluos ~ tmprtrs using Dierckx
    # default parameter s=0.0 interpolates without smoothing
    spline_model(tf_array ::AbstractArray) =
        Spline1D(
            shorten(tf_array)...,
            k=3)

    # smooth raw fluo values
    smooth_raw_fluo() =
        # return value
        [   tmprtrs,
            supsmu(tmprtrs, fluos, span_smooth / denser_factor) ]

    # fit cubic spline to fluos ~ tmprtrs, re-calculate fluorescence,
    # and calculate -df/dt using `tp_denser` (a denser sequence of temperatures)
    function smoothing_process(
        spl       ::Spline1D,
        tp_denser ::AbstractVector
    )
        # baseline-subtracted spline-smoothed fluorescence data
        fluo_spl_blsub(fluo_spl ::AbstractVector) =
            # assumes constant baseline == minimum fluorescence value
            subtract_minimum(
                # optionally, smooth the output of the spline function
                smooth_fluo_spl ?
                    supsmu(tp_denser, fluo_spl, span_smooth) :
                    fluo_spl)

        # calculate derivative of denser array
        # using derivative(splin ::Spline1D, x ::Array{Float61, 1})
        # smooth output using `supsmu`
        ndrv_smu(ndrv ::AbstractVector) =
            supsmu(tp_denser, ndrv, span_smooth)

        # end of function definitions nested in smoothing_process()
        
        # return value
        hcat(
            # collate processed, interpolated data into matrix
            # note: memory intensive
            tp_denser,
            fluo_spl_blsub(spl(tp_denser)),
            ndrv_smu(-derivative(spl, tp_denser)))
    end # smoothing_process()

    # create denser array of interpolated temperature values
    # note: DataArray format doesn't work for `derivative` by "Dierckx"
    interpolated_temperatures() =
        Array(colon(
            min_tp,
            whole_tp_span / (len_raw * denser_factor - 1),
            max_tp))

    # peak finding functions

    # find summit indices of Tm peaks in `ndrv`
    sn_idc() =
        map(
            sumr_func -> find_mid_sumr_bysw(ndrv_smu, span_peaks_dp(), sumr_func),
            [maximum, minimum])

    # peaks and troughs
    summits_and_nadirs() = 
        OrderedDict(zip(
            [:summit_pre, :nadir],
            map(
                idc -> mc_denser[idc, :],
                [summit_pre_idc, nadir_idc])))

    # half_peak_span_tmprtr = (peak_span_tmprtr / 2.0)
    # `dp` - data point
    span_peaks_dp() =
        Int(round(
            (peak_span_tmprtr / 2.0) / (max_tp - min_tp) * len_denser,
            0))

    # find the indices in a vector
    # where the value at the index equals the summary
    # value of the sliding window centering at the index
    # (window width = number of data points in the whole window).
    # can be used to find peak summits and nadirs
    function find_mid_sumr_bysw(
        vals       ::AbstractVector,
        half_width ::Integer,
        sumr_func  ::Function =maximum
    )
        vals_iw(i ::Integer) = vals_padded[i : i + half_width * 2]

        const padding = fill(-sumr_func(-vals), half_width)
        const vals_padded = [padding; vals; padding]
        find(
            i -> (v -> sumr_func(v) == v[half_width + 1])(vals_iw(i)),
            1:length(vals))
    end

    # ensure that there is a trough on eiher side of every peak
    filter_summit_idc() =
        filter(
            i -> minimum(nadir_idc) < i < maximum(nadir_idc),
            summit_pre_idc)

    # calculate peak areas
    function find_peaks()

        function flanking_nadirs(summit_idx ::Integer)
            # initially we assume that the summits and nadirs are properly sorted
            # so that each summit is flanked by a nadir on both sides
            # and each pair of nadirs has a summit between them
            # this means that as we iterate over the summits
            # we can simply increment the nadir indices
            if right_nadir_ii >= len_nadir_idc
                right_nadir_ii = len_nadir_idc
            else
                right_nadir_ii += 1
            end
            left_nadir_ii = right_nadir_ii - 1
            # if we have not identified the correct flanking nadirs
            if !(nadir_idc[left_nadir_ii] < summit_idx < nadir_idc[right_nadir_ii])
                ## vectorized algorithm
                # left_nadir_idx = maximum(nadir_idc[nadir_idc .< summit_idx])
                # right_nadir_idx = minimum(nadir_idc[nadir_idc .> summit_idx])
                #
                # ## devectorized algorithm
                # len_nadir_idc = length(nadir_idc)
                # left_nadir_ii = 1
                # for i in range(1,len_nadir_idc)
                #     if nadir_idc[i] >= summit_idx
                #         break
                #     elseif nadir_idc[left_nadir_ii] < nadir_idc[i]
                #         left_nadir_ii = i
                #     end
                # end
                # right_nadir_ii = len_nadir_idc
                # for i in range(len_nadir_idc,-1,len_nadir_idc)
                #     if nadir_idc[i] <= summit_idx
                #         break
                #     elseif nadir_idc[right_nadir_ii] > nadir_idc[i]
                #         right_nadir_ii = i
                #     end
                # end
                #
                ## more efficient algorithm, assuming that
                ## the vector is long and the solution is close
                while !(nadir_idc[left_nadir_ii] < summit_idx)
                    left_nadir_ii -= 1
                end
                while (nadir_idc[left_nadir_ii + 1] < summit_idx)
                    left_nadir_ii += 1
                end
                while !(summit_idx < nadir_idc[right_nadir_ii])
                    right_nadir_ii += 1
                end
                while (summit_idx < nadir_idc[right_nadir_ii - 1])
                    right_nadir_ii -= 1
                end
            end # if we have not identified the correct flanking nadirs
            return [nadir_idc[left_nadir_ii], nadir_idc[right_nadir_ii]]
        end

        function peak_bounds(summit_idx ::Integer, flanking_nadir_idc ::AbstractVector)
            # nadir_vec = [left_nadir_idx, right_nadir_idx]
            # low_nadir_idx, high_nadir_idx = map(
            #     func -> nadir_vec[func(ndrv_smu[nadir_vec])[2]],
            #     [findmin, findmax])
            low_nadir_idx, high_nadir_idx =
                (diff(ndrv_smu[flanking_nadir_idc])[1] > 0.0) ?
                    flanking_nadir_idc :
                    flanking_nadir_idc[2:-1:1]
            hn_ns = ndrv_smu[high_nadir_idx]
            #
            ## find the nearest location to `summit_idx`
            ## on the `low_nadir_idx` side of the peak
            ## where the line `ndrv = ndrv_smu[high_nadir_idx]`
            ## is crossed by the `ndrv_smu` curve
            # idx_lb, idx_ub = map(
            #     func -> func([summit_idx, low_nadir_idx]),
            #     [minimum, maximum])
            idx_step = -1 + 2 * (summit_idx < low_nadir_idx)
            about2cross_idx = low_nadir_idx - idx_step # peak slightly narrower than using actual crossing point
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
                end # if
                idx = idx1
            end # while
            #
            # return values of this algorithm
            return [high_nadir_idx, about2cross_idx]
        end

        # peak area elevated from baseline ==
        # integrated -df/dT peak area elevated from x-axis -
        # trapezium-shaped baseline area elevated from x-axis
        # Issue: function looks wrong, does not match R algorithm
        # Proposed solution: recode using Dierckx.integrate
        function peak_area(peak_bound_idc ::AbstractVector)

            area_func(tp_low_end ::Real, tp_high_end ::Real) =
                -sum(ndrv_smu[peak_bound_idc]) * (tp_high_end - tp_low_end) / 2.0 -
                    (spl(tp_high_end) - spl(tp_low_end))

            # end of function definition nested in peak_area()

            # tp_low_end, tp_high_end = map(
            #     func -> func(tp_denser[peak_bound_idc]),
            #     [minimum, maximum])
            return area_func(
                (diff(tp_denser[peak_bound_idc])[1] > 0 ?
                    tp_denser[peak_bound_idc] :
                    tp_denser[peak_bound_idc][2:-1:1])...)
        end

        # end of function definitions nested in find_peaks()

        # initialize flanking_nadirs()
        right_nadir_ii = 1

        # return value Ta_raw_wdup =
        round.(
            hcat(
                tp_denser[summit_idc],
                [   peak_area(peak_bounds(summit_idx,flanking_nadirs(summit_idx)))
                    for summit_idx in summit_idc    ]),
            json_digits)
    end # find_peaks()

    function remove_duplicate_peaks(Ta_raw_wdup ::Array{T,2} where T <: AbstractFloat)

        summit_ii_grps() =
            [   find(
                    summit_idx -> nadir_idc[nadir_ii] < summit_idx < nadir_idc[nadir_ii+1],
                    summit_idc)
                for nadir_ii in range(1,len_nadir_idc-1)    ]

        real_summit_ii_range(summit_ii_grp ::Vector{T} where T <: Integer) =
            length(summit_ii_grp) == 0 ?
                range(1,0) :
                range(summit_ii_grp[findmax(ndrv_smu[summit_idc[summit_ii_grp]])[2]], 1)

        # end of function definitions nested in remove_duplicate_peaks()

        # return value Ta_raw =
        vcat(
            map(
                summit_ii_grp -> Ta_raw_wdup[real_summit_ii_range(summit_ii_grp), :],
                summit_ii_grps())...)
    end # remove_duplicate_peaks()

    # count cross points
    function count_cross_points()
        ## vectorized version
        # num_cross_points = sum(map(1:(len_denser-1)) do i
        #     (ndrv_smu[i] - ns_range_mid) * (ndrv_smu[i+1] - ns_range_mid) <= 0
        # end)

        ## devectorized version
        num_cross_points = 0
        ndrv_smu_centred1 = sign(ndrv_smu[1] - ns_range_mid)
        i = 0
        while (i < len_denser)
            i += 1
            ndrv_smu_centred0 = ndrv_smu_centred1
            ndrv_smu_centred1 = sign(ndrv_smu[i] - ns_range_mid)
            if (ndrv_smu_centred0 != ndrv_smu_centred1)
                num_cross_points += 1
            end
        end # while
        return num_cross_points
    end # count_cross_points()

    # filter in real Tm peaks and out those due to random fluctuation
    # `fltd` - filtered
    function filter_peaks(
        tmprtr_max_ndrv     ::AbstractFloat,
        areas_raw           ::AbstractVector,
        fn_mc_slope         ::Function,         # linear regression fluos ~ tmprtrs
        fn_num_cross_points ::Function,
    )
        split_vector_and_return_larger_quantile(
            vec              ::AbstractVector,
            len              ::Integer,
            split_idx        ::Integer,
            q                ::AbstractFloat) =
                maximum(quantile(vec[side], q) for side in (1:split_idx, split_idx:len))

        top_peaks(fltd_idc_topNp1 ::AbstractVector) =
            (length(fltd_idc_topNp1) > top_N) ?
                EMPTY_Ta :
                Ta_raw[fltd_idc_topNp1, :]

        # end of function definitions nested in filter_peaks()

        if  (fn_num_cross_points() > min(ncp_ub, len_raw * noisy_factor)) ||
            (split_vector_and_return_larger_quantile(
                normalize_range(ndrv_smu), # originally normalize_range(ndrv),
                len_denser,
                summit_idc[indmax(areas_raw)], # peak with largest area
                qt_prob_flTm) # larger_normd_qtv_of_two_sides
                    > normd_qtv_ub) ||
            (fn_mc_slope() >= 0.0)
            return EMPTY_Ta
        end
        # else

        ## Disabled because it caused false suppression of Tm peak reporting for
        ## `db_name_ = "20160309_chaipcr"; exp_id_ = 7`, well A2.
        ## Needs to be enabled because it is the only criterion that
        ## suppress false reporting of not-real peaks in
        ## `db_name_ = "20161103_chaipcr_ip152"; exp_id_ = 45`, well A1
        # top1_Tm_idx =  # peak with largest area
        # top1_from_max = abs(tp_denser[top1_Tm_idx] - tmprtr_max_ndrv)
        # if (top1_from_max > top1_from_max_ub)
        #     return EMPTY_Ta
        # end

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
        ## else
        # return Ta_raw[idc_topNp1[fltd_idc], :]

        # when all the Tm peaks are noises, no peak is expected
        # to have a substantially larger area than the other peaks.
        # Provided `top_N+1 <= len_Tms`, this is observed as
        # `areas_raw[idc_sb_area[top_N+1]] >= area_report_lb`
        # implying `length(fltd_idc_topNp1) > top_N`

        return top_peaks(
            filter(
                idx -> areas_raw[idx] >= areas_raw[idc_sb_area[1]] * frac_report_lb,
                idc_sb_area[range(1, min(top_N+1, len_Tms))])
        )
    end # filter_peaks()

    # end of function definitions nested in mc_tm_pw()

    # filter out data points separated by narrow temperature intervals
    # `nti` - narrow temperature interval
    const tf            = tf_dict |> filter_nti
    const tmprtrs       = tf[:tmprtrs]
    const fluos         = tf[:fluos]
    const len_raw       = length(tmprtrs)

    # negative derivative by central finite differencing (cfd)
    # only used if the data array is too short to find peaks
    if (len_raw <= 3)
        return MeltCurveTa(
            hcat(
                tmprtrs,
                fluos,
                -finite_diff(
                    tmprtrs,
                    fluos;
                    nu = 1,
                    method = "central")),               # mc_raw
            EMPTY_Ta,                                   # Ta_fltd
            EMPTY_mc,                                   # mc_denser
            NaN,                                        # ns_range_mid
            Dict(:tmprtrs=>EMPTY_Ta, :fluos=>EMPTY_Ta), # sn_dict
            EMPTY_Ta,                                   # Ta_raw
            "No"                                        # Ta_reported
        )
    end
    # else

    const min_tp        = minimum(tmprtrs)
    const max_tp        = maximum(tmprtrs)
    const whole_tp_span = max_tp - min_tp

    # choose smoothing parameter
    const span_smooth   = choose_span_smooth()

    # fit a cubic spline model in order to interpolate data points
    # then smooth data and calculate slope at denser sequence of temperatures
    const spl           = spline_model(smooth_raw_fluo())
    const mc_denser     = smoothing_process(spl, interpolated_temperatures())
    const tp_denser     = mc_denser[:,1]
    const ndrv_smu      = mc_denser[:,3]
    const len_denser    = length(tp_denser)

    # extract data at observed temperatures
    const mc_raw        = mc_denser[1:denser_factor:len_denser, :]

    # find peak and trough locations
    # `sn` - summits and nadirs
    const summit_pre_idc, nadir_idc = sn_idc()
    const len_nadir_idc = length(nadir_idc)
    const summit_idc    = filter_summit_idc()
    const sn_dict       = summits_and_nadirs()

    # estimate area of peaks above baseline
    const Ta_raw        = remove_duplicate_peaks(find_peaks())

    const max_ndrv_smu  = findmax(ndrv_smu)
    const ns_range_mid  = mean([quantile(ndrv_smu, qt_prob_range_lb), max_ndrv_smu[1]])

    const len_Tms       = size(Ta_raw)[1]
    if (len_Tms == 0)
        return MeltCurveTa(
            mc_raw,
            EMPTY_Ta,       # Ta_fltd
            mc_denser,
            ns_range_mid,
            sn_dict,
            EMPTY_Ta,       # Ta_raw
            "No")
    end
    #else

    # peak indices sorted by area
    # `idc_sb` - indices sorted by
    const idc_sb_area   = sortperm(Ta_raw[:, end], rev=true)

    # keep only the biggest peak(s)
    # passes functions instead of values for mc_slope & num_cross_points
    # so that the values are only calculated if needed
    # `fltd` - filtered
    const Ta_fltd =
        filter_peaks(
            tp_denser[max_ndrv_smu[2]],       # tmprtr_max_ndrv
            Ta_raw[:, end],                   # areas_raw
            () -> linreg(tmprtrs, fluos)[2],  # () -> mc_slope
            count_cross_points
        )

    return MeltCurveTa(
        round.(mc_raw, json_digits),
        Ta_fltd,
        mc_denser,
        ns_range_mid,
        sn_dict,
        Ta_raw[idc_sb_area, :], # sorted by area
        Ta_fltd == EMPTY_Ta ? "No" : "Yes"
    )
end # mc_tm_pw()

# functions called by mc_tm_pw()

# jitter duplicated elements in a numeric vector
# so that all the elements become unique
# used to eliminate duplicate values in temperature data
function mutate_dups(
    vec_2mut ::AbstractVector,
    frac2add ::Real =0.01
)
    const vec_len = length(vec_2mut)
    const vec_uniq = sort(unique(vec_2mut))
    const vec_uniq_len = length(vec_uniq)
    #
    if (vec_len == vec_uniq_len)
        return vec_2mut
    else
        const order_to = sortperm(vec_2mut)
        const order_back = sortperm(order_to)
        vec_sorted = (vec_2mut + .0)[order_to]
        const vec_sorted_prev = vcat(vec_sorted[1]-1, vec_sorted[1:vec_len-1])
        const dups = (1:vec_len)[map(1:vec_len) do i
            vec_sorted[i] == vec_sorted_prev[i]
        end]
        #
        const add1 = frac2add * median(map(2:vec_uniq_len) do i
            vec_uniq[i] - vec_uniq[i-1]
        end)
        #
        for dup_i in 1:length(dups)
            dup_i_moveup = dup_i
            rank = 1
            while dup_i_moveup > 1 && dups[dup_i_moveup] - dups[dup_i_moveup-1] == 1
                dup_i_moveup -= 1
                rank += 1
            end
            vec_sorted[dups[dup_i]] += add1 * rank
        end
        #
        return vec_sorted[order_back]
    end
end

# finite differencing function
function finite_diff(
    X ::AbstractVector,
    Y ::AbstractVector; # X and Y must be of same length
    nu ::Integer=1, # order of derivative
    method ::String="central"
)
    const dlen = length(X)
    if dlen != length(Y)
        error("X and Y must be of same length.")
    end
    if (dlen == 1)
        return zeros(1)
    end
    if (nu == 1)
        if (method == "central")
            const range1 = 3:dlen+2
            const range2 = 1:dlen
        elseif (method == "forward")
            const range1 = 3:dlen+2
            const range2 = 2:dlen+1
        elseif (method == "backward")
            const range1 = 2:dlen+1
            const range2 = 1:dlen
        end
        const X_p2, Y_p2 = map((X, Y)) do ori
            vcat(
                ori[2] * 2 - ori[1],
                ori,
                ori[dlen-1] * 2 - ori[dlen])
        end
        return (Y_p2[range1] .- Y_p2[range2]) ./ (X_p2[range1] .- X_p2[range2])
    else
        return finite_diff(
            X,
            finite_diff(X, Y; nu=nu-1, method=method),
            nu=1;
            method=method)
    end # if nu == 1
end






#
