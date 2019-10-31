#===============================================================================

    amplification.jl

    parse data for amplification analysis from request body

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import DataStructures.OrderedDict
import StaticArrays: SVector
import Memento: debug



#===============================================================================
    function definitions >>
===============================================================================#

## function called by dispatch()
## parse request body into AmpInput struct and call amp_analysis()
"Generic function called by `dispatch`."
function act(
    ::Type{Val{amplification}},
    req             ::Associative;
    out_format      ::OutputFormat = DEFAULT_AMP_OUTPUT_FORMAT
)
    debug(logger, "at act(::Type{Val{amplification}})")
    #
    ## required fields
    @get_calibration_data_from_req(amplification)
    @parse_raw_data_from_req(amplification)
    #
    ## keyword arguments
    kwargs = AMP_FIELD_DEFS |>
        sift(req_key ∘ field(:key)) |>
        mold() do x
			if isa(req[x.key], Int64) && Int_T != Int64
				x.name => Int_T(req[x.key])
			else
				x.name => req[x.key]
			end
        end
    req_key(CQ_METHOD_KEY) &&
        push!(kwargs,
            :cq_method => try
                CqMethod(req[CQ_METHOD_KEY])
            catch()
                return ArgumentError("Unrecognized cq method")
            end) ## try
    req_key(CATEG_WELL_VEC_KEY) &&
        push!(kwargs,
            :categ_well_vec =>
                map(req[CATEG_WELL_VEC_KEY]) do x
                    element = str2sym.(x)
                    (length(element[2]) == 0) ?
                        element :
                        Colon()
                end) ## do x
    req_key(CTRL_WELL_DICT_KEY) &&
        push!(kwargs, :ctrl_well_dict => str2sym.(req[CTRL_WELL_DICT_KEY]))
    #
    ## baseline model parameters
    kw_bl =
        begin
            baseline_method =
                req_key(BASELINE_METHOD_KEY) &&
               req[BASELINE_METHOD_KEY]
            if      (baseline_method == SIGMOID_KEY)
                        Dict{Symbol,Any}(
                            :bl_method          =>  l4_enl,
                            :bl_fallback_func   =>  median)
            elseif  (baseline_method == LINEAR_KEY)
                        Dict{Symbol,Any}(
                            :bl_method          =>  lin_1ft,
                            :bl_fallback_func   =>  mean)
            elseif  (baseline_method == MEDIAN_KEY)
                        Dict{Symbol,Any}(
                            :bl_method          =>  take_the_median)
            else
                Dict{Symbol,Any}()
            end
        end
    #
    ## create container for data and parameters
    ## to pass to amp_analysis()
    interface = AmpInput(
        parsed_raw_data...,
        calibration_data;
        out_format = out_format,
        amp_output = AmpOutputOption(out_format),
        kw_bl...,
        kwargs...,)
    result =
        ## issues:
        ## 1.
        ## the new code currently assumes only 1 step/ramp
        ## because as the request body is currently structured
        ## we cannot subset the fluorescence data by step_id/ramp_id
        ## 2.
        ## need to verify that the fluorescence data complies
        ## with the constraints imposed by max_cycle and well_constraint
        #
        # const sr_key =
        #     if      req_key(STEP_ID_KEY) STEP_ID_KEY
        #     elseif  req_key(RAMP_ID_KEY) RAMP_ID_KEY
        #     else throw(ArgumentError("no step/ramp information found"))
        #     end
        # const asrp_vec = [AmpStepRampProperties(:ramp, req[sr_key], DEFAULT_cyc_nums)]
        # const sr_dict =
        #     OrderedDict(
        #         map([ asrp_vec[1] ]) do asrp
        #             join([asrp.step_or_ramp, asrp.id], "_") =>
        #                 amp_analysis(
        #                     # remove MySql dependency
        #                     # db_conn, exp_id, asrp, calib_info,
        #                     # fluo_well_nums, well_nums,
        #                     amp,
        #                     asrp,
        #                     out_format == json_output ? pre_json_output : out_format))
        #         end) ## do asrp
        # ## output
        # if (out_sr_dict)
        #     final_out = sr_dict
        # else
        #     const first_sr_out = first(values(sr_dict))
        #     final_out =
        #         OrderedDict(
        #             map(fieldnames(first_sr_out)) do key
        #                 key => getfield(first_sr_out, key)
        #             end)
        # end
        first_sr_out = amp_analysis(interface)
        OrderedDict([
            map(fieldnames(first_sr_out)) do key
                key => getfield(first_sr_out, key)
            end...,
            :valid => true])
    return result |> out(out_format)
end ## act(::Type{Val{amplification}})


## called by parse_req >>

@inline str2sym(x) = isa(x, String) ? Symbol(x) : x


#==============================================================================#


"Extract dimensions of raw amplification data, then format the raw data into a
3D array as required by `calibrate`."
function parse_raw_data(::Type{Val{amplification}}, raw_dict ::Associative)
    (cycles, wells, channels) =
        map([CYCLE_NUM_KEY, WELL_NUM_KEY, CHANNEL_KEY]) do key
            raw_dict[key] |> unique ## in order of appearance
        end
    (num_cycles, num_wells, num_channels) =
        map(length, (cycles, wells, channels))
    #
    ## check that data are sorted and conformable to 3D array
    try
        assert(raw_dict[CYCLE_NUM_KEY] ==
            repeat(
                cycles,
                outer = num_wells * num_channels))
        assert(raw_dict[WELL_NUM_KEY ] ==
            repeat(
                wells,
                inner = num_cycles,
                outer = num_channels))
        assert(raw_dict[CHANNEL_KEY  ] ==
            repeat(
                channels,
                inner = num_cycles * num_wells))
    catch err
		error(logger, "raw dict exception: " * sprint(showerror, err))
        throw(ArgumentError("The format of the fluorescence data does not " *
            "lend itself to transformation into a 3-dimensional array. " *
            "Please make sure that the data are sorted by " *
            "channel, well, and cycle number."))
    end ## try
    #
    ## reshape to 3D array
    F = eltype(first(raw_dict[FLUORESCENCE_VALUE_KEY]))
	if (F == Int64 && Int_T != Int64)
		F = Int_T
	end
    raw_data = ## formerly `fr_ary3`
        reshape(
            raw_dict[FLUORESCENCE_VALUE_KEY],
            num_cycles, num_wells, num_channels)
    #
    #
    ## kludge to index well numbers starting at 0
    return (
        RawData{F}(raw_data[cycles, wells, channels]),
        Int_T(num_cycles),
        Int_T(num_wells),
        Int_T(num_channels),
        cycles[cycles] |> SVector{num_cycles,Int_T},
        wells |> mold(Symbol ∘ Int_T) |> SVector{num_wells,Symbol},
        channels[channels] |> SVector{num_channels,Int_T})
end ## parse_raw_data(Type{Val{amplification}})
