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
    field names >>
===============================================================================#

const KWARGS_AMP_KEYS =
    ["min_reliable_cyc", "baseline_cyc_bounds", "ctrl_well_dict",
        CQ_METHOD_KEY, CATEG_WELL_VEC_KEY]
const KWARGS_RCQ_KEYS_DICT = Dict(
    "min_fluomax"   => :max_bsf_lb,
    "min_D1max"     => :max_dr1_lb,
    "min_D2max"     => :max_dr2_lb)



#===============================================================================
    function definitions >>
===============================================================================#

## function called by dispatch()
## parse request body into AmpInput struct and call amp_analysis()
"Generic function called by `dispatch`."
function act(
    ::Type{Val{amplification}},
    req_dict        ::Associative;
    out_format      ::OutputFormat = DEFAULT_AMP_OUTPUT_FORMAT
)
    debug(logger, "at act(::Type{Val{amplification}})")
    #
    ## required data
    req_key = curry(haskey)(req_dict)
    if !raw_data_in_req(req_dict)
        return fail(logger, ArgumentError(
            "no raw data for amplification analysis in request")) |> out(out_format)
    end
    if !calibration_info_in_req(req_dict)
        return fail(logger, ArgumentError(
            "no calibration information in request")) |> out(out_format)
    end
    #
    ## parse data from request
    const parsed_raw_data = amp_parse_raw_data(req_dict[RAW_DATA_KEY])
    const calibration_data = CalibrationData(req_dict[CALIBRATION_INFO_KEY])
    #
    ## analysis parameters for model fitting
    const kw_amp = Dict{Symbol,Any}(
        map(KWARGS_AMP_KEYS |> sift(req_key)) do key
            if (key == CATEG_WELL_VEC_KEY)
                :categ_well_vec =>
                    map(req_dict[CATEG_WELL_VEC_KEY]) do x
                        const element = str2sym.(x)
                        (length(element[2]) == 0) ?
                            element :
                            Colon()
                    end ## do x
            elseif (key == CQ_METHOD_KEY)
                :cq_method => try
                    CqMethod(req_dict[CQ_METHOD_KEY])
                catch()
                    return fail(logger, ArgumentError("Cq method \"" *
                        req_dict[CQ_METHOD_KEY] * "\" not implemented");
                        bt = true) |> out(out_format)
                end ## try
            else
                Symbol(key) => str2sym.(req_dict[key])
            end ## if
        end) ## map
    #
    ## arguments for fit_baseline_model()
    const kw_bl =
        begin
            const baseline_method =
                req_key(BASELINE_METHOD_KEY) &&
               req_dict[BASELINE_METHOD_KEY]
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
    ## report_cq!() arguments
    const kw_rcq = Dict{Symbol,Any}(
        map(KWARGS_RCQ_KEYS_DICT |> keys |> collect |> sift(req_key)) do key
            KWARGS_RCQ_KEYS_DICT[key] => req_dict[key]
        end) ## map
    #
    ## create container for data and parameters
    ## to pass to amp_analysis()
    const interface = AmpInput(
        parsed_raw_data...,
        calibration_data;
        out_format = out_format,
        amp_output = AmpOutputOption(out_format),
        kw_bl...,
        kw_amp...,
        kw_rcq...,)
    const result = try
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
        # const asrp_vec = [AmpStepRampProperties(:ramp, req_dict[sr_key], DEFAULT_cyc_nums)]
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
        const first_sr_out = amp_analysis(interface)
        OrderedDict([
            map(fieldnames(first_sr_out)) do key
                key => getfield(first_sr_out, key)
            end...,
            :valid => true])
    catch err
        return fail(logger, err; bt = true) |> out(out_format)
    end ## try
    return result |> out(out_format)
end ## act(::Type{Val{amplification}})


## called by parse_req >>

@inline str2sym(x) = isa(x, String) ? Symbol(x) : x


#==============================================================================#


"Extract dimensions of raw amplification data, then format the raw data into a
3D array as required by `calibrate`."
function amp_parse_raw_data(raw_dict ::Associative)
    const (cycles, wells, channels) =
        map([CYCLE_NUM_KEY, WELL_NUM_KEY, CHANNEL_KEY]) do key
            raw_dict[key] |> unique ## in order of appearance
        end
    const (num_cycles, num_wells, num_channels) =
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
    catch()
        throw(ArgumentError("The format of the fluorescence data does not " *
            "lend itself to transformation into a 3-dimensional array. " *
            "Please make sure that the data are sorted by " *
            "channel, well, and cycle number."))
    end ## try
    #
    ## reshape to 3D array
    const F = eltype(first(raw_dict[FLUORESCENCE_VALUE_KEY]))
    const raw_data = ## formerly `fr_ary3`
        reshape(
            raw_dict[FLUORESCENCE_VALUE_KEY],
            num_cycles, num_wells, num_channels)
    #
    ## rearrange data in sort order of each index
    const cyc_perm  = sortperm(cycles)
    const well_perm = sortperm(wells)
    const chan_perm = sortperm(channels)
    #
    ## kludge to index well numbers starting at 0
    const kludge = sweep(minimum)(-)(wells)
    return (
        RawData{F}(raw_data[cyc_perm, well_perm, chan_perm]),
        num_cycles,
        num_wells,
        num_channels,
        cycles[cyc_perm] |> SVector{num_cycles,Int},
        kludge[well_perm] |> mold(Symbol ∘ Int) |> SVector{num_wells,Symbol},
        channels[chan_perm] |> SVector{num_channels,Int})
end ## amp_parse_raw_data()
