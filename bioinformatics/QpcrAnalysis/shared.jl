## functions used by multiple analytic methods

import DataStructures.OrderedDict
import Base: getindex
# import Iterators.filter


## using suggestion of MikeInnes https://github.com/JuliaLang/julia/issues/5571#issuecomment-446321504
## overload :[ operator to enable function composition by piping with arguments
## e.g. dict |> values |> map[function] |> reduce[vcat]

getindex(f ::Function, x...) = (y...) -> f(x..., y...)

## synonyms for getindex
index(i,x)  = getindex(x,i)
subset(i,x) = getindex(x,i)

## synonym for getfield
field(f,x)  = getfield(x,f)

## unused functions
inc_index(i ::Integer, len ::Integer) = (i >= len) ? len : i + 1
dec_index(i ::Integer) = (i <= 1) ? 1 : i - 1

## unused function
## curried function
## returns true when data == value, false otherwise
selector(value ::Integer) =
    data ::AbstractArray -> (data .== value)

## used in amp.jl
str2sym(x) = typeof(x) == String ? Symbol(x) : x

## used in adj_w2wvaf.jl
## used in meltcrv.jl
## used in deconv.jl
sweep(summary_func) = sweep_func -> (x -> sweep_func.(x, summary_func(x)))

## used in meltcrv.jl
## normalize values to a range from 0 to 1
normalize_range(x ::AbstractArray) =
    sweep(minimum)(-)(x) |> sweep(maximum)(/)

## used in meltcrv.jl       
## used in shared.jl
thing(x) = x != nothing

## used in standard_curve.jl
## transform `nothing` to NaN
function nothing2NaN(input)
    return isa(input, Void) ? NaN : input
end

## used in standard_curve.jl
## transform a real number to scientific notation
function scinot(x ::Real, num_sig_digits ::Integer=3; log_base ::Integer=10)
    if isnan(x)
        return (NaN, NaN)
    elseif x == 0
        return (0, 0)
    end
    exponent = floor(log(log_base, abs(x)))
    mantissa = round(x / log_base ^ exponent, num_sig_digits)
    return (mantissa, Int(exponent))
end

## used in meltcrv.jl
is_increasing(x ::AbstractVector) =
    x[1:end-1] .< x[2:end]

## used in meltcrv.jl
## truncate elements to length of shortest element
shorten(x...) =
    map(y -> y[range(1, x |> map[length] |> minimum)], x)

## used in meltcrv.jl
## extend vector with NaN values to a specified length
extend_NaN(len ::Integer, vec ::AbstractVector) =
    len - length(vec) |>
        m -> 
            m >= 0 ?
                (m |> fill[NaN] |> vcat[vec]) :
                error("vector is too long")

## extend array elements with NaNs to length of longest element
extend(x ::AbstractArray) =
    map(extend_NaN[(x |> map[length] |> maximum)], x)

## used in meltcrv.jl
## used in pnmsmu.jl
# find nearby data points in vector
# `giis` - get indices in span
function giis_uneven(
    X      ::AbstractVector,
    i      ::Integer,
    span_x ::Real
)
    return find(X) do x
        X[i] - span_x <= x <= X[i] + span_x
    end
end

## find the indices in a vector
## where the value at the index equals the summary
## value of the sliding window centering at the index
## (window width = number of data points in the whole window).
## can be used to find local summits and nadirs
function find_mid_sumr_bysw(
    vals       ::AbstractVector,
    half_width ::Integer,
    sumr_func  ::Function =maximum
)
    vals_iw(i ::Integer) = vals_padded[i : i + half_width * 2]
    #
    const padding = fill(-sumr_func(-vals), half_width)
    const vals_padded = [padding; vals; padding]
    vals |> length |> range[1] |> collect |> map[vals_iw] |> 
        map[v -> sumr_func(v) == v[half_width + 1]] |> find
end

## used in meltcrv.jl
ordered_tuple(x, y) = (x < y) ? (x, y) : (y, x)

## used in meltcrv.jl
function split_vector_and_return_larger_quantile(
    x                   ::AbstractVector,
    len                 ::Integer,          # == length(x)
    idx                 ::Integer,          # 1 <= idx <= len
    p                   ::AbstractFloat     # 0 <= p <= 1
)
    (1:idx, idx:len) |>
        map[range -> quantile(x[range], p)] |>
        maximum
end

## used in meltcrv.jl
report(digits ::Int, x) = round.(x, digits)

## functions
## moved to MySQLforQpcrAnalysis.jl: get_mysql_data_well

# construct DataFrame from dictionary key and value vectors
# `dict_keys` need to be a vector of strings
# to construct DataFrame column indices correctly
function dictvec2df(dict_keys ::AbstractVector, dict_values ::AbstractVector) 
    df = DataFrame()
    for dict_key in dict_keys
        df[Symbol(dict_key)] = map(
            dict_ele -> dict_ele[dict_key], 
            dict_values)
    end
    return df
end

## used in adj_w2wvaf.jl
num_channels(fluos ::AbstractArray) =
    (length(fluos) > 1) && (fluos[2] != nothing) ? 2 : 1

num_channels(calib ::Associative) =
    calib |>
        keys |>
        map[key -> num_channels(calib[key]["fluorescence_value"])] |>
        maximum

## used in calib.jl
num_wells(fluos ::AbstractArray) =
    fluos |> filter[thing] |> map[length] |> maximum

num_wells(calib ::Associative) =
    calib |>
        keys |>
        collect |>
        # Iterators.filter[key -> haskey(calib[key],"fluorescence_value")] |>
        filter[key -> haskey(calib[key],"fluorescence_value")] |>
        map[key -> num_wells(calib[key]["fluorescence_value"])] |>
        maximum

# duplicated in MySQLforQpcrAnalysis.jl
get_ordered_keys(dict ::Dict) =
    dict |> keys |> collect |> sort
    
get_ordered_keys(ordered_dict ::OrderedDict) =
    ordered_dict |> keys |> collect

# parse AbstractFloat on BBB
function parse_af{T<:AbstractFloat}( ::Type{T}, strval ::String)
    str_parts = split(strval, '.')
    float_parts = map(str_part -> Base.parse(Int32, str_part), str_parts)
    return float_parts[1] + float_parts[2] / 10^length(str_parts[2])
end

# print with verbose control
function print_v(
    print_func ::Function,
    verbose ::Bool,
    args...;
    kwargs...
)
    if verbose
        print_func(args...; kwargs...)
    end
    return nothing
end

# unused function
# repeat n times: take the output of an function and use it as the input for the same function
function redo(
    func ::Function,
    input,
    times ::Integer,
    extra_args...;
    kwargs...
)
    output = input
    while times > 0
        output = func(output, extra_args...; kwargs...)
        times -= 1
    end
    return output
end


# unused function
#
# reshape a layered vector into a multi-dimension array
# where outer layer is converted to higher dimension
# and each element has `num_layers_left` layers left
# (e.g. each element is atomic / not an array when `num_layers_lift == 0`,
# a vector of atomic elements when `num_layers_lift == 1`,
# vector of vector of atomic elements when `num_layers_lift == 2`).
function reshape_lv(
    layered_vector ::AbstractVector,
    num_layers_left ::Integer=0
)
    md_array = copy(layered_vector) # safe in case `eltype(layered_vector) <: AbstractArray`
    while redo(eltype, md_array, num_layers_left + 1) <: AbstractArray
        md_array = reshape(
            cat(2, md_array...),
            length(md_array[1]),
            size(md_array)...)
    end
    return md_array
end

# legacy function
# deprecated to remove MySql dependency
#
# function: check whether a value different from `calib_info_AIR` is passed onto `calib_info`
# if not, use `exp_id` to find calibration experiment in MySQL database
# and assumes water "step_id"=2, signal "step_id"=4, using FAM to calibrate all the channels.
function ensure_ci(

    ## remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # calib_info ::Union{Integer,OrderedDict}=calib_info_AIR,

    # new >>
    calib_data ::OrderedDict{String,Any},
    # << new

    # use calibration data from experiment `calib_info_AIR` by default
    exp_id::Integer=calib_info_AIR
)
    # new >>
    # not implemented yet
    return calib_data
    # << new

    if isa(calib_info, Integer)

        if calib_info == calib_info_AIR
            calib_id = MySQL.mysql_execute(
                db_conn,
                "SELECT calibration_id FROM experiments WHERE id=$exp_id"
            )[1][:calibration_id][1]
        else
            calib_id = calib_info
        end

        step_qry = "SELECT step_id FROM fluorescence_data WHERE experiment_id=$calib_id"
        step_ids = sort(unique(MySQL.mysql_execute(db_conn, step_qry)[1][:step_id]))

        calib_info = OrderedDict(
            "water" => OrderedDict(
                "calibration_id" => calib_id,
                "step_id" => step_ids[1]))

        for i in 2:(length(step_ids))
            calib_info["channel_$(i-1)"] = OrderedDict(
                "calibration_id" => calib_id,
                "step_id" => step_ids[i])
        end # for

        channel_qry = "SELECT channel FROM fluorescence_data WHERE experiment_id=$calib_id"
        channels = sort(unique(MySQL.mysql_execute(db_conn, channel_qry)[1][:channel]))

        for channel in channels
            channel_key = "channel_$channel"
            if !(channel_key in keys(calib_info))
                calib_info[channel_key] = OrderedDict(
                    "calibration_id" => calib_id,
                    "step_id" => step_ids[2])
            end # if
        end # for

    end # if isa(calib_info, Integer)

    return calib_info

end # ensure_ci




# legacy function
# deprecated to remove MySql dependency
#
# function get_mysql_data_well(
#     well_nums ::AbstractVector, # must be sorted in ascending order
#     qry_2b ::String, # must select "well_num" column
#     db_conn ::MySQL.MySQLHandle,
#     verbose ::Bool,
# )
#
#     well_nums_str = join(well_nums, ',')
#     print_v(println, verbose, "well_nums: $well_nums_str")
#     well_constraint = (well_nums_str == "") ? "" : "AND well_num in ($well_nums_str)"
#     qry = replace(qry_2b, "well_constraint", well_constraint)
#     found_well_namedtuple = MySQL.mysql_execute(db_conn, qry)[1]
#     found_well_nums = sort(unique(found_well_namedtuple[:well_num]))
#     return (found_well_namedtuple, found_well_nums)
# end





#
