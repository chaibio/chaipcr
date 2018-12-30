# test_response_format.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# This Julia script tests the JSON data structures 
# that are returned in the body of responses to GET requests
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

function standard_curve_response_test()
    response=JSON.parse("""{
        "targets": 
        [
            {"target_id": 1, "slope": 9.99, "offset": 9.99, "efficiency": 1.02, "r2": 0.99}, 
            {"target_id": 2, "slope": 9.99, "offset": 9.99, "efficiency": 0.98, "r2": 0.99}, 
            {"target_id": 3, "error": "xxxxx"},
            {"target_id": 4, "error": "xxxxx"}
        ]
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["standard_curve"](),
        response
    )
end


# ********************************************************************************
#
# call: experiments/:experiment_id/amplification
#
# ********************************************************************************

# single channel

function singlechannel_amplification_response_test()
    response=JSON.parse(
        # after deconvolution (if dual channel) and adjusting well-to-well variation,
        # before baseline subtraction
    """{
        "rbbs_ary3": [ 
            [
                [1.0101, 1.0102,    1.0140],
                [1.0201, 1.0202,    1.0240],
                
                [1.1601, 1.1602,    1.1640]
            ]
        ],
    """*
        # after baseline subtraction
    """
        "blsub_fluos": [ 
            [
                [1.0101, 1.0102,    1.0140],
                [1.0201, 1.0202,    1.0240],
                
                [1.1601, 1.1602,    1.1640]
            ]
        ],
    """*    
        # first derivative of the amp curve
    """
        "dr1_pred": [ 
            [
                [1.0101, 1.0102,    1.0140],
                [1.0201, 1.0202,    1.0240],
                
                [1.1601, 1.1602,    1.1640]
            ]
        ],
    """*
        # second derivative of the amp curve
    """
        "dr2_pred": [ 
            [
                [1.0101, 1.0102,    1.0140],
                [1.0201, 1.0202,    1.0240],
                
                [1.1601, 1.1602,    1.1640]
            ]
        ],

        "cq": [
            [1.01, 1.02,    1.16]
        ],
    """*
        # starting quantity from absolute quantification
    """
        "d0": [
            [1.01, 1.02,    1.16]
        ],
    """*
        # fluorescence threshold if Ct method is used: 
        # [channel_1] for single channel,
        # [channel_1, channel_2] for dual channel,
        # [] empty for automatic detection from data
    """
        "ct_fluos": [1.0], 
        "assignments_adj_labels_dict": { 
            "rbbs_ary3":   ["aa", "aa",     "Aa"],
            "blsub_fluos": ["aA", "aa",     "aa"],
            "d0":          ["aa", "AA",     "Aa"],
            "cq":          ["aa", "Aa",     "aa"]
        }
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["amplification"](),
        response
    )
end

# dual channel

function dualchannel_amplification_response_test()
    response=JSON.parse(
        # after deconvolution (if dual channel) and adjusting well-to-well variation,
        # before baseline subtraction
    """{
        "rbbs_ary3": [ 
            [
                [1.0101, 1.0102,    1.0140],
                [1.0201, 1.0202,    1.0240],
                
                [1.1601, 1.1602,    1.1640]
            ], 
            [
                [2.0101, 2.0102,    2.0140],
                [2.0201, 2.0202,    2.0240],
                
                [2.1601, 2.1602,    2.1640]
            ] 
        ],
    """*
        # after baseline subtraction
    """
        "blsub_fluos": [ 
            [
                [1.0101, 1.0102,    1.0140],
                [1.0201, 1.0202,    1.0240],
                
                [1.1601, 1.1602,    1.1640]
            ], 
            [
                [2.0101, 2.0102,    2.0140],
                [2.0201, 2.0202,    2.0240],
                
                [2.1601, 2.1602,    2.1640]
            ]
        ],
    """*
        # first derivative of the amp curve
    """
        "dr1_pred": [ 
            [
                [1.0101, 1.0102,    1.0140],
                [1.0201, 1.0202,    1.0240],
                
                [1.1601, 1.1602,    1.1640]
            ], 
            [
                [2.0101, 2.0102,    2.0140],
                [2.0201, 2.0202,    2.0240],
                
                [2.1601, 2.1602,    2.1640]
            ] 
        ],
    """*
        # second derivative of the amp curve
    """
        "dr2_pred": [ 
            [
                [1.0101, 1.0102,    1.0140],
                [1.0201, 1.0202,    1.0240],
                
                [1.1601, 1.1602,    1.1640]
            ], 
            [
                [2.0101, 2.0102,    2.0140],
                [2.0201, 2.0202,    2.0240],
                
                [2.1601, 2.1602,    2.1640]
            ] 
        ],

        "cq": [
            [1.01, 1.02,    1.16], 
            [2.01, 2.02,    2.16]  
        ],
    """*
        # starting quantity from absolute quantification
    """
        "d0": [
            [1.01, 1.02,    1.16], 
            [2.01, 2.02,    2.16] 
        ],
    """*
        # fluorescence threshold if Ct method is used: 
        # [channel_1] for single channel,
        # [channel_1, channel_2] for dual channel,
        # [] empty for automatic detection from data
    """
        "ct_fluos": [1.0, 2.0], 
        "assignments_adj_labels_dict": { 
            "rbbs_ary3":   ["aa", "aa",     "Aa"],
            "blsub_fluos": ["aA", "aa",     "aa"],
            "d0":          ["aa", "AA",     "Aa"],
            "cq":          ["aa", "Aa",     "aa"]
        }
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["amplification"](),
        response
    )
end

# error response body: 

function error_amplification_response_test()
    response=JSON.parse("""{
        "valid": false,
        "error": "xxxx"
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["amplification"](),
        response
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/meltcurve
#
# ********************************************************************************

# each matrix r is [ temperature_1 fluo_1 derivative_1;
#                    temperature_2 fluo_2 derivative_2;
#                    ...           ...    ...
#                    temperature_n fluo_n derivative_n]
# n_grid >> 0 is the same for each well
#
# in JSON
r="[[0.101, 0.102,     0.199]," * # temp
  " [0.201, 0.202,     0.299]," * # fluo
  " [0.301, 0.302,     0.399]]"   # slope
r1_01=r; r1_02=r; r1_16=r
r2_01=r; r2_02=r; r2_16=r

# each matrix s is [ temp_max_1 peak_area_1;
#                    temp_max_2 peak_area_2;
#                    ...           ...    ...
#                    temp_max_n peak_area_n;]
# n_peaks >=0 may be different for each well
#
# in JSON
s="[[0.101, 0.102,     0.104]," * # Tm
  " [0.201, 0.202,     0.204]]"   # area
s1_01=s; s1_02=s; s1_16=s
s2_01=s; s2_02=s; s2_16=s

# single channel data

function singlechannel_meltcurve_response_test()
    response=JSON.parse("""{
        "melt_curve_data":     [
            [ $(r1_01), $(r1_02),     $(r1_16) ]
        ],
        "melt_curve_analysis": [
            [ $(s1_01), $(s1_02),     $(s1_16) ]
        ]
    }"""; dicttype=OrderedDict)
    println(response)
    println(JSON.json(response))
    verify_response(
        Action_DICT["meltcurve"](),
        response
    )
end

# dual channel data

function dualchannel_meltcurve_response_test()
    response=JSON.parse("""{
        "melt_curve_data": [ 
            [ $(r1_01), $(r1_02),     $(r1_16) ], 
            [ $(r2_01), $(r2_02),     $(r2_16) ]
        ],
        "melt_curve_analysis": [
            [ $(s1_01), $(s1_02),     $(s1_16) ], 
            [ $(s2_01), $(s2_02),     $(s2_16) ]
        ]
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["meltcurve"](),
        response
    )
end

# error response body: 

function error_meltcurve_response_test()
    response=JSON.parse("""{
        "valid": false,
        "error": "xxxx"
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["meltcurve"](),
        response
    )
end



# ********************************************************************************
#
# call: system/loadscript?script=path%2Fto%2Fanalyze.jl
#
# ********************************************************************************

# success response body: 

function loadscript_response_test()
    response=JSON.parse("""{
        "script": "path/to/analyze.jl"
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["loadscript"](),
        response
    )
end

# error response body: 

function error_loadscript_response_test()
    response=JSON.parse("""{
        "valid": false,
        "error": "xxxx"
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["loadscript"](),
        response
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/thermal_performance_diagnostic
#
# ********************************************************************************

# success response body (thermal_performance_diagnostic): 

function thermal_performance_diagnostic_response_test()
    response=JSON.parse("""{
        "Heating":  {
            "AvgRampRate": [5.3743,true],
            "TotalTime": [8001,false],
            "MaxBlockDeltaT": [1.27,true]
        },
        "Cooling": {
            "AvgRampRate": [0,false],
            "TotalTime": [9000,false],
            "MaxBlockDeltaT": [0.94,true]
        },
        "Lid": {
            "HeatingRate": [1.3031,true],
            "TotalTime": [32999,false]
        },
        "valid": true
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["thermal_performance_diagnostic"](),
        response
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/thermal_consistency
#
# ********************************************************************************

# success response body (thermal_consistency): 

function thermal_consistency_response_test()
    response=JSON.parse("""{
        "tm_check": [
            {
                "Tm": [79.0773,true],
                "area": 1361.5005
            },
            {
                "Tm": [78.5635,true],
                "area": 1763.7998
            },
            {
                "Tm": [78.4396,true],
                "area": 1434.3995
            },
            {
                "Tm": [78.2172,true],
                "area": 1672.9787
            },
            {
                "Tm": [77.8384,true],
                "area": 639.2474
            },
            {
                "Tm": [78.3816,true],
                "area": 1076.2143
            },
            {
                "Tm": [78.6829,true],
                "area": 895.6206
            },
            {
                "Tm": [78.6403,true],
                "area": 366.6082
            },
            {
                "Tm": [78.0791,true],
                "area": 255.8169
            },
            {
                "Tm": [77.5054,true],
                "area": 193.9588
            },
            {
                "Tm": [78.0182,true],
                "area": 1114.7039
            },
            {
                "Tm": [78.171,true],
                "area": 1324.3671
            },
            {
                "Tm": [78.1117,true],
                "area": 1219.4364
            },
            {
                "Tm": [77.8815,true],
                "area": 499.9462
            },
            {
                "Tm": [78.3167,true],
                "area": 1097.0781
            },
            {
                "Tm": [79.2487,true],
                "area": 1318.3026
            }
        ],
        "delta_Tm": [1.7434,true],
        "valid": true
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["thermal_consistency"](),
        response
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_cal
#
# ********************************************************************************

# valid

function valid_optical_cal_response_test()
    response=JSON.parse("""{
        "valid": true
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["optical_cal"](),
        response
    )
end

# invalid

function invalid_optical_cal_response_test()
    response=JSON.parse("""{
        "valid": false,
        "error": "xxxx"
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["optical_cal"](),
        response
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_single_channel
#
# ********************************************************************************

function singlechannel_optical_response_test()
    response=JSON.parse("""{
        "optical_data": [
        {
            "baseline": 1704,
            "excitation": 84756,
            "valid": true
        },{
            "baseline": 1844,
            "excitation": 76751,
            "valid": true
        },{
            "baseline": 1729,
            "excitation": 75655,
            "valid": true
        },{
            "baseline": 1695,
            "excitation": 32242,
            "valid": true
        },{
            "baseline": 1683,
            "excitation": 71588,
            "valid": true
        },{
            "baseline": 1837,
            "excitation": 96184,
            "valid": true
        },{
            "baseline": 1696,
            "excitation": 90374,
            "valid": true
        },{
            "baseline": 1848,
            "excitation": 88519,
            "valid": true
        },{
            "baseline": 1675,
            "excitation": 105414,
            "valid": true
        },{
            "baseline": 1731,
            "excitation": 90122,
            "valid": true
        },{     
            "baseline": 1718,
            "excitation": 94174,
            "valid": true
        },{
            "baseline": 1803,
            "excitation": 110185,
            "valid": true
        },{
            "baseline": 1797,
            "excitation": 92436,
            "valid": true
        },{
            "baseline": 1773,
            "excitation": 35866,
            "valid": true
        },{
            "baseline": 1789,
            "excitation": 101293,
            "valid": true
        },{
            "baseline": 1864,
            "excitation": 98680,
            "valid": true
        },
        "valid": true
    ]}"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["optical_test_single_channel"](),
        response
    )
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_dual_channel
#
# *******************************************************************************

function dualchannel_optical_response_test()
    response=JSON.parse("""{
        "optical_data": [
            {
                "baseline": [[7373,true],[1790,true]],
                "FAM": [[56997,false],[25204,false]],
                "HEX": [[10827,false],[24547,false]],
                "water": [[7373,true],[1790,true]]
            },
            {
                "baseline": [[16590,true],[1908,true]],
                "FAM": [[113931,false],[44197,false]],
                "HEX": [[21176,false],[43755,false]],
                "water": [[16590,true],[1908,true]]
            },
            {
                "baseline": [[10622,true],[1945,true]],
                 "FAM": [[97683,false],[40424,false]],
                 "HEX": [[14754,false],[39349,false]],
                "water": [[10622,true],[1945,true]]
            },
            {
                "baseline": [[3194,true],[1692,true]],
                "FAM": [[15820,false],[7494,false]],
                "HEX": [[4289,false],[7489,false]],
                "water": [[3194,true],[1692,true]]
            },
            {
                "baseline": [[7210,true],[1623,true]],
                "FAM": [[56260,false],[22039,false]],
                "HEX": [[10460,false],[22624,false]],
                "water": [[7210,true],[1623,true]]
            },
            {
                "baseline": [[9309,true],[1958,true]],
                "FAM": [[75858,false],[30542,false]],
                "HEX": [[14908,false],[31364,false]],
                "water": [[9309,true],[1958,true]]
            },
            {
                "baseline": [[9923,true],[1804,true]],
                "FAM": [[76166,false],[32064,false]],
                "HEX": [[19045,false],[32810,false]],
                "water": [[9923,true],[1804,true]]
            },
            {
                "baseline": [[17224,true],[2063,true]],
                "FAM": [[110970,false],[39879,false]],
                "HEX": [[33050,false],[41685,false]],
                "water": [[17224,true],[2063,true]]
            },
            {
                "baseline": [[6116,true],[2098,true]],
                "FAM": [[75856,false],[35634,false]],
                "HEX": [[9767,false],[33825,false]],
                "water": [[6116,true],[2098,true]]
            },
            {
                "baseline": [[11647,true],[1967,true]],
                "FAM": [[118257,false],[43666,false]],
                "HEX": [[19407,false],[42969,false]],
                "water": [[11647,true],[1967,true]]
            },
            {
                "baseline": [[10132,true],[2558,true]],
                "FAM": [[80505,false],[35494,false]],
                "HEX": [[14507,false],[34011,false]],
                "water": [[10132,true],[2558,true]]
            },
            {
                "baseline": [[7019,true],[2757,true]],
                "FAM": [[66396,false],[25384,false]],
                "HEX": [[10391,false],[24408,false]],
                "water": [[7019,true],[2757,true]]
            },
            {
                "baseline": [[12806,true],[1900,true]],
                "FAM": [[117630,false],[45047,false]],
                "HEX": [[21790,false],[42365,false]],
                "water": [[12806,true],[1900,true]]
            },
            {
                "baseline": [[9926,true],[1843,true]],
                "FAM": [[70441,false],[24076,false]],
                "HEX": [[17115,false],[22416,false]],
                "water": [[9926,true],[1843,true]]
            },
            {
                "baseline": [[6189,true],[1822,true]],
                "FAM": [[49142,false],[24322,false]],
                "HEX": [[11908,false],[22722,false]],
                "water": [[6189,true],[1822,true]]
            },
            {
                "baseline": [[10674,true],[2133,true]],
                "FAM": [[106136,false],[47080,false]],
                "HEX": [[22462,false],[42102,false]],
                "water": [[10674,true],[2133,true]]
            }
        ],
        
        "Ch1:Ch2": {
            "FAM": [1.406863,-0.425347,1.633333,4.803922,-9.868056,-0.235926,0.594856,-4.9,-3.811111,6.186869,1.020833,0.340278,0.704023,-0.888889,-0.106456,1.696728],
            "HEX": [0.870219,0.629768,3.175926,3.296024,1.361111,-0.297743,0.506897,-1.341241,-7.712963,0.291667,1.841503,0.680556,-1.681373,-1.852004,-0.397863,2.807292]
        },
        "valid": true
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["optical_test_dual_channel"](),
        response
    )
end

# error response body: 

function error_dualchannel_optical_response_test()
    response=JSON.parse("""{
        "valid": false,
        "error": "xxxx"
    }"""; dicttype=OrderedDict)
    verify_response(
        Action_DICT["optical_test_dual_channel"](),
        response
    )
end



# ********************************************************************************
#
#                               R U N   E X A M P L E S
#
# ********************************************************************************

function verify_response_examples()
    examples = [
        :standard_curve_response_test,
        :singlechannel_amplification_response_test,
        :dualchannel_amplification_response_test,
        :error_amplification_response_test,
        :singlechannel_meltcurve_response_test,
        :dualchannel_meltcurve_response_test,
        :error_meltcurve_response_test,
        :loadscript_response_test,
        :error_loadscript_response_test,
        :thermal_performance_diagnostic_response_test,
        :thermal_consistency_response_test,
        :valid_optical_cal_response_test,
        :invalid_optical_cal_response_test,
        :singlechannel_optical_response_test,
        :dualchannel_optical_response_test,
        :error_dualchannel_optical_response_test
    ]
    OrderedDict(map(examples) do f
        f => 
            try
                !getfield(Main,f)()
            catch err
                err
            end

    end)
end

# Usage:
# verify_response_examples() # every test should return true