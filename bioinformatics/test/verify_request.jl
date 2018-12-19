# verify_request.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# This Julia script tests the JSON data structures 
# that are supplied in the body of GET requests
# 
# *     based on documentation of REST API from juliaapi_new.txt
#
# *     Julia listens on http://localhost:8081 via HttpServer.jl and dispatch.jl
#       and sends responses to the Rails app on http://localhost:3000
#
# *     the relevant controller in the Rails app is
#       chaipcr/web/app/controllers/experiments_controller.rb
#
# *     currently calls are POST-ed to
#       http://127.0.0.1:8081/experiments/#{experiment.id}/standard_curve
#       http://127.0.0.1:8081/experiments/#{experiment.id}/amplification
#       http://127.0.0.1:8081/experiments/#{experiment.id}/meltcurve
#       http://127.0.0.1:8081/experiments/#{experiment.id}/analyze

import JSON, DataStructures.OrderedDict
import FactCheck: @fact, facts, convert, getindex, clear_results, setstyle

FactCheck.setstyle(:default)

# ================================================================================
# Here are the REST APIs using HTTP GET
# ================================================================================

# ********************************************************************************
#
# call: experiments/:experiment_id/standard_curve
#
# ********************************************************************************

function verify_request(
    ::StandardCurve,
    request ::AbstractArray
)
    facts("Standard curve requested") do
        context("Verifying request body") do
            @fact (isa(request,Vector)) --> true
            n_targets=-99
            for i in range(1,length(request))
                well=request[i]
                @fact (isa(well,OrderedDict)) --> true
                if (length(well)>0)
                    @fact (length(well)) --> 1
                    @fact (haskey(well,"well")) --> true
                    array=well["well"]
                    for j in range(1,length(array))
                        dict=array[j]
                        @fact (isa(dict,OrderedDict)) --> true
                        if (length(dict)>0)
                            # fact (length(dict)) --> 3
                            @fact (haskey(dict,"target")) --> true
                            @fact (isa(dict["target"],Integer)) --> true
                            @fact (haskey(dict,"cq")) --> true
                            @fact (isa(dict["cq"],Number)) --> true
                            @fact (haskey(dict,"quantity")) --> true
                            subdict=dict["quantity"]
                            @fact (isa(subdict,OrderedDict)) --> true
                            @fact (length(subdict)) --> 2
                            @fact (haskey(subdict,"m")) --> true
                            @fact (haskey(subdict,"b")) --> true
                            @fact (isa(subdict["m"],Number)) --> true
                            @fact (isa(subdict["b"],Number)) --> true
                        end
                    end
                end
            end
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/amplification
#
# ********************************************************************************

## according to juliaapi_new.txt:
#
## each set of calibration data (water, channel_1, channel_2) comes from the following SQL query: 
# 
# SELECT fluorescence_value, well_num, channel
#     FROM fluorescence_data
#     WHERE experiment_id = $calib_id AND step_id = $step_id
#     ORDER BY channel, well_num
# ;
#
# channel_2 will be NULL for single channel: 
#     "calibration_info": {
#         "water": {
#             "fluorescence_value": [
#                 [water_1__well_01, water_1__well_02, …, water_1__well_16],
#                 null
#             ]
#         },
#         "channel_1": {
#             "fluorescence_value": [
#                 [signal_1__well_01, signal_1__well_02, …, signal_1__well_16],
#                 null
#             ]
#         }
#     }

function calibration_test(
    calib ::Associative, 
    n_channels ::Integer =length(CHANNELS),
    conditions ::AbstractArray =["water","channel_1","channel_2"][1:(n_channels+1)]
)
    n_conditions=length(conditions)
    @fact (isa(calib,OrderedDict)) --> true
    # @fact (length(calib)) --> n_conditions
    @fact (isa(calib[conditions[1]],OrderedDict))--> true
    @fact (haskey(calib[conditions[1]],"fluorescence_value")) --> true
    @fact (isa(calib[conditions[1]]["fluorescence_value"],Vector)) --> true
    n_wells=length(calib[conditions[1]]["fluorescence_value"][1])
    for condition in conditions
        @fact (haskey(calib,condition)) --> true
        @fact (isa(calib[condition],OrderedDict)) --> true
        @fact (length(calib[condition])) --> 1
        @fact (haskey(calib[condition],"fluorescence_value")) --> true
        @fact (isa(calib[condition]["fluorescence_value"],Vector)) --> true
        @fact (length(calib[condition]["fluorescence_value"])) --> less_than_or_equal(2)
        for channel in range(1,n_channels)
            @fact (isa(calib[condition]["fluorescence_value"][channel],Vector)) --> true
            @fact (length(calib[condition]["fluorescence_value"][channel])) --> n_wells
            for i in range(1,n_wells)
                @fact (isa(calib[condition]["fluorescence_value"][channel][i],Number)) --> true
            end
        end
    end
    FactCheck.exitstatus()
end

## Raw Data comes from the following SQL query: 
# SELECT fluorescence_value, well_num, cycle_num, channel
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
#   ORDER BY channel, well_num, cycle_num
# ;

function raw_test(raw)
    @fact (isa(raw,OrderedDict)) --> true
    variables=["fluorescence_value","channel","well_num"]
    if (haskey(raw,"temperature"))
        push!(variables,"temperature")
    else
        push!(variables,"cycle_num")
    end
    n_raw=length(raw["fluorescence_value"])
    for v in variables
        @fact (haskey(raw,v)) --> true
        @fact (isa(raw[v],Vector)) --> true
        @fact abs(length(raw[v]) - n_raw) --> less_than_or_equal(1)
        for i in range(1,length(raw[v]))
            if (v=="fluorescence_value"||v=="temperature")
                @fact (isa(raw[v][i],Number)) --> true
            else
                @fact (isa(raw["well_num"][i],Integer)) --> true
            end
        end
    end
    FactCheck.exitstatus()
end

function verify_request(
    ::Amplification,
    request ::Associative
)
    facts("Amplification requested") do
        context("Verifying request body") do
            @fact (isa(request,OrderedDict)) --> true
            @fact (haskey(request,"experiment_id")) --> true
            @fact (isa(request["experiment_id"],Integer)) --> true
            if (haskey(request,"step_id"))
                id="step_id"
            else
                id="ramp_id"
            end
            @fact (haskey(request,id)) --> true
            @fact (isa(request[id],Integer)) --> true
            if (haskey(request,"min_reliable_cyc"))
                @fact (isa(request["min_reliable_cyc"],Integer)) --> true
            end
            if (haskey(request,"baseline_cyc_bounds"))
                @fact (isa(request["baseline_cyc_bounds"],Vector)) --> true
                if (length(request["baseline_cyc_bounds"])>0)
                    @fact (length(request["baseline_cyc_bounds"])) --> 2
                    @fact (isa(request["baseline_cyc_bounds"][1],Integer)) --> true
                    @fact (isa(request["baseline_cyc_bounds"][2],Integer)) --> true
                end
            end
            if (haskey(request,"baseline_method"))
                @fact (isa(request["baseline_method"],String)) --> true
                @fact ( 
                    request["baseline_method"] == "sigmoid" ||
                    request["baseline_method"] == "linear"  ||
                    request["baseline_method"] == "median" 
                ) --> true
            end
            if (haskey(request,"cq_method"))
                @fact (isa(request["cq_method"],String)) --> true
                @fact (request["cq_method"] in ["cp_dr1","cp_dr2","Cy0","ct"]) --> true
            end
            if (haskey(request,"min_fluomax"))
                @fact (isa(request["min_fluomax"],Number)) --> true
            end
            if (haskey(request,"min_D1max"))
                @fact (isa(request["min_D1max"],Number)) --> true
            end
            if (haskey(request,"min_D2max"))
                @fact (isa(request["min_D2max"],Number)) --> true
            end
            @fact (haskey(request,"calibration_info")) --> true
            calib=request["calibration_info"]
            @fact (isa(calib,OrderedDict)) --> true
            @fact (haskey(calib,"water")) --> true
            @fact (isa(calib["water"],OrderedDict)) --> true
            @fact (haskey(calib["water"],"fluorescence_value")) --> true
            @fact (isa(calib["water"]["fluorescence_value"],Vector)) --> true
            if length(calib["water"]["fluorescence_value"])<2 ||
                calib["water"]["fluorescence_value"][2]==nothing
                n_channels=1
            else
                n_channels=2
            end
            @fact (haskey(request,"raw_data")) --> true
            raw=request["raw_data"]
            @fact (isa(raw,OrderedDict)) --> true
            calibration_test(calib,n_channels)
            raw_test(raw)
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/meltcurve
#
#
# ********************************************************************************

# Notes: 
# 
# channel_nums = [1] for 1 channel, [1,2] for 2 channels, etc.
# top_N = number of Tm peaks to report

# Calibration (water, channel_1, channel_2) data comes from the following SQL query: 
# SELECT fluorescence_value, well_num, channel
#     FROM fluorescence_data
#     WHERE experiment_id = $calib_id AND step_id = $step_id
#     ORDER BY channel, well_num
# ;

# Raw Data comes from the following SQL query: 
# SELECT fluorescence_value, temperature, well_num, channel
#     FROM melt_curve_data
#     WHERE
#         experiment_id = $exp_id AND
#         stage_id = $stage_id
#     ORDER BY channel, well_num
# ;

function verify_request(
    ::MeltCurve,
    request ::Associative
)
    facts("Melting curve requested") do
        context("Verifying request body") do
            @fact (isa(request,OrderedDict)) --> true
            @fact (haskey(request,"experiment_id")) --> true
            @fact (isa(request["experiment_id"],Integer)) --> true
            @fact (haskey(request,"stage_id")) --> true
            @fact (isa(request["stage_id"],Integer)) --> true
            @fact (haskey(request,"calibration_info")) --> true
            @fact (haskey(request,"channel_nums")) --> true
            @fact (isa(request["channel_nums"],Vector)) --> true
            calib=request["calibration_info"]
            @fact (isa(calib,OrderedDict)) --> true
            @fact (haskey(calib,"water")) --> true
            @fact (isa(calib["water"],OrderedDict)) --> true
            @fact (haskey(calib["water"],"fluorescence_value")) --> true
            @fact (isa(calib["water"]["fluorescence_value"],Vector)) --> true
            if length(calib["water"]["fluorescence_value"])<2 ||
                calib["water"]["fluorescence_value"][2]==nothing
                @fact (request["channel_nums"]) --> [1]
                n_channels=1
            else
                @fact (request["channel_nums"]) --> [1,2]
                n_channels=2
            end
            if (haskey(request,"qt_prob"))
                @fact (isa(request["qt_prob"],Number)) --> true
            end
            if (haskey(request,"max_normd_qtv"))
                @fact (isa(request["max_normd_qtv"],Number)) --> true
            end
            if (haskey(request,"top_N"))
                @fact (isa(request["top_N"],Integer)) --> true
            end
            @fact (haskey(request,"raw_data")) --> true
            raw=request["raw_data"]
            calibration_test(calib,n_channels)
            raw_test(raw)
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/thermal_performance_diagnostic
#
# ********************************************************************************

# SQL query: 
# SELECT *
#     FROM temperature_logs
#     WHERE experiment_id = $exp_id
#     ORDER BY id
# ;

function verify_request(
    ::ThermalPerformanceDiagnostic,
    request ::Associative
)
    facts("Thermal performance diagnostic requested") do
        context("Verifying request body") do
            variables=["lid_temp","heat_block_zone_1_temp","heat_block_zone_2_temp","elapsed_time"] # ,"cycle_num"]
            @fact (isa(request,OrderedDict)) --> true
            @fact (length(request)) --> length(variables)
            n_cycles=length(request["elapsed_time"])
            for v in variables
                @fact (haskey(request,v)) --> true
                @fact (length(request[v])) --> n_cycles
                for i in range(1,n_cycles)
                    if (v=="elapsed_time")
                        @fact (isa(request[v][i],Integer)) --> true
                    else
                        @fact (isa(request[v][i],Number)) --> true
                    end
                end
            end
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/thermal_consistency
#
# ********************************************************************************

# SQL query: 
# SELECT fluorescence_value, temperature, well_num, channel
#     FROM melt_curve_data
#     WHERE
#         experiment_id = $exp_id AND
#         stage_id = $stage_id
#   ORDER BY channel, well_num
# ;

function verify_request(
    ::ThermalConsistency,
    request ::Associative
)
    facts("Thermal consistency requested") do
        context("Verifying request body") do
            @fact (isa(request,OrderedDict)) --> true
            # @fact (length(request)) --> 2
            @fact (haskey(request,"raw_data")) --> true
            @fact (isa(request["raw_data"],OrderedDict)) --> true
            @fact (haskey(request["raw_data"],"channel")) --> true
            @fact (haskey(request,"calibration_info")) --> true
            calib=request["calibration_info"]
            @fact (isa(calib,OrderedDict)) --> true
            @fact (haskey(calib,"water")) --> true
            @fact (isa(calib["water"],OrderedDict)) --> true
            @fact (haskey(calib["water"],"fluorescence_value")) --> true
            @fact (isa(calib["water"]["fluorescence_value"],Vector)) --> true
            if length(calib["water"]["fluorescence_value"])<2 ||
                calib["water"]["fluorescence_value"][2]==nothing
                n_channels=1
            else
                n_channels=2
            end
            calibration_test(calib,n_channels)
            raw_test(request["raw_data"])
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_cal
#
# ********************************************************************************

function verify_request(
    ::OpticalCal,
    request ::Associative
)
    facts("Optical calibration requested") do
        context("Verifying request body") do
            @fact (isa(request,OrderedDict)) --> true
            @fact (haskey(request,"calibration_info")) --> true
            calib=request["calibration_info"]
            @fact (isa(calib,OrderedDict)) --> true
            @fact (haskey(calib,"water")) --> true
            @fact (isa(calib["water"],OrderedDict)) --> true
            @fact (haskey(calib["water"],"fluorescence_value")) --> true
            @fact (isa(calib["water"]["fluorescence_value"],Vector)) --> true
            if length(calib["water"]["fluorescence_value"])<2 ||
                calib["water"]["fluorescence_value"][2]==nothing
                n_channels=1
            else
                n_channels=2
            end
            calibration_test(calib,n_channels)
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_single_channel
#
# ********************************************************************************

## SQL query: 
# SELECT fluorescence_value, well_num, cycle_num
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
#     ORDER BY well_num, cycle_num
# ;

function verify_request(
    ::OpticalTestSingleChannel,
    request ::Associative
)
    facts("Single channel optical test requested") do
        context("Verifying request body") do
            conditions=["baseline","excitation"]
            @fact (isa(request,OrderedDict)) --> true
            # @fact (length(request)) --> length(conditions)
            @fact (isa(request["baseline"],OrderedDict))--> true
            @fact (haskey(request["baseline"],"fluorescence_value")) --> true
            @fact (isa(request["baseline"]["fluorescence_value"],Vector)) --> true
            n_wells=length(request["baseline"]["fluorescence_value"])
            for condition in conditions
                @fact (haskey(request,condition)) --> true
                @fact (isa(request[condition],OrderedDict)) --> true
                @fact (length(request[condition])) --> 1
                @fact (haskey(request[condition],"fluorescence_value")) --> true
                @fact (isa(request[condition]["fluorescence_value"],Vector)) --> true
                @fact (isa(request[condition]["fluorescence_value"],Vector)) --> true
                @fact (length(request[condition]["fluorescence_value"])) --> n_wells
                for i in range(1,n_wells)
                    @fact (isa(request[condition]["fluorescence_value"][i],Number)) --> true
                end
            end
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_dual_channel
#
# ********************************************************************************

## SQL query: 
# SELECT fluorescence_value, well_num, cycle_num
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
#     ORDER BY well_num, cycle_num
# ;

function verify_request(
    ::OpticalTestDualChannel,
    request ::Associative
)
    facts("Dual channel optical test requested") do
        context("Verifying request body") do
            @fact (isa(request,OrderedDict)) --> true
            if (haskey(request,"channel_1"))
                calibration_test(request,2,["baseline","water","channel_1","channel_2"])        
            else
                calibration_test(request,2,["baseline","water","FAM","HEX"])
            end
        end
    end
    FactCheck.exitstatus()
end
