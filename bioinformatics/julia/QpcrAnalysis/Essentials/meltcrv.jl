# melt curve analysis

const EMPTY_mc = zeros(1,3)[1:0,:]
const EMPTY_Ta = zeros(1,2)[1:0,:]
const EMPTY_mc_tm_pw_out = OrderedDict(
    "mc" => EMPTY_mc,
    "Ta_raw" => EMPTY_Ta,
    "Ta_fltd" => EMPTY_Ta
)


# Top-level function: get melting curve data and Tm for a melt curve experiment
function process_mc(
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
    out_format::AbstractString="json", # "full", "pre_json", "json"
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

    # # pre-deconvolution, process all available channels
    # channels = sort(unique(mcd_df[:channel]))
    # num_channels = length(channels)
    # if num_channels == 1
    #     dcv = false
    # end

    # pre-deconvolution, process only channel 1
    channels = [1]
    num_channels = 1
    dcv = false

    channel_dict = OrderedDict(map(channels) do channel
        channel => channel
    end)

    mc_data_mtch = process_mtch(
        channel_dict,
        true, # arydims2to3
        get_mc_data, # func
        db_conn,
        exp_id, stage_id,
        well_nums,
        max_tmprtr
    )

    mc_data_mtch_bych = mc_data_mtch["pre_consoli"]

    fr_ary3 = mc_data_mtch["post_consoli"]["fluo_da"] # fr = fluo_raw

    mw_ary3, k_dict, fdcvd_ary3, wva_data, wva_well_nums, faw_ary3 = dcv_aw(
        fr_ary3, dcv, channels,
        db_conn, calib_info, fluo_well_nums, well_nums, dye_in, dyes_2bfild;
        aw_out_format="array"
    )

    # post-deconvolution, process for only 1 channel
    # channel_only1 = 1 # used: 1, 2
    # fc_bych = OrderedDict(channel_only1 => fc_bych[channel_only1])

    tf_bychwl = OrderedDict( # bychwl = by channel then by well
        map(1:num_channels) do channel_i
            channel = channels[channel_i]
            tf = map(wva_well_nums) do wva_well_num
                if wva_well_num in fluo_well_nums
                    i = indexin([wva_well_num], fluo_well_nums)[1]
                    tmprtrs_wNaN = mc_data_mtch_bych[channel]["t_da_vec"][i]
                    fluos_wNaN = faw_ary3[:,i,channel]
                    idc_not_NaN = find(tmprtrs_wNaN) do tmprtr
                        !isnan(tmprtr)
                    end
                    OrderedDict(
                        "tmprtrs" => tmprtrs_wNaN[idc_not_NaN],
                        "fluos" => fluos_wNaN[idc_not_NaN]
                    ) # note: selecting one column of a 2-D array results in a vector (1-D array), but selecting one row of it results in a 1-row 2-D array.
                else
                    nothing
                end # if
            end # do oc_well_num
            return channels[channel_i] => tf
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
        old_keys = ["mc", "Ta_fltd"]
        new_keys = ["melt_curve_data", "melt_curve_analysis"]
        mc_out = OrderedDict(map(1:length(new_keys)) do key_i
            new_keys[key_i] => [mc_bychwl[well_i, channel_i][old_keys[key_i]]
                for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
            ]
        end) # do key_i
        if out_format == "json"
            mc_out = json(mc_out)
        end
    elseif out_format == "full"
        mc_out = OrderedDict( # each element is an OrderedDict whose each element represents a channel
            "mc_bychwl"=>mc_bychwl, # a matrix where dim1 is well and dim2 is channel
            "channels"=>channels,
            "fluo_well_nums"=>fluo_well_nums,
            "fr_ary3"=>fr_ary3,
            "mw_ary3"=>mw_ary3,
            "k_dict"=>k_dict, "fdcvd_ary3"=>fdcvd_ary3,
            "wva_data"=>wva_data, "wva_well_nums"=>wva_well_nums,
            "faw_ary3"=>faw_ary3,
            "tf_bychwl"=>tf_bychwl
        )
    end

    return mc_out

end # process_mc


# functions called by `process_mc`

# function: get raw melt curve data and perform optical calibration
function get_mc_data(
    channel::Integer,
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
                channel = $channel AND
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

    # optical calibration
    fluo_da = hcat(map(tf_df -> tf_df[:fluorescence_value], tf_dv_adj)...)

    mc_data = OrderedDict(
        "t_da_vec" => t_da_vec,
        "fluo_da" => fluo_da
    )

    return mc_data

end # get_mc_data


# function: get melting curve data and Tm peaks for each well

function mc_tm_pw(fake_input::Void; kwargs...)
    EMPTY_mc_tm_pw_out
end

function mc_tm_pw(

    # input data
    tf_dict::OrderedDict; # temperature and fluorescence

    # smoothing -df/dt curve and if `smooth_fluo`, fluorescence curve too
    auto_span_smooth::Bool=true,
    span_css_tmprtr::Real=1, # css = choose `span_smooth`. fluorescence fluctuation with the temperature range of approximately `span_css_tmprtr * 2` is considered for choosing `span_smooth`
    span_smooth_default::Real=0.05, # unit: fraction of data points for smoothing
    span_smooth_factor::Real=7.2,

    # get a denser temperature sequence to get fluorescence and -df/dt from it and fitted spline function
    denser_factor::Real=10,
    smooth_fluo_spl::Bool=false,

    # identify Tm peaks and calculate peak area
    span_peaks_tmprtr::Real=0.5, # Within the smoothed -df/dt sequence spanning the temperature range of approximately `span_peaks_tmprtr * 2`, if the maximum -df/dt value equals that at the middle point of the sequence, identify this middle point as a peak summit.
    peak_shoulder::Real=1, # 1/2 width of peak in temperature when calculating peak area

    # filter Tm peaks
    qt_prob_flTm::Real=0.64, # quantile probability point for normalized -df/dT (range 0-1)
    max_normd_qtv::Real=0.6, # maximum normalized -df/dt values (range 0-1) at the quantile probablity point
    top_N::Integer=4, # top number of Tm peaks to report
    min_frac_report::Real=0.1, # minimum area fraction of the Tm peak to be reported in regards to the largest real Tm peak

    json_digits::Integer=JSON_DIGITS,

    verbose::Bool=false,
    )

    # parse input data
    tmprtrs = mutate_dups(tf_dict["tmprtrs"]) # duplication may cause spline interpolation failure by Dierckx
    fluos = tf_dict["fluos"]

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

        ndrv = -derivative(spl, tp_denser) #  derivative(splin::Dierckx.Spline1D, x::Array{Float61, 1})
        ndrv_smu = supsmu(tp_denser, ndrv, span_smooth) # using default for the rest of `supsmu` parameters

        mc_raw = hcat(
            tp_denser, fluo_spl_blsub, ndrv_smu
        )[1:denser_factor:len_denser, :]

        # end: fit cubic spline ...


        # find summit indices of Tm peaks in `ndrv`
        span_peaks_dp = Int(round(span_peaks_tmprtr / (max_tp - min_tp) * length(tp_denser), 0)) # dp = data points
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
                Tm - peak_shoulder < tp < Tm + peak_shoulder
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
            return round([Tm area], json_digits)
        end...) # do Tm

        # filter for real Tm peaks and against those due to random fluctuation. fltd = filtered
        Ta_fltd = EMPTY_Ta # 0x2 Array. On another note, 2x0 Array `Ta_raw[:, 1:0]` raised error upon `json`.
        if len_Tms > 0
            area_i = 2
            areas_raw = Ta_raw[:, area_i]
            ndrv_normd = (ndrv - minimum(ndrv)) / (maximum(ndrv) - minimum(ndrv))
            top1_Tm_idx = summit_idc[indmax(areas_raw)]
            if maximum(map((1:top1_Tm_idx, top1_Tm_idx:len_denser)) do idc
                quantile(ndrv_normd[idc], qt_prob_flTm)
            end) < max_normd_qtv
                idc_sb_area = sortperm(areas_raw, rev=true) # idc_sb = indice sorted by
                idc_topN = idc_sb_area[1:min(top_N,len_Tms)]
                fltd_idc = find(idc_topN) do idx_topN
                    areas_raw[idx_topN] >= areas_raw[idc_topN[1]] * min_frac_report
                end # do idx_topN
                Ta_fltd = Ta_raw[idc_topN[fltd_idc], :]
            end
        end

    end # if shorter_length_raw <= 3 ... else

    mc = round(mc_raw, json_digits)

    return OrderedDict("mc"=>mc, "Ta_fltd"=>Ta_fltd, "Ta_raw"=>Ta_raw)

end # mc_tm_pw




#
