# melt curve analysis

const EMPTY_mc = zeros(1,3)[1:0,:]
const EMPTY_Ta = zeros(1,2)[1:0,:]
const EMPTY_mc_tm_pw_out = OrderedDict(
    "mc" => EMPTY_mc,
    "Ta_raw" => EMPTY_Ta,
    "Ta_fltd" => EMPTY_Ta
)


type MeltCurveTF # temperature and fluorescence
    t_da_vec::Vector{DataArray{AbstractFloat,1}}
    fluo_da::DataArray{AbstractFloat,2}
end

type MeltCurveTa # Tm and area
    mc::Array{AbstractFloat,2}
    Ta_fltd::Array{AbstractFloat,2}
    Ta_raw::Array{AbstractFloat,2}
    Ta_reported::String
end

type MeltCurveOutput
    mc_bychwl::Matrix{MeltCurveTa} # dim1 is well and dim2 is channel
    channel_nums::Vector{Int}
    fluo_well_nums::Vector{Int}
    fr_ary3::Array{AbstractFloat,3}
    mw_ary3::Array{AbstractFloat,3}
    k4dcv::K4Deconv
    fdcvd_ary3::Array{AbstractFloat,3}
    wva_data::OrderedDict{String,OrderedDict{Int,Vector{AbstractFloat}}}
    wva_well_nums::Vector{Int}
    faw_ary3::Array{AbstractFloat,3}
    tf_bychwl::OrderedDict{Int,Vector{OrderedDict{String,Vector{AbstractFloat}}}}
end



# Top-level function: get melting curve data and Tm for a melt curve experiment
function process_mc(
    db_conn::MySQL.MySQLHandle,
    exp_id::Integer, stage_id::Integer,
    calib_info::Union{Integer,OrderedDict};
    # start: arguments that might be passed by upstream code
    well_nums::AbstractVector=[],
    channel_nums::AbstractVector=[1],
    auto_span_smooth::Bool=false,
    span_smooth_default::Real=0.015,
    span_smooth_factor::Real=7.2,
    # end: arguments that might be passed by upstream code
    dye_in::String="FAM", dyes_2bfild::AbstractVector=[],
    dcv::Bool=true, # logical, whether to perform multi-channel deconvolution
	max_tmprtr::Real=1000, # maximum temperature to analyze
    out_format::String="json", # "full", "pre_json", "json"
    verbose::Bool=false,
    kwdict_mc_tm_pw::OrderedDict=OrderedDict() # keyword arguments passed onto `mc_tm_pw`
    )

    print_v(println, verbose,
        "db_conn: ", db_conn, "\n",
        "experiment_id: $exp_id\n",
        "stage_id: $stage_id\n",
        "calib_info: $calib_info\n",
        "max_tmprtr: $max_tmprtr"
    )

    calib_info = ensure_ci(db_conn, calib_info, exp_id)

    mcd_qry_2b = "
        SELECT well_num, channel
            FROM melt_curve_data
                WHERE
                    experiment_id = $exp_id AND
                    stage_id = $stage_id AND
                    temperature <= $max_tmprtr
                    well_constraint
    "
    mcd_df, fluo_well_nums = get_mysql_data_well(
        well_nums, mcd_qry_2b, db_conn, verbose
    )
    num_fluo_wells = length(fluo_well_nums)

    # pre-deconvolution, can process multiple channels
    # channel_nums = sort(unique(mcd_df[:channel])) # process all available channels in the database
    num_channels = length(channel_nums)
    if num_channels == 1
        dcv = false
    end

    # # pre-deconvolution, process only channel 1
    # channel_nums = [1]
    # num_channels = 1
    # dcv = false

    mc_data_bych = map(channel_nums) do channel_num
        get_mc_data(
            channel_num,
            db_conn,
            exp_id, stage_id,
            well_nums,
        	max_tmprtr
        )
    end

    fr_ary3 = cat(3, map(mc_data -> mc_data.fluo_da, mc_data_bych)...) # fr = fluo_raw

    mw_ary3, k4dcv, fdcvd_ary3, wva_data, wva_well_nums, faw_ary3 = dcv_aw(
        fr_ary3, dcv, channel_nums,
        db_conn, calib_info, fluo_well_nums, well_nums, dye_in, dyes_2bfild;
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
    channel_num::Integer,
    db_conn::MySQL.MySQLHandle,
    exp_id::Integer, stage_id::Integer,
    well_nums::AbstractVector,
	max_tmprtr::Real
    )

    # get fluorescence data for melting curve
    fluo_qry_2b = "
        SELECT well_num, temperature, fluorescence_value
            FROM melt_curve_data
            WHERE
                experiment_id = $exp_id AND
                stage_id = $stage_id AND
                channel = $channel_num AND
				temperature <= $max_tmprtr
                well_constraint
            ORDER BY well_num, temperature
    "
    fluo_sel, fluo_well_nums = get_mysql_data_well(
        well_nums, fluo_qry_2b, db_conn, false
    )

    # split temperature and fluo data by well_num
    tf_df_vec = map(fluo_well_nums) do well_num
        fluo_sel[
            fluo_sel[:well_num] .== well_num,
            [:temperature, :fluorescence_value]
        ]
    end # do well_num

    # add NaN to the end if not enough data
    max_len = maximum(map(tf_df -> size(tf_df)[1], tf_df_vec))
    tf_dv_adj = map(tf_df_vec) do tf_df
        nan_da = ones(max_len - size(tf_df)[1]) * NaN
        nan_df = DataFrame(temperature=nan_da, fluorescence_value=nan_da)
        vcat(tf_df, nan_df)
    end # do tf_df

    # temperature DataArray vector, with rows as temperature points and columns as wells
    t_da_vec = map(tf_df -> tf_df[:temperature], tf_dv_adj)

    # fluorescence DataArray
    fluo_da = hcat(map(tf_df -> tf_df[:fluorescence_value], tf_dv_adj)...)

    return MeltCurveTF(t_da_vec, fluo_da)

end # get_mc_data


# function: get melting curve data and Tm peaks for each well

function mc_tm_pw(fake_input::Void; kwargs...)
    EMPTY_mc_tm_pw_out
end

function mc_tm_pw(

    # input data
    tf_dict::OrderedDict; # temperature and fluorescence

    # The maximum fraction of median temperature interval to be considered narrow
    nti_frac::AbstractFloat=0.05,

    # smoothing -df/dt curve and if `smooth_fluo`, fluorescence curve too
    auto_span_smooth::Bool=true,
    span_css_tmprtr::Real=1, # css = choose `span_smooth`. fluorescence fluctuation with the temperature range of approximately `span_css_tmprtr * 2` is considered for choosing `span_smooth`
    span_smooth_default::Real=0.05, # unit: fraction of data points for smoothing
    span_smooth_factor::Real=7.2,

    # get a denser temperature sequence to get fluorescence and -df/dt from it and fitted spline function
    denser_factor::Real=10,
    smooth_fluo_spl::Bool=false,

    # identify Tm peaks and calculate peak area
    peak_span_tmprtr::Real=5, # Within the smoothed -df/dt sequence spanning the temperature range of approximately `peak_span_tmprtr`, if the maximum -df/dt value equals that at the middle point of the sequence, identify this middle point as a peak summit. Similar to `span.peaks` in qpcR code. Combined with `peak_shoulder` (similar to `Tm.border` in qpcR code).
    # peak_shoulder::Real=1, # 1/2 width of peak in temperature when calculating peak area  # consider changing from 1 to 2, or automatically determined (max and min d2)?

    # filter Tm peaks
    qt_prob_flTm::Real=0.64, # quantile probability point for normalized -df/dT (range 0-1)
    max_normd_qtv::Real=0.8, # maximum normalized -df/dt values (range 0-1) at the quantile probablity point
    top1_from_max_ub::Real=1, # upper bound of temperature difference between top-1 Tm peak and maximum -df/dt
    top_N::Integer=4, # top number of Tm peaks to report
    min_frac_report::Real=0.1, # minimum area fraction of the Tm peak to be reported in regards to the largest real Tm peak

    json_digits::Integer=JSON_DIGITS,

    verbose::Bool=false,
    )

    # parse input data
    tmprtrs_ori = tf_dict["tmprtrs"]
    tmprtr_intvls = vcat(tmprtrs_ori[2:end], Inf .- tmprtrs_ori[end]) .- tmprtrs_ori
    nti = nti_frac * median(tmprtr_intvls) # nti = narrow temperature interval
    no_nti = find(tmprtr_intvl -> tmprtr_intvl > nti, tmprtr_intvls)
    tmprtrs = mutate_dups(tmprtrs_ori[no_nti]) # duplication may cause spline interpolation failure by Dierckx
    fluos = tf_dict["fluos"][no_nti]

    len_raw = length(tmprtrs)
    area_i = 2

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

        ndrv = -derivative(spl, tp_denser) #  derivative(splin::Dierckx.Spline1D, x::Array{Float61, 1})
        ndrv_smu = supsmu(tp_denser, ndrv, span_smooth) # using default for the rest of `supsmu` parameters

        mc_raw = hcat(
            tp_denser, fluo_spl_blsub, ndrv_smu
        )[1:denser_factor:len_denser, :]

        # end: fit cubic spline ...

        half_peak_span_tmprtr = peak_span_tmprtr / 2

        # find summit indices of Tm peaks in `ndrv`
        span_peaks_dp = Int(round(half_peak_span_tmprtr / (max_tp - min_tp) * length(tp_denser), 0)) # dp = data point
        min_ns_vec = fill(minimum(ndrv_smu), span_peaks_dp) # ns = ndrv_smu
        ns_wms = [min_ns_vec; ndrv_smu; min_ns_vec] # wms = with min values
        summit_idc = find(1:len_denser) do i
            ndrv_iw = ns_wms[i : i + span_peaks_dp * 2] # iw = in window
            return maximum(ndrv_iw) == ndrv_iw[span_peaks_dp + 1]
        end # do i

        # calculate peak area
        Tms = tp_denser[summit_idc]
        len_Tms = length(Tms)
        Ta_raw = vcat(map(Tms) do Tm # Ta = Tm_area
            a_idc_bool = map(tp_denser) do tp
                Tm - half_peak_span_tmprtr < tp < Tm + half_peak_span_tmprtr
            end
            a_idc_int = (1:len_denser)[a_idc_bool]
            base_end_idc = [a_idc_int[1], a_idc_int[end]]
            tp_denser_bes = tp_denser[base_end_idc] # be = base_end
            ndrv_bes = ndrv[base_end_idc]
            # baseline_coefs = *(inv([ones(2) tp_denser_bes]), ndrv_bes) # coefficients (solved by linear algebra) for baseline (the line connecting the two ends of curve -df/dT against temperature)
            # baseline = *([ones(length(a_idc_int)) tp_denser[a_idc_int]], baseline_coefs)
            area = spl(tp_denser_bes[1]) - spl(tp_denser_bes[2])    - sum(ndrv_bes) * (tp_denser_bes[2] - tp_denser_bes[1]) / 2
            #      integrated -df/dT peak area elevated from x-axis - trapezium-shaped baseline area elevlated from x-axis == peak area elevated from baseline (pa)
            # pa_vec[i] = OrderedDict("Tm"=>Tm, "pa"=>pa)
            return round.([Tm area], json_digits)
        end...) # do Tm


        # filter in real Tm peaks and out those due to random fluctuation. fltd = filtered

        Ta_fltd = EMPTY_Ta # 0x2 Array. On another note, 2x0 Array `Ta_raw[:, 1:0]` raised error upon `json`.
        Ta_reported = "No"

        if len_Tms > 0

            # larger_normd_qtv_of_two_sides
            # area_i = 2
            areas_raw = Ta_raw[:, area_i]
            abs_areas_raw = abs(areas_raw)
            ndrv_normd = (ndrv - minimum(ndrv)) / (maximum(ndrv) - minimum(ndrv))
            top1_Tm_idx = summit_idc[indmax(areas_raw)]
            larger_normd_qtv_of_two_sides = maximum(
                map((1:top1_Tm_idx, top1_Tm_idx:len_denser)) do idc
                    quantile(ndrv_normd[idc], qt_prob_flTm)
                end
            )

            # top1_from_max
            tmprtr_max_ndrv = tp_denser[findmax(ndrv_smu)[2]]
            top1_from_max = abs(tp_denser[top1_Tm_idx] - tmprtr_max_ndrv)

            # mc_slope
            mc_slope = linreg(tmprtrs, fluos)[2]

            seq_topNp1 = 1 : min(top_N+1, len_Tms)

            # idc_topNp1, min_area_report
            idc_sb_area = sortperm(areas_raw, rev=true) # idc_sb = indice sorted by
            idc_topNp1 = idc_sb_area[seq_topNp1]
            min_area_report = areas_raw[idc_topNp1[1]] * min_frac_report

            # absolute areas
            idc_sb_abs_area = sortperm(abs_areas_raw, rev=true)
            idc_abs_topNp1 = idc_sb_abs_area[seq_topNp1]
            smallest_abs_area_within_topNp1 = top_N+1 <= len_Tms ? abs_areas_raw[idc_abs_topNp1[end]] : 0

            # reporting
            if (
                larger_normd_qtv_of_two_sides <= max_normd_qtv &&
                # top1_from_max <= top1_from_max_ub && # disabled because it caused false suppression of Tm peak reporting for `db_name_ = "20160309_chaipcr"; exp_id_ = 7`, well A2.
                mc_slope < 0
                )

                fltd_idc = find(idc_topNp1) do idx
                    areas_raw[idx] >= min_area_report
                end # do idx

                # if length(fltd_idc) <= top_N && # When all the Tm peaks are noises, no peak is expected to have a substantially larger area than the other peaks. This can be observed as top-(N+1) peak has an area >= `min_area_report`, and thus `length(fltd_idc) > top_N`
                if smallest_abs_area_within_topNp1 < min_area_report # When all the Tm peaks are noises, no peak is expected to have a substantially larger area than the other peaks; and absolute values of negative peak areas should not be much smaller than top-1 peak area.
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
        Ta_raw,
        "$Ta_reported. All of the following statements must be true for Tm to be reported. \n(1) The larger normalized quantile value of the left and right sides of the summit on the negative derivative curve $larger_normd_qtv_of_two_sides <= `max_normd_qtv` $max_normd_qtv. \n(2, disabled for now) The top-1 Tm peak is $(top1_from_max)C (need to be <= top1_from_max_ub $(top1_from_max_ub)C) away from maximum -df/dT temperature $tmprtr_max_ndrv. \n(3) Has $(size(Ta_raw)[1]) no more than $top_N (top_N) raw_tm peaks, or the peak with smallest absolute area within top-$(top_N+1) (top_N+1) has an absolute area $smallest_abs_area_within_topNp1 < $min_area_report ($min_frac_report of the top-1 peak). \n(4) The slope of the straight line fit to the melt curve $mc_slope < 0."
    )

end # mc_tm_pw




#
