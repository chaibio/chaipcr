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
	req_dict 	::Associative,
)
	for key in keys(req_dict)
	    const parsed_field =
	        parse_req(Val{action}, Val{Symbol(key)}, key, req_dict)
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
    req_dict::Associative,
) =
    :calibration_data =>
        try
            CalibrationData(req_dict[key])
        catch()
            throw(ArgumentError("could not parse calibration data"))
        end ## try

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:experiment_id}},
    key     ::AbstractString,
    req_dict::Associative,
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:stage_id}},
    key     ::AbstractString,
    req_dict::Associative,
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:step_id}},
    key     ::AbstractString,
    req_dict::Associative,
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:ramp_id}},
    key     ::AbstractString,
    req_dict::Associative,
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Val{:channel_nums}},
    key     ::AbstractString,
    req_dict::Associative,
) = nothing

parse_req(
            ::Union{Type{Val{amplification}},Type{Val{meltcurve}}},
            ::Type{Any},
    key     ::AbstractString,
    req_dict::Associative,
) =
    throw(ArgumentError("field \"$key\" in request body not recognized"))
