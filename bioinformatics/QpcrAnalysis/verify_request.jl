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

# set default calibration experiment
calib_info_AIR = -99

# constants

const CHANNELS = [1, 2]



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
    request ::Any
)
    @assert (isa(request,Vector))
    n_targets=length(request[1]["well"])
    for i in range(1,length(request))
        well=request[i]
        @assert (isa(well,OrderedDict))
        @assert (length(well)==1)
        @assert (haskey(well,"well"))
        array=well["well"]
        @assert (length(array)==n_targets)
        empty=(length(array[1])==0)
        for j in range(1,n_targets)
            dict=array[j]
            @assert (isa(dict,OrderedDict))
            if (empty)
                @assert (length(dict)==0)
            else
                @assert (length(dict)==3)
                k=keys(dict)
                @assert (haskey(dict,"target"))
                @assert (dict["target"]==j)
                @assert (haskey(dict,"cq"))
                @assert (isa(dict["cq"],Integer))
                @assert (haskey(dict,"quantity"))
                subdict=dict["quantity"]
                @assert (isa(subdict,OrderedDict))
                @assert (length(subdict)==2)
                @assert (haskey(subdict,"m"))
                @assert (haskey(subdict,"b"))
                @assert (isa(subdict["m"],Number))
                @assert (isa(subdict["b"],Number))
            end
        end
    end
    true
end


function standard_curve_request_test()
    request=JSON.parse("""[
        {"well": [
            {"target": 1, "cq": 999, "quantity": {"m": 1.111, "b": -10}},
            {"target": 2, "cq": 999, "quantity": {"m": 1.111, "b": -10}}
        ]},
        {"well": [
            {"target": 1, "cq": 999, "quantity": {"m": 1.111, "b": -10}},
            {"target": 2, "cq": 999, "quantity": {"m": 1.456, "b": 12}}
        ]},
        {"well": [
            {"target": 1, "cq": 999, "quantity": {"m": 1.111, "b": -10}},
            {"target": 2, "cq": 999, "quantity": {"m": 3, "b": -12}}
        ]},
        {"well": [{}, {}]}
    ]"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["standard_curve"](),
        request
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/amplification
#
# ********************************************************************************

## according to juliaapi_new.txt:
#
# each set of calibration data (water, signal_1, signal_2) comes from the following SQL query: 
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
    n_channels=length(CHANNELS) ::Integer,
    conditions=["water","channel_1","channel_2"][1:n_channels] ::AbstractArray
)
    n_conditions=length(conditions)
    @assert (isa(calib,OrderedDict))
    # @assert (length(calib)==n_conditions)
    @assert (isa(calib[conditions[1]],OrderedDict))
    @assert (haskey(calib[conditions[1]],"fluorescence_value"))
    @assert (isa(calib[conditions[1]]["fluorescence_value"],Vector))
    n_wells=length(calib[conditions[1]]["fluorescence_value"][1])
    for condition in conditions
        @assert (haskey(calib,condition))
        @assert (isa(calib[condition],OrderedDict))
        @assert (length(calib[condition])==1)
        @assert (haskey(calib[condition],"fluorescence_value"))
        @assert (isa(calib[condition]["fluorescence_value"],Vector))
        @assert (length(calib[condition]["fluorescence_value"])<=2)
        for channel in range(1,n_channels)
            @assert (isa(calib[condition]["fluorescence_value"][channel],Vector))
            @assert (length(calib[condition]["fluorescence_value"][channel])==n_wells)
            for i in range(1,n_wells)
                        @assert (isa(calib[condition]["fluorescence_value"][channel][i],Number))
            end
        end
    end
    true
end


# Raw Data comes from the following sql query: 
#
# SELECT fluorescence_value, well_num, cycle_num, channel
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
#   ORDER BY channel, well_num, cycle_num
# ;

function raw_test(raw)
    @assert (isa(raw,OrderedDict))
    variables=["fluorescence_value","channel","well_num"]
    if (haskey(raw,"temperature"))
        push!(variables,"temperature")
    else
        push!(variables,"cycle_num")
    end
    n_raw=length(raw["fluorescence_value"])
    for v in variables
        @assert (haskey(raw,v))
        @assert (isa(raw[v],Vector))
        @assert (length(raw[v])==n_raw)
        for i in range(1,n_raw)
            if (v=="fluorescence_value"||v=="temperature")
                @assert (isa(raw[v][i],Number))
            else
                @assert (isa(raw["well_num"][i],Integer))
            end
        end
    end
    true
end


function verify_request(
    ::Amplification,
    request ::Any
)
    @assert (isa(request,OrderedDict))
    @assert (haskey(request,"experiment_id"))
    @assert (isa(request["experiment_id"],Integer))
    if (haskey(request,"step_id"))
        id="step_id"
    else
        id="ramp_id"
    end
    @assert (haskey(request,id))
    @assert (isa(request[id],Integer))
    if (haskey(request,"min_reliable_cyc"))
        @assert (isa(request["min_reliable_cyc"],Integer))
    end
    if (haskey(request,"baseline_cyc_bounds"))
        @assert (isa(request["baseline_cyc_bounds"],Vector))
        if (length(request["baseline_cyc_bounds"])>0)
            @assert (length(request["baseline_cyc_bounds"])==2)
            @assert (isa(request["baseline_cyc_bounds"][1],Integer))
            @assert (isa(request["baseline_cyc_bounds"][2],Integer))
        end
    end
    if (haskey(request,"baseline_method"))
        @assert (isa(request["baseline_method"],String))
        @assert (
            request["baseline_method"] == "sigmoid" ||
            request["baseline_method"] == "linear"  ||
            request["baseline_method"] == "median" 
        )
    end
    if (haskey(request,"cq_method"))
        @assert (isa(request["cq_method"],String))
        @assert (request["cq_method"] in ["cp_dr1","cp_dr2","Cy0","ct"])
    end
    if (haskey(request,"min_fluomax"))
        @assert (isa(request["min_fluomax"],Number))
    end
    if (haskey(request,"min_D1max"))
        @assert (isa(request["min_D1max"],Number))
    end
    if (haskey(request,"min_D2max"))
        @assert (isa(request["min_D2max"],Number))
    end
    @assert (haskey(request,"calibration_info"))
    calib=request["calibration_info"]
    @assert (isa(calib,OrderedDict))
    @assert (haskey(calib,"water"))
    @assert (isa(calib["water"],OrderedDict))
    @assert (haskey(calib["water"],"fluorescence_value"))
    @assert (isa(calib["water"]["fluorescence_value"],Vector))
    if length(calib["water"]["fluorescence_value"])<2 ||
        calib["water"]["fluorescence_value"][2]==nothing
        n_channels=1
    else
        n_channels=2
    end
    @assert (haskey(request,"raw_data"))
    raw=request["raw_data"]
    @assert (isa(raw,OrderedDict))
    calibration_test(calib,n_channels) &&
        raw_test(raw)
end

# single channel

function singlechannel_amplification_request_test()
    request=JSON.parse("""{
        "experiment_id": 99,
        "step_id": 99,
        "min_reliable_cyc": 5,
        "calibration_info": {
            "water": {
                "fluorescence_value": [
                    [0.01, 0.02,    0.15, 0.16],
                    null
                ]
            },
            "channel_1": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            }
        },
        "baseline_cyc_bounds": [5, 10],
        "baseline_method": "sigmoid", 
        "cq_method": "Cy0",
        "min_fluomax": 4356,
        "min_D1max": 472,
        "min_D2max": 41,
        "raw_data": {
            "fluorescence_value": [],
            "well_num": [],
            "cycle_num": [],
            "channel": []
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["amplification"](),
        request
    )
end

# dual channel

function dualchannel_amplification_request_test()
    request=JSON.parse("""{
        "experiment_id": 99,
        "ramp_id": 99,
        "min_reliable_cyc": 5,
        "calibration_info": {
            "water": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            },
            "channel_1": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            },
            "channel_2": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            }
        },
        "baseline_cyc_bounds": [],
        "baseline_method": "sigmoid", 
        "cq_method": "Cy0",
        "min_fluomax": 4356,
        "min_D1max": 472,
        "min_D2max": 41,
        "raw_data": {
            "fluorescence_value": [],
            "well_num": [],
            "cycle_num": [],
            "channel": []
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["amplification"](),
        request
    )
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

# Calibration (Water, signal_1, signal_2) data comes from the following sql query: 
#
# SELECT fluorescence_value, well_num, channel
#     FROM fluorescence_data
#     WHERE experiment_id = $calib_id AND step_id = $step_id
#     ORDER BY channel, well_num
# ;

# Raw Data comes from the following sql query: 
#
# SELECT fluorescence_value, temperature, well_num, channel
#     FROM melt_curve_data
#     WHERE
#         experiment_id = $exp_id AND
#         stage_id = $stage_id
#     ORDER BY channel, well_num
# ;


function verify_request(
    ::MeltCurve,
    request ::Any
)
    @assert (isa(request,OrderedDict))
    @assert (haskey(request,"experiment_id"))
    @assert (isa(request["experiment_id"],Integer))
    @assert (haskey(request,"stage_id"))
    @assert (isa(request["stage_id"],Integer))
    @assert (haskey(request,"calibration_info"))
    @assert (haskey(request,"channel_nums"))
    @assert (isa(request["channel_nums"],Vector))
    calib=request["calibration_info"]
    @assert (isa(calib,OrderedDict))
    @assert (haskey(calib,"water"))
    @assert (isa(calib["water"],OrderedDict))
    @assert (haskey(calib["water"],"fluorescence_value"))
    @assert (isa(calib["water"]["fluorescence_value"],Vector))
    if length(calib["water"]["fluorescence_value"])<2 ||
        calib["water"]["fluorescence_value"][2]==nothing
        @assert (request["channel_nums"]==[1])
        n_channels=1
    else
        @assert (request["channel_nums"]==[1,2])
        n_channels=2
    end
    if (haskey(request,"qt_prob"))
        @assert (isa(request["qt_prob"],Number))
    end
    if (haskey(request,"max_normd_qtv"))
        @assert (isa(request["max_normd_qtv"],Number))
    end
    if (haskey(request,"top_N"))
        @assert (isa(request["top_N"],Integer))
    end
    @assert (haskey(request,"raw_data"))
    raw=request["raw_data"]
    calibration_test(calib,n_channels) &&
        raw_test(raw)
end

# single channel

function singlechannel_meltcurve_request_test()
    request=JSON.parse("""{
        "experiment_id": 2,
        "stage_id": 5,
        "calibration_info": {
            "water": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            },
            "channel_1": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            },
            "channel_2": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            }
        },
        "channel_nums": [1],
        "qt_prob": 0.64,
        "max_normd_qtv": 0.8,
        "top_N": 4, 
        "raw_data": {
            "fluorescence_value": [],
            "temperature": [],
            "well_num": [],
            "channel": []
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["meltcurve"](),
        request
    )
end

# dual channel

function dualchannel_meltcurve_request_test()
    request=JSON.parse("""{
        "experiment_id": 2,
        "stage_id": 5,
        "calibration_info": {
            "water": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            },
            "channel_1": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            },
            "channel_2": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            }
        },
        "channel_nums": [1,2],
        "qt_prob": 0.64,
        "max_normd_qtv": 0.8,
        "top_N": 4, 
        "raw_data": {
        	"fluorescence_value": [],
        	"temperature": [],
        	"well_num": [],
        	"channel": []
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["meltcurve"](),
        request
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/thermal_performance_diagnostic
#
# ********************************************************************************

# MySQL query it is used: 
# SELECT *
#     FROM temperature_logs
#     WHERE experiment_id = $exp_id
#     ORDER BY id
# ;

function verify_request(
    ::ThermalPerformanceDiagnostic,
    request ::Any
)
    variables=["lid_temp","heat_block_zone_1_temp","heat_block_zone_2_temp","elapsed_time","cycle_num"]
    @assert (isa(request,OrderedDict))
    @assert (length(request)==length(variables))
    n_cycles=length(request["cycle_num"])
    for v in variables
        @assert (haskey(request,v))
        @assert (length(request[v])==n_cycles)
        for i in range(1,n_cycles)
            @assert (isa(request[v][i],Number))
        end
    end
    true
end


function thermal_performance_diagnostic_request_test()
    request=JSON.parse("""{
      "lid_temp": [],
      "heat_block_zone_1_temp": [],
      "heat_block_zone_2_temp": [],
      "elapsed_time": [],
      "cycle_num": []
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["thermal_performance_diagnostic"](),
        request
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/thermal_consistency
#
# ********************************************************************************

# request body: 

# MySQL query used: 
#
# SELECT fluorescence_value, temperature, well_num, channel
#     FROM melt_curve_data
#     WHERE
#         experiment_id = $exp_id AND
#         stage_id = $stage_id
#   ORDER BY channel, well_num
# ;

function verify_request(
    ::ThermalConsistency,
    request ::Any
)
    @assert (isa(request,OrderedDict))
    # @assert (length(request)==2)
    @assert (haskey(request,"raw_data"))
    @assert (isa(request["raw_data"],OrderedDict))
    @assert (haskey(request["raw_data"],"channel"))
    @assert (haskey(request,"calibration_info"))
    calib=request["calibration_info"]
    @assert (isa(calib,OrderedDict))
    @assert (haskey(calib,"water"))
    @assert (isa(calib["water"],OrderedDict))
    @assert (haskey(calib["water"],"fluorescence_value"))
    @assert (isa(calib["water"]["fluorescence_value"],Vector))
    if length(calib["water"]["fluorescence_value"])<2 ||
        calib["water"]["fluorescence_value"][2]==nothing
        n_channels=1
    else
        n_channels=2
    end
    experiment_info(request) &&
        calibration_test(calib,n_channels) &&
        raw_test(request["raw_data"])
end

# single channel

function single_channel_thermal_consistency_request_test()
    request=JSON.parse("""{
        "raw_data": {
            "fluorescence_value":  [],
            "temperature":  [],
            "well_num":  [],
            "channel":  []
        },
        "calibration_info": {
            "water": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            },
            "channel_1": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            },
            "channel_2": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            }
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["thermal_consistency"](),
        request
    )
end

# dual channel

function dual_channel_thermal_consistency_request_test()
    request=JSON.parse("""{
        "raw_data": {
            "fluorescence_value":  [],
            "temperature":  [],
            "well_num":  [],
            "channel":  []
        },
        "calibration_info": {
            "water": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            },
            "channel_1": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            },
            "channel_2": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            }
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["thermal_consistency"](),
        request
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_cal
#
# ********************************************************************************

function verify_request(
    ::OpticalCal,
    request ::Any
)
    @assert (isa(request,OrderedDict))
    @assert (haskey(request,"calibration_info"))
    @assert (length(request)==1)
    calib=request["calibration_info"]
    @assert (isa(calib,OrderedDict))
    @assert (haskey(calib,"water"))
    @assert (isa(calib["water"],OrderedDict))
    @assert (haskey(calib["water"],"fluorescence_value"))
    @assert (isa(calib["water"]["fluorescence_value"],Vector))
    if length(calib["water"]["fluorescence_value"])<2 ||
        calib["water"]["fluorescence_value"][2]==nothing
        n_channels=1
    else
        n_channels=2
    end
    experiment_info(request) &&
        calibration_test(calib,n_channels)
end

# single channel

function singlechannel_optical_cal_request_test()
    request=JSON.parse("""{
        "calibration_info": {
            "water": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            },
            "channel_1": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            },
            "channel_2": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    null
                ]
            }
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["optical_cal"](),
        request
    )
end

# dual channel

function dualchannel_optical_cal_request_test()
    request=JSON.parse("""{
        "calibration_info": {
            "water": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            },
            "channel_1": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            },
            "channel_2": {
                "fluorescence_value": [
                    [1.01, 1.02,    1.15, 1.16],
                    [2.01, 2.02,    2.15, 2.16]
                ]
            }
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["optical_cal"](),
        request
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_single_channel
#
# ********************************************************************************

# MySQL query used: 
#
# SELECT fluorescence_value, well_num, cycle_num
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
#     ORDER BY well_num, cycle_num
# ;

function verify_request(
    ::OpticalTestSingleChannel,
    request ::Any
)
    calibration_test(request,1,["baseline","excitation"])
end

function singlechannel_optical_request_test()
    request=JSON.parse("""{
        "baseline": {
            "fluorescence_value": [
                [1.01, 1.02,    1.15, 1.16]
            ]
        },
        "excitation": {
            "fluorescence_value": [
                [1.01, 1.02,    1.15, 1.16]
            ]
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["optical_test"](),
        request
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_dual_channel
#
# ********************************************************************************

# MySQL query used: 
#
# SELECT fluorescence_value, well_num, cycle_num
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
#     ORDER BY well_num, cycle_num
# ;

function verify_request(
    ::OpticalTestDualChannel,
    request ::Any
)
    @assert (isa(request,OrderedDict))
    @assert (haskey(request,"calibration_info"))
    calib=request["calibration_info"]
    @assert (isa(calib,OrderedDict))
    if (haskey(calib,"channel_1"))
        calibration_test(calib,2,["baseline","water","channel_1","channel_2"])
    else
        calibration_test(calib,2,["baseline","water","FAM","HEX"])
    end
end

function dualchannel_optical_request_test()
    request=JSON.parse("""{
        "baseline": {
            "fluorescence_value": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        },
        "water": {
            "fluorescence_value": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        },
        "channel_1": {
            "fluorescence_value": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        },
        "channel_2": {
            "fluorescence_value": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        }
    }"""; dicttype=OrderedDict)
    verify_request(
        ActionType_DICT["optical_test"](),
        request
    )
end



# ********************************************************************************
#
#                               R U N   E X A M P L E S
#
# ********************************************************************************

function verify_request_examples()
    examples = [
        :standard_curve_request_test,
        :singlechannel_amplification_request_test,
        :dualchannel_amplification_request_test,
        :singlechannel_meltcurve_request_test,
        :dualchannel_meltcurve_request_test,
        :thermal_performance_diagnostic_request_test,
        :single_channel_thermal_consistency_request_test,
        :dual_channel_thermal_consistency_request_test,
        :singlechannel_optical_cal_request_test,
        :dualchannel_optical_cal_request_test,
        :singlechannel_optical_request_test,
        :singlechannel_optical_request_test,
        :dualchannel_optical_request_test
    ]
    OrderedDict(map(examples) do f
        f => 
            try
                getfield(Main,f)()
            catch err
                err
            end
    end)
end

# Usage:
# verify_request_examples() # every test should return true