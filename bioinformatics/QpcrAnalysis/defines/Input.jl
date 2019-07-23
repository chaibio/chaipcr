#===============================================================================

    Input.jl

    abstract type for data and analysis parameters
    and methods for both AmpImput and McInput structs

    Author: Tom Price
    Date:   July 2019

===============================================================================#



#===============================================================================
    type definition >>
===============================================================================#

abstract type Input end



#===============================================================================
    function definitions >>
===============================================================================#

"Parse data from request into Dict of keywords."
function parse_req_dict!(
	action 		::Action,
	kwargs 		::Associative,
	req_dict 	::Associative
)
	for key in keys(req_dict)
	    const parsed_field = try
	        parse_req(Val{action}, Val{Symbol(key)}, key, req_dict[key])
	    catch err
	        return fail(logger, err; bt = true) |> out(out_format)
	    end ## try
	    (parsed_field === nothing) &&
	        info(logger, "ignored field \"$key\" in request data") 
	    add_pairs!(kwargs, parsed_field)
	end ## next key
	return kwargs
end ## parse_req_dict()


#==============================================================================#


## parse_req methods for both Type{Val{amplification}} and Type{Val{meltcurve}}
parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:calibration_info}},
    key     ::AbstractString,
    value   ::Associative
) =
    :calibration_data =>
        try
            CalibrationData(value)
        catch()
            throw(ArgumentError("could not parse calibration data"))
        end ## try

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:experiment_id}},
    key     ::AbstractString,
            ::Any
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:stage_id}},
    key     ::AbstractString,
            ::Any
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:step_id}},
    key     ::AbstractString,
            ::Any
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:ramp_id}},
    key     ::AbstractString,
            ::Any
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:channel_nums}},
    key     ::AbstractString,
            ::Any
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Any},
    key     ::AbstractString,
            ::Any
) =
    throw(ArgumentError("field \"$key\" in request body not recognized"))
