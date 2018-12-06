# api_test.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# documentation of REST API from juliaapi_new.txt

import JSON

# ===================================================================================
# Here are the REST APIs using HTTP GET
# ===================================================================================

# experiments/:experiment_id/standard_curve

request=JSON.parse("[
    {\"well\": [
        {\"target\": 1, \"cq\": 999, \"quantity\": {\"m\":1.111, \"b\":-10}},
        {\"target\": 2, \"cq\": 999, \"quantity\": {\"m\":1.111, \"b\":-10}}
    ]},
    {\"well\": [
        {\"target\": 1, \"cq\": 999, \"quantity\": {\"m\":1.111, \"b\":-10}},
        {\"target\": 2, \"cq\": 999, \"quantity\": {\"m\":1.456, \"b\":12}}
    ]},
    {\"well\": [
        {\"target\": 1, \"cq\": 999, \"quantity\": {\"m\":1.111, \"b\":-10}},
        {\"target\": 2, \"cq\": 999, \"quantity\": {\"m\":3, \"b\":-12}}
    ]},
    {\"well\": [{}, {}]}
]")

function standard_curve_request_test(request)
    assert(isa(request,Array))
    n_targets=999
    for i in range(1,length(request))
        well=request[i]
        assert(isa(well,Dict))
        assert(length(well)==1)
        assert(haskey(well,"well"))
        array=well["well"]
        if (i==1)
            n_targets=length(array)
        else
            assert(length(array)==n_targets)
        end
        empty=false
        for j in range(1,n_targets)
            dict=array[j]
            assert(isa(dict,Dict))
            if (j==1)
                empty=(length(dict)==0)
            end
            if (empty)
                assert(length(dict)==0)
            else
                assert(length(dict)==3)
                k=keys(dict)
                assert(haskey(dict,"target"))
                assert(dict["target"]==j)
                assert(haskey(dict,"cq"))
                assert(isa(dict["cq"],Integer))
                assert(haskey(dict,"quantity"))
                subdict=dict["quantity"]
                assert(isa(subdict,Dict))
                assert(length(subdict)==2)
                assert(haskey(subdict,"m"))
                assert(haskey(subdict,"b"))
                assert(isa(subdict["m"],Number))
                assert(isa(subdict["b"],Number))
            end
        end
    end
    true
end

standard_curve_request_test(request) # true

response=JSON.parse("{
    \"targets\": 
    [
        {\"target_id\": 1, \"slope\": 9.99, \"offset\": 9.99, \"efficiency\": 1.02, \"r2\": 0.99}, 
        {\"target_id\": 2, \"slope\": 9.99, \"offset\": 9.99, \"efficiency\": 0.98, \"r2\": 0.99}, 
        {\"target_id\": 3, \"error\": \"xxxxx\"},
        {\"target_id\": 4, \"error\": \"xxxxx\"}
    ]
}")

function standard_curve_response_test(response)
    assert(isa(response,Dict))
    assert(length(response)==1)
    assert(haskey(response,"targets"))
    array=response["targets"]
    assert(isa(array,Array))
    for i in range(1,length(array))
        dict=array[i]
        assert(isa(dict,Dict))
        assert(haskey(dict,"target_id"))
        assert(dict["target_id"]==i)
        if (length(dict)==2)
            assert(haskey(dict,"error"))
            assert(isa(dict["error"],String))
        else
            assert(length(dict)==5)
            assert(haskey(dict,"slope"))
            assert(isa(dict["slope"],Number))
            assert(haskey(dict,"offset"))
            assert(isa(dict["offset"],Number))
            assert(haskey(dict,"efficiency"))
            assert(isa(dict["efficiency"],Number))
            assert(haskey(dict,"r2"))
            assert(isa(dict["r2"],Number))
        end
    end
    true
end

standard_curve_response_test(response) # true




# ********************************************************************************
# experiments/:experiment_id/amplification
#


request=JSON.parse("{
    \"experiment_id\": 99,
    \"step_id/ramp_id\": 99,
    \"min_reliable_cyc\": 5,
    \"calibration_info\": {
        \"water\": {
            \"fluorescence_value\": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        },
        \"channel_1\": {
            \"fluorescence_value\": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        },
        \"channel_2\": {
            \"fluorescence_value\": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        }
    },
    \"baseline_cyc_bounds\": [],
    \"baseline_method\": \"sigmoid\", 
    \"cq_method\": \"Cy0\",
    \"min_fluomax\": 4356,
    \"min_D1max\": 472,
    \"min_D2max\": 41,
    \"raw_data\": {
        \"fluorescence_value\": [],
        \"well_num\": [],
        \"cycle_num\": [],
        \"channel\": []
    }
}")

function amplification_request_test(request)
    assert(isa(request,Dict))
    assert(length(request)==11)
    assert(haskey(request,"experiment_id"))
    assert(isa(request["experiment_id"],Integer))
    assert(haskey(request,"step_id/ramp_id"))
    assert(isa(request["step_id/ramp_id"],Integer))
    assert(haskey(request,"min_reliable_cyc"))
    assert(isa(request["min_reliable_cyc"],Integer))
    assert(haskey(request,"calibration_info"))
    calib=request["calibration_info"]
    assert(isa(calib,Dict))
    assert(length(calib)==3)
    assert(haskey(calib,"water"))
    assert(isa(calib["water"],Dict))
    assert(length(calib["water"])==1)
    assert(haskey(calib["water"],"fluorescence_value"))
    assert(isa(calib["water"]["fluorescence_value"],Array))
    assert(length(calib["water"]["fluorescence_value"])==2)
    n_wells=length(calib["water"]["fluorescence_value"][1])
    assert(length(calib["water"]["fluorescence_value"][2])==n_wells)
    assert(haskey(calib,"channel_1"))
    assert(isa(calib["channel_1"],Dict))
    assert(length(calib["channel_1"])==1)
    assert(haskey(calib["channel_1"],"fluorescence_value"))
    assert(isa(calib["channel_1"]["fluorescence_value"],Array))
    assert(length(calib["channel_1"]["fluorescence_value"])==2)
    assert(length(calib["channel_1"]["fluorescence_value"][1])==n_wells)
    single_channel=(calib["channel_1"]["fluorescence_value"][2]==nothing)
    if (!single_channel)
        assert(length(calib["channel_1"]["fluorescence_value"][2])==n_wells)
    end
    assert(haskey(calib,"channel_2"))
    assert(isa(calib["channel_2"],Dict))
    assert(length(calib["channel_2"])==1)
    assert(haskey(calib["channel_2"],"fluorescence_value"))
    assert(isa(calib["channel_2"]["fluorescence_value"],Array))
    assert(length(calib["channel_2"]["fluorescence_value"])==2)
    assert(length(calib["channel_2"]["fluorescence_value"][1])==n_wells)
    if (single_channel)
        assert(calib["channel_2"]["fluorescence_value"][2]==nothing)
    else
        assert(length(calib["channel_2"]["fluorescence_value"][2])==n_wells)
    end
    assert(haskey(request,"baseline_cyc_bounds"))
    assert(isa(request["baseline_cyc_bounds"],Array))
    assert(haskey(request,"baseline_method"))
    assert(isa(request["baseline_method"],String))
    assert(
        request["baseline_method"] == "sigmoid" ||
        request["baseline_method"] == "linear"  ||
        request["baseline_method"] == "median" 
    )
    assert(haskey(request,"cq_method"))
    assert(isa(request["cq_method"],String))
    assert(request["cq_method"] == "Cy0")
    assert(haskey(request,"min_fluomax"))
    assert(isa(request["min_fluomax"],Number))
    assert(haskey(request,"min_D1max"))
    assert(isa(request["min_D1max"],Number))
    assert(haskey(request,"min_D2max"))
    assert(isa(request["min_D2max"],Number))
    assert(haskey(request,"raw_data"))
    raw=request["raw_data"]
    assert(isa(raw,Dict))
    assert(length(raw)==4)
    assert(haskey(raw,"fluorescence_value"))
    assert(isa(raw["fluorescence_value"],Array))
    n_raw=length(raw["fluorescence_value"])
    assert(haskey(raw,"well_num"))
    assert(isa(raw["well_num"],Array))
    assert(length(raw["well_num"])==n_raw)
    assert(haskey(raw,"cycle_num"))
    assert(isa(raw["cycle_num"],Array))
    assert(length(raw["cycle_num"])==n_raw)
    assert(haskey(raw,"channel"))
    assert(isa(raw["channel"],Array))
    assert(length(raw["channel"])==n_raw)
    true
end

amplification_request_test(request) # true

# Calibration (Water, channel_1, channel_2) data comes from the following sql query:
# 
# SELECT fluorescence_value, well_num, channel
#     FROM fluorescence_data
#     WHERE experiment_id = $calib_id AND step_id = $step_id
#     ORDER BY channel, well_num
# ;

# channel_2 will be NULL for single channel:
#     \"calibration_info\": {
#         \"water\": {
#             \"fluorescence_value\":[[channel_1__well_01, channel_1__well_02, …, channel_1__well_16],
#			      NULL]
#         },
#         \"channel_1\": {
#             \"fluorescence_value\":[[channel_1__well_01, channel_1__well_02, …, channel_1__well_16],
#			      NULL]
#         },
#         \"channel_2\": {
#             \"fluorescence_value\":[[channel_1__well_01, channel_1__well_02, …, channel_1__well_16],
#			      NULL]
#         }
#     },

# ????? the above does not look right ?????


# Raw Data comes from the following sql query:
#
# SELECT fluorescence_value, well_num, cycle_num, channel
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
# 	ORDER BY channel, well_num, cycle_num
# ;


response=JSON.parse("{

    # after deconvolution (if dual channel) and adjusting well-to-well variation,
    # before baseline subtraction
    \"rbbs_ary3\": [ 
        [
            [1.0101, 1.0102,    1.0140],
            [1.0201, 1.0202,    1.0240],
            
            [1.1601, 1.1602,    1.1640]
        ], # the only element if single-channel
        [
            [2.0101, 2.0102,    2.0140],
            [2.0201, 2.0202,    2.0240],
            
            [2.1601, 2.1602,    2.1640]
        ] # only exist if dual-channel
    ],

    # after baseline subtraction
    \"blsub_fluos\": [ 
        [
            [1.0101, 1.0102,    1.0140],
            [1.0201, 1.0202,    1.0240],
            
            [1.1601, 1.1602,    1.1640]
        ], 
        [
            [2.0101, 2.0102,    2.0140],
            [2.0201, 2.0202,    2.0240],
            
            [2.1601, 2.1602,    2.1640]
        ] # only exist if dual-channel
    ],
    
    # first derivative of the amp curve
    \"dr1_pred\": [ 
        [
            [1.0101, 1.0102,    1.0140],
            [1.0201, 1.0202,    1.0240],
            
            [1.1601, 1.1602,    1.1640]
        ], 
        [
            [2.0101, 2.0102,    2.0140],
            [2.0201, 2.0202,    2.0240],
            
            [2.1601, 2.1602,    2.1640]
        ] # only exist if dual-channel
    ],

    # second derivative of the amp curve
    \"dr2_pred\": [ 
        [
            [1.0101, 1.0102,    1.0140],
            [1.0201, 1.0202,    1.0240],
            
            [1.1601, 1.1602,    1.1640]
        ], 
        [
            [2.0101, 2.0102,    2.0140],
            [2.0201, 2.0202,    2.0240],
            
            [2.1601, 2.1602,    2.1640]
        ] # only exist if dual-channel
    ],

    \"cq\": [
        [1.01, 1.02,    1.16], # the only element if single-channel
        [2.01, 2.02,    2.16] # only exist if dual-channel
    ],

    # starting quantity from absolute quantification
    \"d0\": [
        [1.01, 1.02,    1.16], # the only element if single-channel
        [2.01, 2.02,    2.16] # only exist if dual-channel
    ],

    # fluorescence threshold if Ct method is used:
    # [channel_1] for single channel,
    # [channel_1, channel_2] for dual channel,
    # [] empty for automatic detection from data
    \"ct_fluos\": [], 

    # current data categories are: \"rbbs_ary3\", \"blsub_fluos\", \"d0\", \"cq\"
    #
    # \"assignments_adj_labels_dict\": { 
    #     \"data_category_1\": [well_01, well_02, ... well_16], 
    #     \"data_category_2\": [well_01, well_02, ... well_16], 
    #     ...
    # }
    \"assignments_adj_labels_dict\": { 
        \"rbbs_ary3\":   [1.01, 1.02,     1.16], 
        \"blsub_fluos\": [1.01, 1.02,     1.16],
        \"d0\":          [1.01, 1.02,     1.16], 
        \"cq\":          [1.01, 1.02,     1.16]
    }
}

function amplification_response_test(response)
    # to do
    true
end


# error response body:

response=JSON.parse("{
    \"error\": \"xxxx\"
}")

function amplification_response_test(response)
    assert(isa(response,Dict))
    assert(length(response)==1)
    assert(haskey(response,"error"))
    true
end

amplification_response_test(response) # true

# *************************************************************************************
# experiments/:experiment_id/meltcurve

request=JSON.parse("{
    \"experiment_id\": 2,
    \"stage_id\": 5,
    \"calibration_info\": {
        \"water\": {
            \"fluorescence_value\": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        },
        \"channel_1\": {
            \"fluorescence_value\": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        },
        \"channel_2\": {
            \"fluorescence_value\": [
                [1.01, 1.02,    1.15, 1.16],
                [2.01, 2.02,    2.15, 2.16]
            ]
        }
    },
    \"channel_nums\": [1,2],
    \"qt_prob\": 0.64,
    \"max_normd_qtv\": 0.8,
    \"top_N\": 4, 
    \"raw_data\": {
    	\"fluorescence_value\":[],
    	\"temperature\":[],
    	\"well_num\":[],
    	\"channel\":[]
    }
}")

# Notes:
# 
# channel_nums = [1] for 1 channel, [1,2] for 2 channels, etc.
# top_N = number of Tm peaks to report

function meltcurve_response_test(response)
    assert(isa(request,Dict))
    assert(length(request)==8)
    assert(haskey(request,"experiment_id"))
    assert(isa(request["experiment_id"],Integer))
    assert(haskey(request,"stage_id"))
    assert(isa(request["stage_id"],Integer))
    assert(haskey(request,"calibration_info"))
    calib=request["calibration_info"]
    assert(isa(calib,Dict))
    assert(length(calib)==3)
    assert(haskey(calib,"water"))
    assert(isa(calib["water"],Dict))
    assert(length(calib["water"])==1)
    assert(haskey(calib["water"],"fluorescence_value"))
    assert(isa(calib["water"]["fluorescence_value"],Array))
    assert(length(calib["water"]["fluorescence_value"])==2)
    n_wells=length(calib["water"]["fluorescence_value"][1])
    assert(length(calib["water"]["fluorescence_value"][2])==n_wells)
    assert(haskey(calib,"channel_1"))
    assert(isa(calib["channel_1"],Dict))
    assert(length(calib["channel_1"])==1)
    assert(haskey(calib["channel_1"],"fluorescence_value"))
    assert(isa(calib["channel_1"]["fluorescence_value"],Array))
    assert(length(calib["channel_1"]["fluorescence_value"])==2)
    assert(length(calib["channel_1"]["fluorescence_value"][1])==n_wells)
    single_channel=(calib["channel_1"]["fluorescence_value"][2]==nothing)
    if (!single_channel)
        assert(length(calib["channel_1"]["fluorescence_value"][2])==n_wells)
    end
    assert(haskey(calib,"channel_2"))
    assert(isa(calib["channel_2"],Dict))
    assert(length(calib["channel_2"])==1)
    assert(haskey(calib["channel_2"],"fluorescence_value"))
    assert(isa(calib["channel_2"]["fluorescence_value"],Array))
    assert(length(calib["channel_2"]["fluorescence_value"])==2)
    assert(length(calib["channel_2"]["fluorescence_value"][1])==n_wells)
    if (single_channel)
        assert(calib["channel_2"]["fluorescence_value"][2]==nothing)
    else
        assert(length(calib["channel_2"]["fluorescence_value"][2])==n_wells)
    end
    assert(haskey(request,"channel_nums"))
    assert(isa(request["channel_nums"],Array))
    assert(request["channel_nums"][1]==1)
    if (single_channel)
        assert(length(request["channel_nums"])==1)
    else
        assert(length(request["channel_nums"])==2)
        assert(request["channel_nums"][2]==2)
    end
    assert(haskey(request,"qt_prob"))
    assert(isa(request["qt_prob"],Number))
    assert(haskey(request,"max_normd_qtv"))
    assert(isa(request["max_normd_qtv"],Number))
    assert(haskey(request,"top_N"))
    assert(isa(request["top_N"],Integer))
    assert(haskey(request,"raw_data"))
    raw=request["raw_data"]
    assert(isa(raw,Dict))
    assert(length(raw)==4)
    assert(haskey(raw,"fluorescence_value"))
    assert(isa(raw["fluorescence_value"],Array))
    n_raw=length(raw["fluorescence_value"])
    assert(haskey(raw,"temperature"))
    assert(isa(raw["temperature"],Array))
    assert(length(raw["temperature"])==n_raw)
    assert(haskey(raw,"well_num"))
    assert(isa(raw["well_num"],Array))
    assert(length(raw["well_num"])==n_raw)
    assert(haskey(raw,"channel"))
    assert(isa(raw["channel"],Array))
    assert(length(raw["channel"])==n_raw)
    true
end

meltcurve_response_test(response) # true


# Calibration (Water, channel_1, channel_2) data comes from the following sql query:
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

# success response body:

# each matrix m is [[temperature_1, temperature_2 ...], [fluo_1, fluo_2, ...], [derivative_1, derivative_2 ...]]
m="[
    [0.101, 0.102, 0.103,    0.199], 
    [0.201, 0.202, 0.203,    0.299],  
    [0.301, 0.302, 0.303,    0.399]
]"
m1_01=m; m1_02=m; m1_16=m
m2_01=m; m2_02=m; m2_16=m

# single channel data

response=JSON.parse("{
    \"melt_curve_data\": [ 
        [ $(m1_01), $(m1_02),     $(m1_16) ]
    ],
    \"melt_curve_analysis\": [
        [ $(m1_01), $(m1_02),     $(m1_16) ]
    ]
}")

# dual channel data

response=JSON.parse("{
    \"melt_curve_data\": [ 
        [ $(m1_01), $(m1_02),     $(m1_16) ], 
        [ $(m2_01), $(m2_02),     $(m2_16) ]
    ]
    \"melt_curve_analysis\": [
        [ $(m1_01), $(m1_02),     $(m1_16) ], 
        [ $(m2_01), $(m2_02),     $(m2_16) ]
    ]
}")

function meltcurve_response_test(response)
    assert(isa(response,Dict))
    assert(length(response)==2)
    assert(haskey(response,"melt_curve_data"))
    assert(isa(response["melt_curve_data"],Array))
    n_channels=length(response["melt_curve_data"])
    n_wells=999
    n_stages=999
    for i in range(1,n_channels)
        channel=response["melt_curve_data"][i]
        assert(isa(channel,Array))
        if (i==1)
            n_wells=length(channel)
        else
            assert(length(channel)==n_wells)
        end
        for j in range(1,n_wells)
            well=channel[j]
            assert(isa(well,Array))
            assert(length(well)==3)
            for k in range(1,3)
                measurement=well[k]
                assert(isa(measurement,Array))
                if (i==1 && j==1 && k==1)
                    n_stages=length(measurement)
                else
                    assert(length(measurement)==n_stages)
                end
                for n in range(1,n_stages)
                    assert(isa(measurement[n],Number))
                end
            end
        end
    end
    assert(haskey(response,"melt_curve_analysis"))
    assert(isa(response["melt_curve_analysis"],Array))
    assert(length(response["melt_curve_analysis"])==n_channels)
    for i in range(1,n_channels)
        channel=response["melt_curve_analysis"][i]
        assert(isa(channel,Array))
        assert(length(channel)==n_wells)
        for j in range(1,n_wells)
            well=channel[j]
            assert(isa(well,Array))
            assert(length(well)==3)
            for k in range(1,3)
                measurement=well[k]
                assert(isa(measurement,Array))
                assert(length(measurement)==n_stages)
                for n in range(1,n_stages)
                    assert(isa(measurement[n],Number))
                end
            end
        end
    end
    true
end

meltcurve_response_test(response) # true

# error response body:

response=JSON.parse("{
    \"error\": \"xxxx\"
}")

function meltcurve_response_test(response)
    assert(isa(response,Dict))
    assert(length(response)==1)
    assert(haskey(response,"error"))
    true
end

meltcurve_response_test(response) # true



*************************************************************************************
system/loadscript?script=path%2Fto%2Fanalyze.jl

# success response body:

response=JSON.parse("{
    \"script\": \"path/to/analyze.jl\"
}")

function loadscript_response_test(response)
    assert(isa(response,Dict))
    assert(length(response)==1)
    assert(haskey(response,"script"))
    assert(isa(response["script"],String))
    true
end

loadscript_response_test(response) # true


# error response body:

response=JSON.parse("{
    \"error\": \"xxxx\"
}")

function loadscript_response_test(response)
    assert(isa(response,Dict))
    assert(length(response)==1)
    assert(haskey(response,"error"))
    true
end

loadscript_response_test(response) # true




*************************************************************************************
experiments/:experiment_id/optical_cal

request body:
{
    \"calibration_info\": {
        \"water\": {
	    \"fluorescence_value\":[[channel_1__well_01, channel_1__well_02, …, channel_1__well_16],
				  [channel_2__well_01, channel_2__well_02, …, channel_2__well_16]]
        },
        \"channel_1\": {
	    \"fluorescence_value\":[[channel_1__well_01, channel_1__well_02, …, channel_1__well_16],
				  [channel_2__well_01, channel_2__well_02, …, channel_2__well_16]]
        },
        \"channel_2\": {
	    \"fluorescence_value\":[[channel_1__well_01, channel_1__well_02, …, channel_1__well_16],
				  [channel_2__well_01, channel_2__well_02, …, channel_2__well_16]]
        }
    }
}

success response body (optical_cal):
{\"valid\": true}
or
{\"valid\": false, \"error_message\": \"xxxx\"}




*************************************************************************************
experiments/:experiment_id/thermal_performance_diagnostic

request body:
{
  \"lid_temp\": [],
  \"heat_block_zone_1_temp\": [],
  \"heat_block_zone_2_temp\": [],
  \"elapsed_time\", [],
  \"cycle_num\": [],
}

MySQL query it is used:
SELECT *
    FROM temperature_logs
    WHERE experiment_id = $exp_id
    ORDER BY id
;

success response body (thermal_performance_diagnostic):
{
    \"Heating\":  {
        \"AvgRampRate\":[5.3743,true],
        \"TotalTime\":[8001,false],
        \"MaxBlockDeltaT\":[1.27,true]
    },
    \"Cooling\": {
        \"AvgRampRate\":[0,false],
        \"TotalTime\":[9000,false],
        \"MaxBlockDeltaT\":[0.94,true]
    },
    \"Lid\": {
        \"HeatingRate\":[1.3031,true],
        \"TotalTime\":[32999,false]}
    }
}




*************************************************************************************
experiments/:experiment_id/thermal_consistency

request body:
{
  \"raw_data\": {
	\"fluorescence_value\":[],
	\"temperature\":[],
	\"well_num\":[],
	\"channel\":[]
  },
  
  \"calibration_info\": {
        \"water\": {
	    \"fluorescence_value\":[[channel_1__well_01, channel_1__well_02, …, channel_1__well_16],
				  [channel_2__well_01, channel_2__well_02, …, channel_2__well_16]]
        },
        \"channel_1\": {
	    \"fluorescence_value\":[[channel_1__well_01, channel_1__well_02, …, channel_1__well_16],
				  [channel_2__well_01, channel_2__well_02, …, channel_2__well_16]]
        },
        \"channel_2\": {
	    \"fluorescence_value\":[[channel_1__well_01, channel_1__well_02, …, channel_1__well_16],
				  [channel_2__well_01, channel_2__well_02, …, channel_2__well_16]]
        }
  }
}

MySQL query it is used:

SELECT fluorescence_value, temperature, well_num, channel
    FROM melt_curve_data
    WHERE
        experiment_id = $exp_id AND
        stage_id = $stage_id
	ORDER BY channel, well_num
;

success response body (thermal_consistency):
{
    \"tm_check\": [
        {
            \"Tm\":[79.0773,true],
            \"Area\":1361.5005
        },
        {
            \"Tm\":[78.5635,true],
            \"Area\":1763.7998
        },
        {
            \"Tm\":[78.4396,true],
            \"Area\":1434.3995
        },
        {
            \"Tm\":[78.2172,true],
            \"Area\":1672.9787
        },
        {
            \"Tm\":[77.8384,true],
            \"Area\":639.2474
        },
        {
            \"Tm\":[78.3816,true],
            \"Area\":1076.2143
        },
        {
            \"Tm\":[78.6829,true],
            \"Area\":895.6206
        },
        {
            \"Tm\":[78.6403,true],
            \"Area\":366.6082
        },
        {
            \"Tm\":[78.0791,true],
            \"Area\":255.8169
        },
        {
            \"Tm\":[77.5054,true],
            \"Area\":193.9588
        },
        {
            \"Tm\":[78.0182,true],
            \"Area\":1114.7039
        },
        {
            \"Tm\":[78.171,true],
            \"Area\":1324.3671
        },
        {
            \"Tm\":[78.1117,true],
            \"Area\":1219.4364
        },
        {
            \"Tm\":[77.8815,true],
            \"Area\":499.9462
        },
        {
            \"Tm\":[78.3167,true],
            \"Area\":1097.0781
        },
        {
            \"Tm\":[79.2487,true],
            \"Area\":1318.3026
        }
    ],
    \"delta_Tm\":[1.7434,true]
}




*************************************************************************************
experiments/:experiment_id/optical_test_single_channel

request body:
{
  \"baseline\": {
	\"fluorescence_value\":[well_01, well_02, …, well_16]
  },

  \"excitation\": {
	\"fluorescence_value\":[well_01, well_02, …, well_16]
  }
}

MySQL query it is used:
SELECT fluorescence_value, well_num, cycle_num
    FROM fluorescence_data
    WHERE experiment_id = $exp_id AND step_id = $step_id
    ORDER BY well_num, cycle_num
;


success response body (optical_test_single_channel):
{\"optical_data\":[
    {
        \"baseline\":1704,
        \"excitation\":84756,
        \"valid\":true
    },{
        \"baseline\":1844,
        \"excitation\":76751,
        \"valid\":true
    },{
        \"baseline\":1729,
        \"excitation\":75655,
        \"valid\":true
    },{
        \"baseline\":1695,
        \"excitation\":32242,
        \"valid\":true
    },{
        \"baseline\":1683,
        \"excitation\":71588,
        \"valid\":true
    },{
        \"baseline\":1837,
        \"excitation\":96184,
        \"valid\":true
    },{
        \"baseline\":1696,
        \"excitation\":90374,
        \"valid\":true
    },{
        \"baseline\":1848,
        \"excitation\":88519,
        \"valid\":true
    },{
        \"baseline\":1675,
        \"excitation\":105414,
        \"valid\":true
    },{
        \"baseline\":1731,
        \"excitation\":90122,
        \"valid\":true
    },{     
        \"baseline\":1718,
        \"excitation\":94174,
        \"valid\":true
    },{
        \"baseline\":1803,
        \"excitation\":110185,
        \"valid\":true
    },{
        \"baseline\":1797,
        \"excitation\":92436,
        \"valid\":true
    },{
        \"baseline\":1773,
        \"excitation\":35866,
        \"valid\":true
    },{
        \"baseline\":1789,
        \"excitation\":101293,
        \"valid\":true
    },{
        \"baseline\":1864,
        \"excitation\":98680,
        \"valid\":true
    }
]}




*************************************************************************************
experiments/:experiment_id/optical_test_dual_channel

request body:
{
  \"baseline\": {
	\"fluorescence_value\":[well_01, well_02, …, well_16]
  },

  \"water\": {
	\"fluorescence_value\":[well_01, well_02, …, well_16]
  },

  \"FAM\": {
	\"fluorescence_value\":[well_01, well_02, …, well_16]
  },
  
  \"HEX\": {
	\"fluorescence_value\":[well_01, well_02, …, well_16]
  }
}

MySQL query it is used:
SELECT fluorescence_value, well_num, cycle_num
    FROM fluorescence_data
    WHERE experiment_id = $exp_id AND step_id = $step_id
    ORDER BY well_num, cycle_num
;

success response body (optical_test_dual_channel):
{
    \"optical_data\":[
        {
            \"baseline\":[[7373,true],[1790,true]],
            \"FAM\":[[56997,false],[25204,false]],
            \"HEX\":[[10827,false],[24547,false]],
            \"water\":[[7373,true],[1790,true]]
        },
        {
            \"baseline\":[[16590,true],[1908,true]],
            \"FAM\":[[113931,false],[44197,false]],
            \"HEX\":[[21176,false],[43755,false]],
            \"water\":[[16590,true],[1908,true]]
        },
        {
            \"baseline\":[[10622,true],[1945,true]],
             \"FAM\":[[97683,false],[40424,false]],
             \"HEX\":[[14754,false],[39349,false]],
            \"water\":[[10622,true],[1945,true]]
        },
        {
            \"baseline\":[[3194,true],[1692,true]],
            \"FAM\":[[15820,false],[7494,false]],
            \"HEX\":[[4289,false],[7489,false]],
            \"water\":[[3194,true],[1692,true]]
        },
        {
            \"baseline\":[[7210,true],[1623,true]],
            \"FAM\":[[56260,false],[22039,false]],
            \"HEX\":[[10460,false],[22624,false]],
            \"water\":[[7210,true],[1623,true]]
        },
        {
            \"baseline\":[[9309,true],[1958,true]],
            \"FAM\":[[75858,false],[30542,false]],
            \"HEX\":[[14908,false],[31364,false]],
            \"water\":[[9309,true],[1958,true]]
        },
        {
            \"baseline\":[[9923,true],[1804,true]],
            \"FAM\":[[76166,false],[32064,false]],
            \"HEX\":[[19045,false],[32810,false]],
            \"water\":[[9923,true],[1804,true]]
        },
        {
            \"baseline\":[[17224,true],[2063,true]],
            \"FAM\":[[110970,false],[39879,false]],
            \"HEX\":[[33050,false],[41685,false]],
            \"water\":[[17224,true],[2063,true]]
        },
        {
            \"baseline\":[[6116,true],[2098,true]],
            \"FAM\":[[75856,false],[35634,false]],
            \"HEX\":[[9767,false],[33825,false]],
            \"water\":[[6116,true],[2098,true]]
        },
        {
            \"baseline\":[[11647,true],[1967,true]],
            \"FAM\":[[118257,false],[43666,false]],
            \"HEX\":[[19407,false],[42969,false]],
            \"water\":[[11647,true],[1967,true]]
        },
        {
            \"baseline\":[[10132,true],[2558,true]],
            \"FAM\":[[80505,false],[35494,false]],
            \"HEX\":[[14507,false],[34011,false]],
            \"water\":[[10132,true],[2558,true]]
        },
        {
            \"baseline\":[[7019,true],[2757,true]],
            \"FAM\":[[66396,false],[25384,false]],
            \"HEX\":[[10391,false],[24408,false]],
            \"water\":[[7019,true],[2757,true]]
        },
        {
            \"baseline\":[[12806,true],[1900,true]],
            \"FAM\":[[117630,false],[45047,false]],
            \"HEX\":[[21790,false],[42365,false]],
            \"water\":[[12806,true],[1900,true]]
        },
        {
            \"baseline\":[[9926,true],[1843,true]],
            \"FAM\":[[70441,false],[24076,false]],
            \"HEX\":[[17115,false],[22416,false]],
            \"water\":[[9926,true],[1843,true]]
        },
        {
            \"baseline\":[[6189,true],[1822,true]],
            \"FAM\":[[49142,false],[24322,false]],
            \"HEX\":[[11908,false],[22722,false]],
            \"water\":[[6189,true],[1822,true]]
        },
        {
            \"baseline\":[[10674,true],[2133,true]],
            \"FAM\":[[106136,false],[47080,false]],
            \"HEX\":[[22462,false],[42102,false]],
            \"water\":[[10674,true],[2133,true]]
        }
    ],
    
    \"Ch1:Ch2\":{
        \"FAM\":[1.406863,-0.425347,1.633333,4.803922,-9.868056,-0.235926,0.594856,-4.9,-3.811111,6.186869,1.020833,0.340278,0.704023,-0.888889,-0.106456,1.696728],
        \"HEX\":[0.870219,0.629768,3.175926,3.296024,1.361111,-0.297743,0.506897,-1.341241,-7.712963,0.291667,1.841503,0.680556,-1.681373,-1.852004,-0.397863,2.807292]
    }
}

# error response body:

response=JSON.parse("{
    \"error\": \"xxxx\"
}")

assert(isa(response,Dict))
assert(length(response)==1)
assert(haskey(response,"error"))
