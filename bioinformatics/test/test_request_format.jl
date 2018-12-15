# test_request_format.jl
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


# ********************************************************************************
#
# call: experiments/:experiment_id/standard_curve
#
# ********************************************************************************

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

function thermal_performance_diagnostic_request_test()
    request=JSON.parse("""{
      "lid_temp": [1,2,3],
      "heat_block_zone_1_temp": [1,2,3],
      "heat_block_zone_2_temp": [1,2,3],
      "elapsed_time": [1,2,3]
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
        ActionType_DICT["optical_test_single_channel"](),
        request
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_dual_channel
#
# ********************************************************************************

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
        ActionType_DICT["optical_test_dual_channel"](),
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
# verify_request_examples() # every test should return false