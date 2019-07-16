#==============================================================================================

    shared_functions.jl

    functions used by multiple analytic methods
    
==============================================================================================#

import DataStructures.OrderedDict
import Memento: debug, warn, error, Logger


## used in amplification.jl
## used in shared_functions.jl
## currying function
@inline curry(f) = x -> (y...) -> f(x, y...)

## used in amplificatcion.jl
## used in shared_functions.jl
## used in melting_curve.jl
## used in optical_test_dual_channel.jl
mold   = curry(map)         ## mold(f)   = x -> map(f, x)

## used in amplification.jl
## used in shared_functions.jl
## used in melting_curve.jl
## used in deconvolute.jl
sift   = curry(filter)      ## sift(f)   = x -> filter(f, x)

## used in melting_curve.jl
## used in shared_functions.jl
cast   = curry(broadcast)   ## cast(f)   = x -> broadcast(f, x)

## used in calibration.jl
## used in shared_functions.jl
from   = curry(range)       ## from(b)   = e -> range(b, e)

## used in amplification.jl
## used in allelic_discrimination.jl
gather = curry(reduce)      ## gather(f) = x -> reduce(f, x)

## used in amplification.jl
bless  = curry(convert)     ## bless(T)  = x -> convert(T, x)

## used in shared_functions.jl
## flip function
@inline flip(f)  = x -> (y...) -> f(y..., x)

## used in amplification.jl
## used in melting_curve.jl
## thermal_consistency.jl
field = flip(getfield)  ## field(f) = x -> getfield(x, f)

## used in amplification.jl
## used in melting_curve.jl
index = flip(getindex)  ## index(i) = x -> getindex(x, i)

## used in amplification.jl
morph(d...) = x -> reshape(x, d...)

## used in allelic_discrimination.jl
## used in mc_peak_analysis.jl
furnish(d...) = x -> fill(x, d...)

## used in amplification.jl
## used in allelic_discrimination.jl
## used in melting_curve.jl
moose(f, g) = x -> mapreduce(f, g, x)

## used in amplification.jl
## used in melting_curve.jl
## curried reporter function, flipped
report(digits ::Integer, x) = round(x, digits)
roundoff(digits ::Integer) = cast(curry(report))(digits)
const JSON_DIGITS = 6 ## number of decimal points for floats in JSON output

@inline out(out_format ::OutputFormat) =
    output -> (out_format == json) ? JSON.json(output) : output

@inline get_ordered_keys(dict ::Dict) =
    dict |> keys |> collect |> sort

@inline get_ordered_keys(ordered_dict ::OrderedDict) =
    ordered_dict |> keys |> collect

## used in melting_curve.jl
## used in mc_peak_analysis.jl
## used in deconvolution.jl
## used in optical_test_dual_channel.jl
sweep(summary_func) = sweep_func -> x -> broadcast(sweep_func, x, summary_func(x))

## used in melting_curve.jl
## used in shared_functions.jl
# thing(x) = !(x == nothing)
## NB cannot inline this because compiler does not recognize it as a function
thing = (!isequal)(nothing)

## used in amplification.jl
## used in melting_curve.jl
## used in optical_cal.jl
## used in thermal_consistency.jl
function fail(
    logger      ::Logger,
    err         ::Exception;
    bt          ::Bool = false ## backtrace?
)
    const err_msg = sprint(showerror, err)
    if bt
        const st = stacktrace(catch_backtrace())
    end
    try
        error(logger, err_msg)
    catch() ## just report the error
        if bt
            const stl = collect(enumerate(IndexStyle(st), st))
            try
                error(logger, "error thrown in " *
                    string(st[1]) * "\nStacktrace:\n" *
                    join(
                        map(stl[1:end]) do tup
                            index, ptr = tup
                            " [$index] $ptr\n"
                        end))
            catch()
            end ## try
        end ## if bt
    end ## try
    OrderedDict(
        :valid => false,
        :error => err_msg)
end ## fail()

## used in amplification.jl
## used in melting_curve.jl
## finite differencing function
function finite_diff(
    X       ::AbstractVector,
    Y       ::AbstractVector; ## X and Y must be of same length
    nu      ::Integer = 1, ## order of derivative
    method  ::FiniteDiffMethod = central
)
    debug(logger, "at finite_diff()")
    const dlen = length(X)
    if dlen != length(Y)
        throw(DimensionError, "X and Y must be of same length")
    end ## if
    (dlen == 1) && return zeros(1)
    if (nu == 1)
        const (range1, range2) =
            if      (method == central)  tuple(3:dlen+2, 1:dlen)
            elseif  (method == forward)  tuple(3:dlen+2, 1:dlen+1)
            elseif  (method == backward) tuple(2:dlen+1, 1:dlen)
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

## used in standard_curve.jl
## transform a real number to scientific notation
function scinot(
    x               ::Real,
    num_sig_digits  ::Integer = 3;
    log_base        ::Integer = 10
)
    isnan(x) && return (NaN, NaN)
    (x == 0) && return (0, 0)
    _exponent = log(log_base, abs(x)) |> floor
    _mantissa = round(x / log_base ^ _exponent, num_sig_digits)
    return (_mantissa, Int(_exponent))
end

## used in melting_curve.jl
## extend vector with NaN values to a specified length
## curried function
extend_NaN(len ::Integer) =
    vec ::AbstractVector ->
        len - length(vec) |>
            m ->
                m >= 0 ?
                    vcat(vec, fill(NaN, m)) :
                    error(logger, "vector is too long")

## used in calibration.jl
import Base.length
length(::Void) = 0
@inline num_wells(fluos ::AbstractArray) =
    fluos |> mold(length) |> maximum

## parse AbstractFloat on BBB
function parse_af{T<:AbstractFloat}( ::Type{T}, strval ::String)
    str_parts = split(strval, '.')
    float_parts = map(str_part -> Base.parse(Int32, str_part), str_parts)
    return float_parts[1] + float_parts[2] / 10^length(str_parts[2])
end

## print with verbose control
## deprecated in favour of Memento.info()
## still used in test functions
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

## unused function
## repeat n times: take the output of an function and use it as the input for the same function
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

## unused functions
# inc_index(i ::Integer, len ::Integer) = (i >= len) ? len : i + 1
# dec_index(i ::Integer) = (i <= 1) ? 1 : i - 1

## unused function
#
## reshape a layered vector into a multi-dimension array
## where outer layer is converted to higher dimension
## and each element has `num_layers_left` layers left
## (e.g. each element is atomic / not an array when `num_layers_lift == 0`,
## a vector of atomic elements when `num_layers_lift == 1`,
## vector of vector of atomic elements when `num_layers_lift == 2`).
# function reshape_lv(
#     layered_vector ::AbstractVector,
#     num_layers_left ::Integer=0
# )
#     md_array = copy(layered_vector) # safe in case `eltype(layered_vector) <: AbstractArray`
#     while redo(eltype, md_array, num_layers_left + 1) <: AbstractArray
#         md_array = reshape(
#             cat(2, md_array...),
#             length(md_array[1]),
#             size(md_array)...)
#     end
#     return md_array
# end

## legacy function
## deprecated to remove MySql dependency
#
## function: check whether a value different from `calib_info_AIR` is passed onto `calib_info`
## if not, use `exp_id` to find calibration experiment in MySQL database
## and assumes water "step_id"=2, signal "step_id"=4, using FAM to calibrate all the channels.
# function ensure_ci(
#
#     ## remove MySql dependency
#     #
#     # db_conn ::MySQL.MySQLHandle,
#     # calib_info ::Union{Integer,OrderedDict}=calib_info_AIR,
#
#     ## new >>
#     calib_data  ::OrderedDict{String,Any},
#     ## << new
#
#     ## use calibration data from experiment `calib_info_AIR` by default
#     exp_id      ::Integer ##=calib_info_AIR
# )
#     if isa(calib_info, Integer)
#
#         if calib_info == calib_info_AIR
#             calib_id = MySQL.mysql_execute(
#                 db_conn,
#                 "SELECT calibration_id FROM experiments WHERE id=$exp_id"
#             )[1][:calibration_id][1]
#         else
#             calib_id = calib_info
#         end
#
#         step_qry = "SELECT step_id FROM fluorescence_data WHERE experiment_id=$calib_id"
#         step_ids = sort(unique(MySQL.mysql_execute(db_conn, step_qry)[1][:step_id]))
#
#         calib_info = OrderedDict(
#             "water" => OrderedDict(
#                 "calibration_id" => calib_id,
#                 "step_id" => step_ids[1]))
#
#         for i in 2:(length(step_ids))
#             calib_info["channel_$(i-1)"] = OrderedDict(
#                 "calibration_id" => calib_id,
#                 "step_id" => step_ids[i])
#         end ## for
#
#         channel_qry = "SELECT channel FROM fluorescence_data WHERE experiment_id=$calib_id"
#         channels = sort(unique(MySQL.mysql_execute(db_conn, channel_qry)[1][:channel]))
#
#         for channel in channels
#             channel_key = "channel_$channel"
#             if !(channel_key in keys(calib_info))
#                 calib_info[channel_key] = OrderedDict(
#                     "calibration_id" => calib_id,
#                     "step_id" => step_ids[2])
#             end ## if
#         end ## for
#     end ## if isa(calib_info, Integer)
#     return calib_info
# end ## ensure_ci


## legacy function
## deprecated to remove MySql dependency
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

## functions
## moved to MySQLforQpcrAnalysis.jl: get_mysql_data_well

## construct DataFrame from dictionary key and value vectors
## `dict_keys` need to be a vector of strings
## to construct DataFrame column indices correctly
# function dictvec2df(
#     dict_keys           ::AbstractVector,
#     dict_values         ::AbstractVector
# )
#     df = DataFrame()
#     for dict_key in dict_keys
#         df[Symbol(dict_key)] = map(index(dict_key), dict_values)
#     end
#     return df
# end

## simple macros
# macro when(predicate, conditional)
#     return :(if ($predicate)
#         ($conditional)
#     end)
# end
# macro unless(predicate, conditional)
#     return :(if !($predicate)
#         ($conditional)
#     end)
# end
