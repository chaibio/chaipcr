## amplification.jl
##
## amplification analysis
##
## issue:
## the code assumes only 1 step/ramp because the current data format
## does not allow us to break the fluorescence data down by step_id/ramp_id

import JSON: parse
import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver
import Memento: debug, warn, error
using Ipopt


## field names
const KWARGS_RC_KEYS_DICT = Dict(
    "min_fluomax"   => :max_bsf_lb,
    "min_D1max"     => :max_dr1_lb,
    "min_D2max"     => :max_dr2_lb)
const KWARGS_AMP_KEYS =
    ["min_reliable_cyc", "baseline_cyc_bounds", "ctrl_well_dict",
        CQ_METHOD_KEY, CATEG_WELL_VEC_KEY]


## function definitions >>

## function called by dispatch()
-## parses request body into Amp struct and calls amp_process_1sr()
function act(
    ::Type{Val{amplification}},
    req_dict        ::Associative;
    out_format      ::OutputFormat = pre_json
)
    debug(logger, "at act(::Type{Val{amplification}})")
    const parsed_raw_data = try
        amp_parse_raw_data(req_dict)
    catch err
        return fail(logger, err; bt=true) |> out(out_format)
    end ## try        
    ## calibration data is required
    req_key = curry(haskey)(req_dict)
    if !(req_key(CALIBRATION_INFO_KEY) &&
        typeof(req_dict[CALIBRATION_INFO_KEY]) <: Associative)
            return fail(logger, ArgumentError(
                "no calibration information found")) |> out(out_format)
    end
    const calibration_data = CalibrationData(req_dict[CALIBRATION_INFO_KEY])
    ## amp_process_1sr() arguments
    const kwargs_amp = Dict{Symbol,Any}(
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
                        bt=true) |> out(out_format)
                end ## try        
            else
                Symbol(key) => str2sym.(req_dict[key])
            end ## if
        end) ## map
    ## arguments for fit_baseline_model()
    const kwargs_bl =
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
                            :bl_method          =>  median)
            else
                Dict{Symbol,Any}()
            end
        end
    ## report_cq!() arguments
    const kwargs_rc = Dict{Symbol,Any}(
        map(KWARGS_RC_KEYS_DICT |> keys |> collect |> sift(req_key)) do key
            KWARGS_RC_KEYS_DICT[key] => req_dict[key]
        end) ## map
    ## create container for data and parameters
    ## to pass to amp_process_1sr
    const amp = AmpInput(
        parsed_raw_data...,
        calibration_data,
        IpoptSolver(print_level = 0, max_iter = 35),
        "",
        DEFAULT_AMP_DCV && parsed_raw_data[4] > 1, ## dcv && num_channels > 1
        DEFAULT_AMP_MODEL,
        # true,
        AmpOutputOption(out_format),
        roundoff(JSON_DIGITS);
        kwargs_bl...,
        kwargs_amp...,
        kwargs_rc...,)
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
        #                 amp_process_1sr(
        #                     # remove MySql dependency
        #                     # db_conn, exp_id, asrp, calib_info,
        #                     # fluo_well_nums, well_nums,
        #                     amp,
        #                     asrp,
        #                     out_format == :json ? :pre_json : out_format)) ## out_format_1sr
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
        final_out = amp_process_1sr(amp)
        final_out[:valid] = true
        final_out        
    catch err
        return fail(logger, err; bt=true) |> out(out_format)
    end ## try
    return result |> out(out_format)
end ## act(::Type{Val{amplification}})


## extract dimensions of raw amplification data
## and format into a 3D array
function amp_parse_raw_data(req_dict ::Associative)
    const (cyc_nums, fluo_well_nums, channel_nums) =
        map([CYCLE_NUM_KEY, WELL_NUM_KEY, CHANNEL_KEY]) do key
            req_dict[RAW_DATA_KEY][key] |> unique             ## in order of appearance
        end
    const (num_cycs, num_fluo_wells, num_channels) =
        map(length, (cyc_nums, fluo_well_nums, channel_nums))
    try
        assert(req_dict[RAW_DATA_KEY][CYCLE_NUM_KEY] ==
            repeat(
                cyc_nums,
                outer = num_fluo_wells * num_channels))
        assert(req_dict[RAW_DATA_KEY][WELL_NUM_KEY ] ==
            repeat(
                fluo_well_nums,
                inner = num_cycs,
                outer = num_channels))
        assert(req_dict[RAW_DATA_KEY][CHANNEL_KEY  ] ==
            repeat(
                channel_nums,
                inner = num_cycs * num_fluo_wells))
    catch()
        throw(AssertionError("The format of the fluorescence data does not " *
            "lend itself to transformation into a 3-dimensional array. " *
            "Please make sure that it is sorted by channel, well number, and cycle number."))
    end ## try
    const F = typeof(req_dict[RAW_DATA_KEY][FLUORESCENCE_VALUE_KEY][1])
    const raw_data = ## formerly `fr_ary3`
        reshape(
            req_dict[RAW_DATA_KEY][FLUORESCENCE_VALUE_KEY],
            num_cycs, num_fluo_wells, num_channels)
    ## rearrange data in sort order of each index
    const cyc_perm  = sortperm(cyc_nums)
    const well_perm = sortperm(fluo_well_nums)
    const chan_perm = sortperm(channel_nums)
    return (
        AmpRawData{F}(raw_data[cyc_perm, well_perm, chan_perm]),
        num_cycs,
        num_fluo_wells,
        num_channels,
        cyc_nums[cyc_perm],
        fluo_well_nums[well_perm],
        channel_nums[chan_perm])
end ## amp_parse_raw_data()
