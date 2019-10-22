#===============================================================================

    mc_peak_analysis.jl

    melting curve peak analysis

===============================================================================#

import DataStructures.OrderedDict
import DataFrames.DataFrame
import StatsBase: rle
import Dierckx: Spline1D, derivative
import Memento: debug, info


#==============================================================================#


"Finds peak in the melting curve data, specifically the negative of the derivative
of fluorescence with respect to temperature, for each well and channel."
function mc_peak_analysis(
    output_type                 ::Type{P},
    i                           ::McInput,
    df                          ::DataFrame,
) where {P <: McPeakOutput}

    ## functions to parse input data >>

    "Filter out data points that are separated by narrow temperature intervals."
    filter_too_close(df ::DataFrame) =
        df[df[:temperature] |> mold(Float_T) |> temperature_intervals |> not_too_close, :]

    "Calculate temperature intervals."
    temperature_intervals(temps_orig ::Vector{<: Float_T}) =
        vcat(diff(temps_orig), Inf_T)

    "Criterion for narrow temperature intervals."
    not_too_close(temp_intervals ::Vector{<: Float_T}) =
        temp_intervals .> i.temp_too_close_frac * median(temp_intervals)

    jitter_temps!(df ::DataFrame) =
        (mutate_dups(df[:temperature], i.jitter_constant), df[:fluorescence] |> mold(Float_T))

    ## functions used to calculate `span_smooth` >>

    "Choose the value for the smoothing parameter `span_smooth`."
    choose_span_smooth() =
        if i.auto_span_smooth
            info(logger, "automatic selection of `span_smooth`...")
            calc_span_smooth(fu_rle())
        else
            info(logger, "no automatic selection, use span_smooth_default " *
                string(i.span_smooth_default) * " as `span_smooth`")
            i.span_smooth_default
        end ## if

    "Calculate the smoothing parameter `span_smooth`."
    @inline function calc_span_smooth(fu ::Tuple{Vector{Bool},Vector{<: Integer}})

        larger_span(span_smooth_product ::Real) =
            if span_smooth_product > i.span_smooth_default
                info(logger, "`span_smooth` was selected as $span_smooth_product")
                return span_smooth_product
            else
                info(logger, "`span_smooth_product` $span_smooth_product < " *
                    "`span_smooth_default`, use `span_smooth_default` " *
                    string(i.span_smooth_default))
                return i.span_smooth_default
            end ## if

        "Calculate `span_smooth_product` as the longest temperature span
        in which fluorescence rises with temperature."
        span_smooth_product() =
            i.span_smooth_factor * max_fu_temp_span(fu_idc()) / i.temp_span

        max_fu_temp_span(fu ::AbstractVector{Int_T}) =
            maximum(temps[fu_idc[2:2:end]] .- temps[fu[1:2:end]])

        fu_idc() = (cumsum(fu[1][1] ? vcat(0,fu[2]) : fu[2]) .+ 1)[1:2*sum(fu[1])]

        ## << end of function definitions nested within calc_span_smooth()

        if fu[1] == [false]
            info(logger, "no fluorescence increase with temperature increase was detected: " *
                "using `span_smooth_default` $(i.span_smooth_default)")
            return i.span_smooth_default
        else
            info(logger, "fluorescence increase with temperature increase was detected")
            return larger_span(span_smooth_product())
        end ## if
    end ## calc_span_smooth()

    ## `fu_rle` - fluorescence up run length encoding
    "Find the region(s) where there is a positive gradient such that fluorescence
    increases with temperature."
    fu_rle() = calc_fu_rle(temps_in_span(max_fluo_decrease()))

    is_increasing(x ::AbstractVector) =
        diff(x) .> zero(x)

    calc_fu_rle(idc ::AbstractVector{Int_T}) =
        rle(is_increasing(fluos[idc]))

    "Find the region of length 2 * `temperature_bandwidth` showing the steepest
    fluorescence decrease between start and end."
    max_fluo_decrease() =
        indmax(fluo_decrease(temps_in_span(i)) for i in 1:len_raw)

    fluo_decrease(sel_idc_int ::AbstractVector{Int_T}) =
        fluos[sel_idc_int[1]] - fluos[sel_idc_int[end]]

    "Find nearby data points in a vector."
    find_in_span(
        X           ::AbstractVector,
        i           ::Int_T,
        half_span   ::Real
    ) =
        find(X) do x
            X[i] - half_span <= x <= X[i] + half_span
        end

    temps_in_span(i ::Int_T) =
        find_in_span(temps, i, i.temperature_bandwidth)

    ## smoothing functions >>

    "Truncate elements in a vector to the length of the shortest element."
    shorten(x) =
        x |> mold(index(x |> mold(length) |> minimum |> from(1)))

    "Model fluorescence as a cubic spline function of temperature using the Dierckx
    Fortran library. The default parameter `s = 0.0` interpolates without smoothing."
    spline_model(x) =
        Spline1D(shorten(x)...; k = 3)

    "Smooth raw fluorescence values."
    smooth_raw_fluo() =
        (temps, supsmu(temps, fluos, span_smooth / i.denser_factor))

    "Model fluorescence as a cubic spline function of temperature, then recalculates
    the fluorescence and its derivative with respect to temperature using a denser
    sequence of interpolated temperatures."
    smoothed_data_matrix() =
        hcat(
            ## collates processed, interpolated data into matrix
            ## note: memory intensive
            denser_temps,
            fluo_spl_blsub(spl(denser_temps)),
            negderiv_smu(-derivative(spl, denser_temps)))

    "Calculate baseline-subtracted spline-smoothed fluorescence data, and optionally
    smooth the output of the spline function."
    fluo_spl_blsub(fluo_spl ::AbstractVector{<: Float_T}) =
        ## assumes constant baseline == minimum fluorescence value
        sweep(minimum)(-)(
            ## optionally, smooth the output of the spline function
            i.smooth_fluo_spline ?
                supsmu(denser_temps, fluo_spl, span_smooth) :
                fluo_spl)

    "Calculate the negative derivative at interpolated temperatures and smooth
    the output using `supsmu`."
    negderiv_smu(negderiv ::AbstractVector{<: Float_T}) =
        supsmu(denser_temps, negderiv, span_smooth)

    ## note: DataArray format doesn't work for `derivative` by "Dierckx"
    "Create a dense sequence of interpolated temperature values."
    interpolated_temperatures() =
        Array(colon(
            min_temp,
            temp_span / (len_raw * i.denser_factor - 1),
            max_temp))

    ## peak finding functions >>

    "Find the indices in a vector where the value at the index equals the summary
    value of a sliding window centered at the index. This can be used to find local
    summits and nadirs (peaks and troughs) in a 1-dimensional data series."
    function find_local(
        summary_func    ::Function,
        vals            ::AbstractVector,
        half_width      ::Int_T,
    )
        vals_in_window(i ::Int_T) = vals_padded[i : i + half_width * 2]
        match_summary_val(v ::AbstractVector) = summary_func(v) == v[half_width + 1]
        #
        const padding = -summary_func(-vals) |> furnish(half_width)
        const vals_padded = [padding; vals; padding]
        vals |> length |> from(1) |> collect |>
            mold(match_summary_val ∘ vals_in_window) |> find
    end

    # half_peak_span_temperature = 0.5 * i.peak_span_temperature
    half_peak_window() =
        0.5 * (i.peak_span_temperature / temp_span) * len_denser |>
            roundoff(0) |> Int_T

    "Find the indices of summits and nadirs the smoothed -df/dT data series."
    find_summits_and_nadirs() =
        [maximum, minimum] |> mold(f -> find_local(f, negderiv_smu, half_peak_window()))

    summits_and_nadirs(sn_idc) =
        OrderedDict(
            zip([:summit, :nadir],
                sn_idc |> mold(idc -> smoothed_data[idc, :])))

    ## peak constructors used in find_peaks()
    make_peak(::Void) = nothing
    make_peak(element ::PeakIndicesElement) =
        Peak(
            element.summit_idx,                 ## summit_idx
            denser_temps[element.summit_idx],   ## temperature at peak
            peak_bounds(element) |> calc_area)  ## area

    "Iterate over summits and nadirs to create a vector of `Peak`s."
    function find_peaks(
        summit_idc      ::AbstractVector,
        nadir_idc       ::AbstractVector
    )
        const peak_finder =
            PeakIndices(
                negderiv_smu[summit_idc],
                summit_idc,
                nadir_idc)
        Vector{Peak}(peak_finder |> collect |> mold(make_peak) |> sift(thing))
    end ## find_peaks()

    "Find the shoulders of a peak."
    @inline function peak_bounds(element ::PeakIndicesElement)
        left_nadir_idx, summit_idx, right_nadir_idx =
            element |> fieldnames |> mold(curry(getfield)(element))
        # nadir_vec = [left_nadir_idx, right_nadir_idx]
        # low_nadir_idx, high_nadir_idx = map(
        #     func -> nadir_vec[func(negderiv_smu[nadir_vec])],
        #     [indmin, indmax])
        const (low_nadir_idx, high_nadir_idx) =
            (negderiv_smu[left_nadir_idx] < negderiv_smu[right_nadir_idx]) ?
                (left_nadir_idx, right_nadir_idx) :
                (right_nadir_idx, left_nadir_idx)
        const hn_ns = negderiv_smu[high_nadir_idx]
        #
        ## find the nearest location to `summit_idx`
        ## on the `low_nadir_idx` side of the peak
        ## where the line `negderiv = negderiv_smu[high_nadir_idx]`
        ## is crossed by the `negderiv_smu` curve
        idx_step = -1 + 2 * (summit_idx < low_nadir_idx)
        about2cross_idx = low_nadir_idx - idx_step ## peak slightly narrower than using actual crossing point
        idx = summit_idx
        negderiv_smu1 = negderiv_smu[summit_idx]
        limit_idx = low_nadir_idx - 2 * idx_step
        while (idx != limit_idx)
            negderiv_smu0 = negderiv_smu1
            idx1 = idx + idx_step
            negderiv_smu1 = negderiv_smu[idx1]
            if negderiv_smu1 <= hn_ns <= negderiv_smu0
                about2cross_idx = idx
                break
            end ## if
            idx = idx1
        end ## while
        return (high_nadir_idx, about2cross_idx)
    end ## peak_bounds()

    ## == integrated -df/dT peak area elevated from x-axis minus
    ## trapezium-shaped baseline area elevated from x-axis
    "Calculate the area of the peak above its baseline."
    @inline function calc_area(peak_bounds_idc ::Tuple{Integer, Integer})
        #
        area_func(temp_lo ::Real, temp_hi ::Real) =
            -sum(negderiv_smu[[peak_bounds_idc...]]) * 0.5 * (temp_hi - temp_lo) -
                (spl(temp_hi) - spl(temp_lo)) ## 'baseline' of peak
        #
        ordered_tuple(x, y) = (x < y) ? (x, y) : (y, x)
        #
        ## << end of function definitions nested in peak_area()

        # temp_lo, temp_hi = map(
        #     func -> func(denser_temps[peak_bound_idc]),
        #     [minimum, maximum])
        return area_func(ordered_tuple(denser_temps[[peak_bounds_idc...]]...)...)
    end ## calc_area()

    ## count cross points
    @inline function count_cross_points()
        ## vectorized version
        # num_cross_points = sum(map(1:(len_denser-1)) do i
        #     (negderiv_smu[i] - negderiv_midrange) * (negderiv_smu[i+1] - negderiv_midrange) <= 0
        # end)
        #
        ## devectorized version
        num_cross_points = 0
        negderiv_smu_centred1 = sign(negderiv_smu[1] - negderiv_midrange)
        local i = 0
        while (i < len_denser)
            i += 1
            negderiv_smu_centred0 = negderiv_smu_centred1
            negderiv_smu_centred1 = sign(negderiv_smu[i] - negderiv_midrange)
            if negderiv_smu_centred0 != negderiv_smu_centred1
                num_cross_points += 1
            end
        end ## while
        return num_cross_points
    end ## count_cross_points()

    split_vector_and_return_larger_quantile(
        x                   ::AbstractVector,
        len                 ::Integer,      ## == length(x)
        idx                 ::Integer,      ## 1 <= idx <= len
        q                   ::Float_T     ## 0 <= p <= 1
    ) = (1:idx, idx:len) |> mold(range -> quantile(x[range], q)) |> maximum

    ## note: largest_peak_idx calculated incorrectly in original code
    "Filter out small or randomly-occurring peaks."
    function peak_filter()
        ## function: normalize values to a range from 0 to 1
        normalize_range(x ::AbstractArray) =
            sweep(minimum)(-)(x) |> sweep(maximum)(/)
        #
        const largest_peak = first(area_order)
        if  (split_vector_and_return_larger_quantile(
                normalize_range(negderiv_smu), ## originally normalize_range(negderiv), but why ???
                len_denser,
                peaks_raw[largest_peak].idx, ## index of peak with largest area
                i.norm_negderiv_quantile) ## larger_normd_qtv_of_two_sides
                    > i.max_norm_negderiv) ||
            (count_cross_points() > min(i.max_num_cross_points, len_raw * i.noise_factor)) ||
            (linreg(temps, fluos)[2] >= 0.0) ## slope
            return []
        end ## if
        ## else
        #
        ## Disabled because it caused false suppression of Tm peak reporting for
        ## `db_name_ = "20160309_chaipcr"; exp_id_ = 7`, well A2.
        ## Needs to be enabled because it is the only criterion that
        ## suppress false reporting of not-real peaks in
        ## `db_name_ = "20161103_chaipcr_ip152"; exp_id_ = 45`, well A1
        # temperature_max_negderiv = denser_temps[max_negderiv_smu[2]]
        # largest_peak_idx = summit_idc[indmax(areas_raw)] ## peak with largest area
        # top1_from_max = abs(denser_temps[largest_peak_idx] - temperature_max_negderiv)
        # if (top1_from_max > top1_from_max_ub)
        #     return []
        # end
        #
        ## when all the peaks are noise, no peak is expected
        ## to have a substantially larger area than the other peaks.
        ## Provided `i.max_num_peaks + 1 < num_peaks`, this is observed as
        ## `areas_raw[area_order[i.max_num_peaks + 1]] >= area_lb`
        ## implying `length(filtered_idc_topNp1) > i.max_num_peaks`
        ## If `num_peaks >= i.max_num_peaks` there is no problem.
        const min_area = areas_raw[largest_peak] * i.min_normalized_area
        const largest_idc = area_order[min(i.max_num_peaks + 1, num_peaks) |> from(1)]
        const filtered_idc = largest_idc |> sift(idx -> areas_raw[idx] >= min_area)
        return length(filtered_idc) > i.max_num_peaks ? [] : filtered_idc
    end ## peak_filter()

    ## << end of function definitions nested in mc_peak_analysis()

    debug(logger, "at mc_peak_analysis()")
    #
    ## filter out data points separated by narrow temperature intervals
    ## return temperatures as array, assuming no missing values
    const (temps, fluos)    = df |> filter_too_close |> jitter_temps!
    const len_raw           = length(temps)
    #
    ## negative derivative by central finite differencing (cfd)
    ## only used if the data array is too short to find peaks
    if (len_raw <= 3)
        const slope = finite_diff(temps, fluos; nu = 1)
        return McPeakOutput(output_type;
            observed_data = i.reporting(hcat(temps, fluos, -slope)))
    end ## if
    #
    ## else
    const min_temp          = minimum(temps)
    const max_temp          = maximum(temps)
    const temp_span         = max_temp - min_temp
    #
    ## choose smoothing parameter
    const span_smooth       = choose_span_smooth()
    #
    ## fit a cubic spline model in order to interpolate data points
    ## then smooth data and calculate slope at denser sequence of temperatures
    const spl               = spline_model(smooth_raw_fluo())
    const denser_temps      = interpolated_temperatures()
    const smoothed_data     = smoothed_data_matrix()
    const negderiv_smu      = smoothed_data[:, 3]
    const max_negderiv_smu  = findmax(negderiv_smu)
    const negderiv_midrange =
        mean([quantile(negderiv_smu, i.negderiv_range_low_quantile), max_negderiv_smu[1]])
    #
    ## extract data at observed temperatures
    const len_denser        = length(denser_temps)
    const observed_data     = smoothed_data[1:i.denser_factor:len_denser, :]
    #
    ## find peak and trough locations
    ## `sn` - summits and nadirs
    const sn_idc            = find_summits_and_nadirs()
    const sn_dict           = summits_and_nadirs(sn_idc)
    #
    ## estimate area of peaks above baseline
    const peaks_raw         = find_peaks(sn_idc...)
    const num_peaks         = length(peaks_raw)
    #
    ## return smoothed data if no peaks

    if num_peaks == 0
        return output_type == McPeakLongOutput ?
			McPeakLongOutput(
                observed_data       = i.reporting(observed_data),
                smoothed_data       = smoothed_data,
                negderiv_midrange   = negderiv_midrange,
                extremes            = sn_dict) :
            McPeakShortOutput(
                observed_data       = i.reporting(observed_data))
    end ## if no peaks
    #
    ## keep only the biggest peak(s)
    const areas_raw = peaks_raw |> their(:area)
    const area_order = sortperm(areas_raw, rev = true)
    const peaks_filtered = peaks_raw[peak_filter()]
    return output_type == McPeakLongOutput ?
        McPeakLongOutput(
            i.reporting(observed_data),
            i.reporting(peaks_filtered),
            smoothed_data,
            negderiv_midrange,
            sn_dict,
            i.reporting(peaks_raw[area_order]),
            length(peaks_filtered) > 0) :
        McPeakShortOutput(
            i.reporting(observed_data),
            i.reporting(peaks_filtered))

end ## mc_peak_analysis()


#==============================================================================#


## function called by mc_peak_analysis() >>

"Jitter duplicated temperature values so that all the elements become unique."
function mutate_dups(
    vec_2mut        ::AbstractVector,
    jitter_constant ::Float_T,
)
    debug(logger, "at mutate_dups()")
    const vec_len       = vec_2mut |> length
    const vec_uniq      = vec_2mut |> unique |> sort
    const vec_uniq_len  = vec_uniq |> length
    ## return if no ties
    (vec_len == vec_uniq_len) && return vec_2mut
    ## find ties
    const order_to   = sortperm(vec_2mut)
    const order_back = sortperm(order_to)
    vec_sorted = (vec_2mut + 0.0)[order_to]
    const dups = find(diff(vec_sorted) .== 0.0) .+ 1
    ## calculate value of jitter
    const add1 = jitter * median(diff(vec_uniq))
    ## break ties
    accumulator1 = 0
    accumulator2 = 0
    local i
    for i in eachindex(dups)
        multiway_tie  = i > 1 && dups[i] - dups[i - 1] == 1
        accumulator1 += multiway_tie
        accumulator2  = multiway_tie ? accumulator2 : accumulator1
        rank = accumulator1 - accumulator2 + 1
        vec_sorted[dups[i]] += add1 * rank
    end
    return vec_sorted[order_back]
end ## mutate_dups()
