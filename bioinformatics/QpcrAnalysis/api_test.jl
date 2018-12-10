# api_test.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# This Julia script tests the JSON data structures 
# that are supplied in the body of GET requests and 
# returned in the body of the responses.
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

# ================================================================================
# Here are the REST APIs using HTTP GET
# ================================================================================

# ********************************************************************************
#
# call: experiments/:experiment_id/standard_curve
#
# ********************************************************************************

# request

function standard_curve_request_test(request)
    @assert (isa(request,Array))
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
            OrderedDict=array[j]
            @assert (isa(OrderedDict,OrderedDict))
            if (empty)
                @assert (length(OrderedDict)==0)
            else
                @assert (length(OrderedDict)==3)
                k=keys(OrderedDict)
                @assert (haskey(OrderedDict,"target"))
                @assert (OrderedDict["target"]==j)
                @assert (haskey(OrderedDict,"cq"))
                @assert (isa(OrderedDict["cq"],Integer))
                @assert (haskey(OrderedDict,"quantity"))
                subOrderedDict=OrderedDict["quantity"]
                @assert (isa(subOrderedDict,OrderedDict))
                @assert (length(subOrderedDict)==2)
                @assert (haskey(subOrderedDict,"m"))
                @assert (haskey(subOrderedDict,"b"))
                @assert (isa(subOrderedDict["m"],Number))
                @assert (isa(subOrderedDict["b"],Number))
            end
        end
    end
    true
end

function example_amplification_standard_curve_request_test()
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
    ]""")
    standard_curve_request_test(request)
end


# response

function standard_curve_response_test(response)
    @assert (isa(response,OrderedDict))
    @assert (length(response)==1)
    @assert (haskey(response,"targets"))
    array=response["targets"]
    @assert (isa(array,Array))
    for i in range(1,length(array))
        OrderedDict=array[i]
        @assert (isa(OrderedDict,OrderedDict))
        @assert (haskey(OrderedDict,"target_id"))
        @assert (OrderedDict["target_id"]==i)
        if (length(OrderedDict)==2)
            @assert (haskey(OrderedDict,"error"))
            @assert (isa(OrderedDict["error"],String))
        else
            @assert (length(OrderedDict)==5)
            @assert (haskey(OrderedDict,"slope"))
            @assert (isa(OrderedDict["slope"],Number))
            @assert (haskey(OrderedDict,"offset"))
            @assert (isa(OrderedDict["offset"],Number))
            @assert (haskey(OrderedDict,"efficiency"))
            @assert (isa(OrderedDict["efficiency"],Number))
            @assert (haskey(OrderedDict,"r2"))
            @assert (isa(OrderedDict["r2"],Number))
        end
    end
    true
end

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
    standard_curve_response_test(response)
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

function calibration_test(calib)
    conditions=["water","channel_1","channel_2"]
    channels=["channel_1","channel_2"]
    n_channels=(calib["water"]["fluorescence_value"][2]==nothing) ? 1 : 2
    n_wells=length(calib["water"]["fluorescence_value"][1])
    @assert (isa(calib,OrderedDict))
    @assert (length(calib)<=3)
    for condition in conditions[range(1,n_channels+1)]
        @assert (haskey(calib,condition))
        @assert (isa(calib[condition],OrderedDict))
        @assert (length(calib[condition])==1)
        @assert (haskey(calib[condition],"fluorescence_value"))
        @assert (isa(calib[condition]["fluorescence_value"],Array))
        @assert (length(calib[condition]["fluorescence_value"])<=2)
        for channel in range(1,n_channels)
            if (condition=="water"||condition==channel)
                @assert (isa(calib[condition]["fluorescence_value"][channel],Array))
                @assert (length(calib[condition]["fluorescence_value"][channel])==n_wells)
                for i in range(1,n_wells)
                            @assert (isa(calib[condition]["fluorescence_value"][channel][i],Number))
                end
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
    @assert (length(raw)==4)
    variables=["fluorescence_value","channel","well_num"]
    if (haskey(raw,"temperature"))
        push!(variables,"temperature")
    else
        push!(variables,"cycle_num")
    end
    n_raw=length(raw["fluorescence_value"])
    for v in variables
        @assert (haskey(raw,v))
        @assert (isa(raw[v],Array))
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

function amplification_request_test(request)
    @assert (isa(request,OrderedDict))
    @assert (length(request)==11)
    @assert (haskey(request,"experiment_id"))
    @assert (isa(request["experiment_id"],Integer))
    if (haskey(request,"step_id"))
        id="step_id"
    else
        id="ramp_id"
    end
    @assert (haskey(request,id))
    @assert (isa(request[id],Integer))
    @assert (haskey(request,"min_reliable_cyc"))
    @assert (isa(request["min_reliable_cyc"],Integer))
    @assert (haskey(request,"baseline_cyc_bounds"))
    @assert (isa(request["baseline_cyc_bounds"],Array))
    if (length(request["baseline_cyc_bounds"])>0)
        @assert (length(request["baseline_cyc_bounds"])==2)
        @assert (isa(request["baseline_cyc_bounds"][1],Integer))
        @assert (isa(request["baseline_cyc_bounds"][2],Integer))
    end
    @assert (haskey(request,"baseline_method"))
    @assert (isa(request["baseline_method"],String))
    @assert (
        request["baseline_method"] == "sigmoid" ||
        request["baseline_method"] == "linear"  ||
        request["baseline_method"] == "median" 
    )
    @assert (haskey(request,"cq_method"))
    @assert (isa(request["cq_method"],String))
    @assert (request["cq_method"] == "Cy0")
    @assert (haskey(request,"min_fluomax"))
    @assert (isa(request["min_fluomax"],Number))
    @assert (haskey(request,"min_D1max"))
    @assert (isa(request["min_D1max"],Number))
    @assert (haskey(request,"min_D2max"))
    @assert (isa(request["min_D2max"],Number))
    @assert (haskey(request,"calibration_info"))
    @assert (haskey(request,"raw_data"))
    raw=request["raw_data"]
    @assert (isa(raw,OrderedDict))
    calibration_test(request["calibration_info"]) && raw_test(raw)
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
    amplification_request_test(request)
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
    amplification_request_test(request) 
end

# not in run_examples()
function more_amplification_request_tests()

    # Notes

    # The following are not implemented yet:
    # ensure_ci in shared.jl
    # get_mysql_data_well in shared.jl
    # get_k in deconv.jl <- deconV in deconv.jl <- dcv_aw in calib.jl
    #                    <- analyze_customized/optical_cal.jl

    # startup script
    #
    # ;cd ~/chaipcr/bioinformatics/QpcrAnalysis
    # ;sudo mount -t vboxsf shared /mnt/share
    # 
    #
    push!(LOAD_PATH,pwd())
    using QpcrAnalysis

    import Clustering.ClusteringResult
    import DataStructures.OrderedDict
    import JuMP.@variable
    import JuMP.@objective
    import JuMP.@NLobjective
    import JuMP.@constraint
    import JuMP.Model
    import Ipopt.IpoptSolver
    import JuMP.solve
    import JuMP.getvalue
    import JuMP.getobjectivevalue
    include("amp_models/sfc_models.jl")
    include("amp_models/types_for_amp_models.jl")
    include("types_for_allelic_discrimination.jl")
    include("allelic_discrimination.jl")
    include("shared.jl")
    include("deconv.jl")
    include("/mnt/share/amp.jl")
    include("allelic_discrimination.jl")
    calib_info_AIR = 1

    include("/mnt/share/amp.jl")

    include("/mnt/share/dispatch.jl")
    include("/mnt/share/api_test.jl")
    include("/mnt/share/calib.jl")
    include("/mnt/share/adj_w2wvaf.jl")
    include("/mnt/share/shared.jl")


    # request = JSON.parsefile("~/chaibio/bioinformatics/test/singlechannel_amplification_request.json"; dicttype=OrderedDict)
    request = JSON.parsefile("/mnt/share/singlechannel_amplification_request.json"; dicttype=OrderedDict)

    amplification_request_test(request)
    result = dispatch("amplification",String(JSON.json(request)))
    response = JSON.parse(result[2],dicttype=OrderedDict)
    amplification_response_test(response)


    # request = JSON.parsefile("~/chaibio/bioinformatics/test/dualchannel_amplification_request.json"; dicttype=OrderedDict)
    request = JSON.parsefile("/mnt/share/dualchannel_amplification_request.json"; dicttype=OrderedDict)

    amplification_request_test(request)

    # test Julia server

    request = JSON.parsefile("/mnt/share/dualchannel_amplification_request.json"; dicttype=OrderedDict)

    amplification_request_test(request)
    dispatch("amplification",String(JSON.json(request)))

    # run(`curl \
    #     --header "Content-Type: application/json" \
    #     --request "GET" \
    #     --data $(JSON.json(request)) \
    #     http://localhost:8081/experiments/250/amplification`)

    # curl \
    #     --header "Content-Type: application/json" \
    #     --data @/mnt/share/dualchannel_amplification_request.json \
    #     http://localhost:8081/experiments/250/amplification
end






# response

function amplification_response_test(response)
    @assert (isa(response,OrderedDict))
    if (length(response)==1)
        @assert (haskey(response,"error"))
        @assert (isa(response["error"],String))
        return true
    end
    # else
    @assert (length(response)==8)
    measurements=["rbbs_ary3","blsub_fluos","dr1_pred","dr2_pred"]
    n_channels=length(response["rbbs_ary3"])
    @assert (n_channels==1 || n_channels==2)
    n_wells=length(response["rbbs_ary3"][1])
    n_steps=length(response["rbbs_ary3"][1][1])
    n_pred=length(response["dr1_pred"][1][1])
    for m in measurements
        @assert (haskey(response,m))
        @assert (isa(response[m],Array))
        @assert (length(response[m])==n_channels)
        for c in range(1,n_channels)
            @assert (isa(response[m][c],Array))
            @assert (length(response[m][c])==n_wells)
            for i in range(1,n_wells)
                @assert (isa(response[m][c][i],Array))
                if (m=="rbbs_ary3" || m=="blsub_fluos")
                    @assert (length(response[m][c][i])==n_steps)
                    for j in range(1,n_steps)
                        @assert (isa(response[m][c][i][j],Number) || response[m][c][i][j]==nothing)
                    end
                else # dr1_pred, dr2_pred
                    @assert (length(response[m][c][i])==n_pred)
                    for j in range(1,n_pred)
                        @assert (isa(response[m][c][i][j],Number) || response[m][c][i][j]==nothing)
                    end
                end
            end
        end
    end
    statistics=["cq","d0"]
    for s in statistics
        @assert (haskey(response,s))
        @assert (isa(response[s],Array))
        @assert (length(response[s])==n_channels)
        for c in range(1,n_channels)
            @assert (isa(response[s][c],Array))
            @assert (length(response[s][c])==n_wells)
            for i in range(1,n_wells)
                @assert (isa(response[s][c][i],Number) || response[s][c][i]==nothing)
            end
        end
    end
    @assert (haskey(response,"ct_fluos"))
    @assert (isa(response["ct_fluos"],Array))
    @assert (length(response["ct_fluos"])==n_channels)
    for c in range(1,n_channels)
        @assert (isa(response["ct_fluos"][c],Number) || response["ct_fluos"][c]==nothing)
    end
    variables=["rbbs_ary3","blsub_fluos","cq","d0"]
    @assert (haskey(response,"assignments_adj_labels_dict"))
    @assert (isa(response["assignments_adj_labels_dict"],OrderedDict))
    # @assert (length(response["assignments_adj_labels_dict"])==n_genotypes)
    for g in range(1,length(response["assignments_adj_labels_dict"]))
        @assert (isa(response["assignments_adj_labels_dict"][g],Array))
        @assert (length(response["assignments_adj_labels_dict"][g])==n_wells)
        for i in range(1,n_wells)
            @assert (isa(response["assignments_adj_labels_dict"][g][i],Number))
        end
    end
    true
end

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
    """*
        # current data categories are: "rbbs_ary3", "blsub_fluos", "d0", "cq"
        #
        # "assignments_adj_labels_OrderedDict": { 
        #     "data_category_1": [well_01, well_02, ... well_16], 
        #     "data_category_2": [well_01, well_02, ... well_16], 
        #     ...
        # }
    """
        "assignments_adj_labels_OrderedDict": { 
            "rbbs_ary3":   [1.01, 1.02,     1.16], 
            "blsub_fluos": [1.01, 1.02,     1.16],
            "d0":          [1.01, 1.02,     1.16], 
            "cq":          [1.01, 1.02,     1.16]
        }
    }"""; dicttype=OrderedDict)
    amplification_response_test(response)
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
    """*
        # current data categories are: "rbbs_ary3", "blsub_fluos", "d0", "cq"
        #
        # "assignments_adj_labels_OrderedDict": { 
        #     "data_category_1": [well_01, well_02, ... well_16], 
        #     "data_category_2": [well_01, well_02, ... well_16], 
        #     ...
        # }
    """
        "assignments_adj_labels_OrderedDict": { 
            "rbbs_ary3":   [1.01, 1.02,     1.16], 
            "blsub_fluos": [1.01, 1.02,     1.16],
            "d0":          [1.01, 1.02,     1.16], 
            "cq":          [1.01, 1.02,     1.16]
        }
    }"""; dicttype=OrderedDict)
    amplification_response_test(response)
end

# error response body: 

function error_amplification_response_test()
    response=JSON.parse("""{
        "error": "xxxx"
    }"""; dicttype=OrderedDict)
    amplification_response_test(response)
end


# From experiments_controller.rb
#
# api :GET, "/experiments/:id/amplification_data?raw=false&background=true&baseline=true&firstderiv=true&secondderiv=true&summary=true&step_id[]=43&step_id[]=44", "Retrieve amplification data"
# example "{
#    'partial':false, 
#    'total_cycles':40, 
#    'steps':[
#        'step_id':2, [
#            'amplification_data':[
#                ['target_id', 'well_num', 'cycle_num', 'background_subtracted_value',
#                    'baseline_subtracted_value', 'dr1_pred', 'dr2_pred' 'fluorescence_value'], 
#                [1, 1, 1, 25488, -2003, 34543, 453344, 86], 
#                [1, 1, 2, 53984, -409, 56345, 848583, 85]
#            ],
#            'summary_data':[
#                ['target_id','well_num','replic_group','cq','quantity_m','quantity_b','mean_cq',
#                    'mean_quantity_m','mean_quantity_b'],
#                [1,1,null,null,null,null,null,null,null],
#                [2,12,1,7.314787,4.0,2,6.9858934999999995,4.0,2],
#                [2,14,1,6.657,4.0,2,6.9858934999999995,4.0,2],
#                [2,3,null,6.2,5.7952962,14,null,null,null]
#            ],
#            'targets':[
#                ['id','name','equation'],
#                [1,'target1',null],
#                [2,'target2',{
#                    'slope':-0.064624,'offset':7.154049,'efficiency':2979647189313701.5,'r2':0.221279
#                }]
#            ]
#        ]
#    ]
#}"





# ********************************************************************************
#
# call: experiments/:experiment_id/meltcurve
#
#
# ********************************************************************************

# request

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


function meltcurve_request_test(request)
    @assert (isa(request,OrderedDict))
    @assert (length(request)==8)
    @assert (haskey(request,"experiment_id"))
    @assert (isa(request["experiment_id"],Integer))
    @assert (haskey(request,"stage_id"))
    @assert (isa(request["stage_id"],Integer))
    @assert (haskey(request,"calibration_info"))
    calib=request["calibration_info"]
    @assert (haskey(request,"channel_nums"))
    @assert (isa(request["channel_nums"],Array))
    if (calib["water"]["fluorescence_value"][2]==nothing)
        @assert (request["channel_nums"]==[1])
    else
        @assert (request["channel_nums"]==[1,2])
    end
    @assert (haskey(request,"qt_prob"))
    @assert (isa(request["qt_prob"],Number))
    @assert (haskey(request,"max_normd_qtv"))
    @assert (isa(request["max_normd_qtv"],Number))
    @assert (haskey(request,"top_N"))
    @assert (isa(request["top_N"],Integer))
    @assert (haskey(request,"raw_data"))
    raw=request["raw_data"]
    calibration_test(calib) && raw_test(raw)
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
    meltcurve_request_test(request)
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
    meltcurve_request_test(request)
end


# success response body: 

function meltcurve_response_test(response)
    @assert (isa(response,OrderedDict))
    if (length(response)==1)
        @assert (haskey(response,"error"))
        @assert (isa(response["error"],String))
        return true
    end
    # else
    variables=["melt_curve_data","melt_curve_analysis"]
    @assert (length(response)==length(variables))
    n_channels=length(response["melt_curve_data"])
    n_wells=length(response["melt_curve_data"][1])
    n_stages=length(response["melt_curve_data"][1][1][1])
    for v in variables
        @assert (haskey(response,v))
        @assert (isa(response[v],Array))
        @assert (length(response[v])==n_channels)
        for i in range(1,n_channels) # channel
            @assert (isa(response[v][i],Array))
            @assert (length(response[v][i])==n_wells)
            for j in range(1,n_wells) # well
                @assert (isa(response[v][i][j],Array))
                @assert (length(response[v][i][j])==3)
                for k in range(1,3) # measurement
                    @assert (isa(response[v][i][j][k],Array))
                    @assert (length(response[v][i][j][k])==n_stages)
                    for n in range(1,n_stages) # stage
                        @assert (isa(response[v][i][j][k][n],Number))
                    end
                end
            end
        end
    end
    true
end

# each matrix m is [[temperature_1, temperature_2 ...], [fluo_1, fluo_2, ...], [derivative_1, derivative_2 ...]]
m="[
    [0.101, 0.102, 0.103,    0.199], 
    [0.201, 0.202, 0.203,    0.299],  
    [0.301, 0.302, 0.303,    0.399]
]"
m1_01=m; m1_02=m; m1_16=m
m2_01=m; m2_02=m; m2_16=m

# single channel data

function singlechannel_meltcurve_response_test()
    response=JSON.parse("""{
        "melt_curve_data": [ 
            [ $(m1_01), $(m1_02),     $(m1_16) ]
        ],
        "melt_curve_analysis": [
            [ $(m1_01), $(m1_02),     $(m1_16) ]
        ]
    }"""; dicttype=OrderedDict)
    meltcurve_response_test(response)
end

# dual channel data

function dualchannel_meltcurve_response_test()
    response=JSON.parse("""{
        "melt_curve_data": [ 
            [ $(m1_01), $(m1_02),     $(m1_16) ], 
            [ $(m2_01), $(m2_02),     $(m2_16) ]
        ],
        "melt_curve_analysis": [
            [ $(m1_01), $(m1_02),     $(m1_16) ], 
            [ $(m2_01), $(m2_02),     $(m2_16) ]
        ]
    }"""; dicttype=OrderedDict)
    meltcurve_response_test(response)
end

# error response body: 

function error_meltcurve_response_test()
    response=JSON.parse("""{
        "error": "xxxx"
    }"""; dicttype=OrderedDict)
    meltcurve_response_test(response)
end

# from experiments_controller.rb:
#
# api :GET, "/experiments/:id/melt_curve_data?raw=false&normalized=true&derivative=true&tm=true&ramp_id[]=43&ramp_id[]=44", "Retrieve melt curve data"
#
# example "{
#    'partial':false,
#    'ramps':[
#        'ramp_id':22,
#        'melt_curve_data':[
#            {
#                'well_num':1,
#                'temperature':[0,1,2,3,4,5],
#                'normalized_data':[0,1,2,3,4,5],
#                'derivative_data':[0,1,2,3,4,5],
#                'tm':[1,2,3],
#                'area':[2,4,5]
#            },
#            {
#                'well_num':2,
#                'temperature':[0,1,2,3,4,5],
#                'normalized_data':[0,1,2,3,4,5],
#                'derivative_data':[0,1,2,3,4,5],
#                'tm':[1,2,3],
#                'area':[2,4,5]
#            }
#        ]
#    ]
#}"



# ********************************************************************************
#
# call: system/loadscript?script=path%2Fto%2Fanalyze.jl
#
# 
# ********************************************************************************

# success response body: 

function loadscript_response_test(response)
    @assert (isa(response,OrderedDict))
    @assert (length(response)==1)
    if (haskey(response,"error"))
        @assert (isa(response["error"],String))
        return true
    end
    # else
    @assert (haskey(response,"script"))
    @assert (isa(response["script"],String))
    true
end

function example_loadscript_response_test()
    response=JSON.parse("""{
        "script": "path/to/analyze.jl"
    }"""; dicttype=OrderedDict)
    loadscript_response_test(response) 
end

# error response body: 

function error_loadscript_response_test()
    response=JSON.parse("""{
        "error": "xxxx"
    }"""; dicttype=OrderedDict)
    loadscript_response_test(response) 
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_cal
#
# ? not implemented in Rails yet
#
# ********************************************************************************

# request body: 

function optical_cal_request_test(request)
    @assert (isa(request,OrderedDict))
    @assert (haskey(request,"calibration_info"))
    @assert (length(request)==1)
    calib=request["calibration_info"]
    calibration_test(calib)
    true
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
    optical_cal_request_test(request)
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
    optical_cal_request_test(request)
end

# success response body (optical_cal): 

function optical_cal_response_test(response)
    @assert (isa(response,OrderedDict))
    @assert (haskey(response,"valid"))
    if (response["valid"])
        @assert (length(response)==1)
    else
        @assert (length(response)==2)
        @assert (haskey(response,"error_message"))
        @assert (isa(response["error_message"],String))
    end
    true
end

# valid

function valid_optical_cal_response_test()
    response=JSON.parse("""{
        "valid": true
    }"""; dicttype=OrderedDict)
    optical_cal_response_test(response)
end

# invalid

function invalid_optical_cal_response_test()
    response=JSON.parse("""{
        "valid": false, 
        "error_message": "xxxx"
    }"""; dicttype=OrderedDict)
    optical_cal_response_test(response)
end





# ********************************************************************************
#
# call: experiments/:experiment_id/thermal_performance_diagnostic
#
# ? not implemented in Rails yet
#
# ********************************************************************************

# request body: 

# MySQL query it is used: 
# SELECT *
#     FROM temperature_logs
#     WHERE experiment_id = $exp_id
#     ORDER BY id
# ;

function thermal_performance_diagnostic_request_test(request)
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

function example_thermal_performance_diagnostic_request_test()
    request=JSON.parse("""{
      "lid_temp": [],
      "heat_block_zone_1_temp": [],
      "heat_block_zone_2_temp": [],
      "elapsed_time": [],
      "cycle_num": []
    }"""; dicttype=OrderedDict)
    thermal_performance_diagnostic_request_test(request)
end

# success response body (thermal_performance_diagnostic): 

function thermal_performance_diagnostic_response_test(response)
    @assert (isa(response,OrderedDict))
    @assert (length(response)==3)
    @assert (haskey(response,"Heating"))
    @assert (haskey(response,"Cooling"))
    @assert (haskey(response,"Lid"))
    @assert (isa(response["Heating"],OrderedDict))
    @assert (isa(response["Cooling"],OrderedDict))
    @assert (isa(response["Lid"],OrderedDict))
    @assert (length(response["Heating"])==3)
    @assert (length(response["Cooling"])==3)
    @assert (length(response["Lid"])==2)
    @assert (haskey(response["Heating"],"AvgRampRate"))
    @assert (haskey(response["Cooling"],"AvgRampRate"))
    @assert (haskey(response["Lid"],"HeatingRate"))
    @assert (haskey(response["Heating"],"TotalTime"))
    @assert (haskey(response["Cooling"],"TotalTime"))
    @assert (haskey(response["Lid"],"TotalTime"))
    @assert (haskey(response["Heating"],"MaxBlockDeltaT"))
    @assert (haskey(response["Cooling"],"MaxBlockDeltaT"))
    @assert (isa(response["Heating"]["AvgRampRate"],Array))
    @assert (isa(response["Cooling"]["AvgRampRate"],Array))
    @assert (isa(response["Lid"]["HeatingRate"],Array))
    @assert (isa(response["Heating"]["TotalTime"],Array))
    @assert (isa(response["Cooling"]["TotalTime"],Array))
    @assert (isa(response["Lid"]["TotalTime"],Array))
    @assert (isa(response["Heating"]["MaxBlockDeltaT"],Array))
    @assert (isa(response["Cooling"]["MaxBlockDeltaT"],Array))
    @assert (length(response["Heating"]["AvgRampRate"])==2)
    @assert (length(response["Cooling"]["AvgRampRate"])==2)
    @assert (length(response["Lid"]["HeatingRate"])==2)
    @assert (length(response["Heating"]["TotalTime"])==2)
    @assert (length(response["Cooling"]["TotalTime"])==2)
    @assert (length(response["Lid"]["TotalTime"])==2)
    @assert (length(response["Heating"]["MaxBlockDeltaT"])==2)
    @assert (length(response["Cooling"]["MaxBlockDeltaT"])==2)
    @assert (isa(response["Heating"]["AvgRampRate"][1],Number))
    @assert (isa(response["Cooling"]["AvgRampRate"][1],Number))
    @assert (isa(response["Lid"]["HeatingRate"][1],Number))
    @assert (isa(response["Heating"]["TotalTime"][1],Number))
    @assert (isa(response["Cooling"]["TotalTime"][1],Number))
    @assert (isa(response["Lid"]["TotalTime"][1],Number))
    @assert (isa(response["Heating"]["MaxBlockDeltaT"][1],Number))
    @assert (isa(response["Cooling"]["MaxBlockDeltaT"][1],Number))
    @assert (isa(response["Heating"]["AvgRampRate"][2],Bool))
    @assert (isa(response["Cooling"]["AvgRampRate"][2],Bool))
    @assert (isa(response["Lid"]["HeatingRate"][2],Bool))
    @assert (isa(response["Heating"]["TotalTime"][2],Bool))
    @assert (isa(response["Cooling"]["TotalTime"][2],Bool))
    @assert (isa(response["Lid"]["TotalTime"][2],Bool))
    @assert (isa(response["Heating"]["MaxBlockDeltaT"][2],Bool))
    @assert (isa(response["Cooling"]["MaxBlockDeltaT"][2],Bool))
    true
end

function example_thermal_performance_diagnostic_response_test()
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
        }
    }"""; dicttype=OrderedDict)
    thermal_performance_diagnostic_response_test(response)
end



# ********************************************************************************
#
# call: experiments/:experiment_id/thermal_consistency
#
# ? not implemented in Rails yet
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

function thermal_consistency_request_test(request)
    @assert (isa(request,OrderedDict))
    @assert (length(request)==2)
    @assert (haskey(request,"calibration_info"))
    @assert (haskey(request,"raw_data"))
    calibration_test(request["calibration_info"]) && raw_test(request["raw_data"])
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
    thermal_consistency_request_test(request)
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
    thermal_consistency_request_test(request)
end

# success response body (thermal_consistency): 

function thermal_consistency_response_test(response)
    @assert (isa(response,OrderedDict))
    @assert (length(response)==2)
    @assert (haskey(response,"tm_check"))
    @assert (haskey(response,"delta_Tm"))
    @assert (isa(response["tm_check"],Array))
    for i in range(1,length(response["tm_check"]))
        @assert (isa(response["tm_check"][i],OrderedDict))
        @assert (length(response["tm_check"][i])==2)
        @assert (haskey(response["tm_check"][i],"Tm"))
        @assert (haskey(response["tm_check"][i],"Area"))
        @assert (isa(response["tm_check"][i]["Tm"],Array))
        @assert (length(response["tm_check"][i]["Tm"])==2)
        @assert (isa(response["tm_check"][i]["Tm"][1],Number))
        @assert (isa(response["tm_check"][i]["Tm"][2],Bool))
        @assert (isa(response["tm_check"][i]["Area"],Number))
    end
    @assert (isa(response["delta_Tm"],Array))
    @assert (length(response["delta_Tm"])==2)
    @assert (isa(response["delta_Tm"][1],Number))
    @assert (isa(response["delta_Tm"][2],Bool))
    true
end

function example_thermal_consistency_response_test()
    response=JSON.parse("""{
        "tm_check": [
            {
                "Tm": [79.0773,true],
                "Area": 1361.5005
            },
            {
                "Tm": [78.5635,true],
                "Area": 1763.7998
            },
            {
                "Tm": [78.4396,true],
                "Area": 1434.3995
            },
            {
                "Tm": [78.2172,true],
                "Area": 1672.9787
            },
            {
                "Tm": [77.8384,true],
                "Area": 639.2474
            },
            {
                "Tm": [78.3816,true],
                "Area": 1076.2143
            },
            {
                "Tm": [78.6829,true],
                "Area": 895.6206
            },
            {
                "Tm": [78.6403,true],
                "Area": 366.6082
            },
            {
                "Tm": [78.0791,true],
                "Area": 255.8169
            },
            {
                "Tm": [77.5054,true],
                "Area": 193.9588
            },
            {
                "Tm": [78.0182,true],
                "Area": 1114.7039
            },
            {
                "Tm": [78.171,true],
                "Area": 1324.3671
            },
            {
                "Tm": [78.1117,true],
                "Area": 1219.4364
            },
            {
                "Tm": [77.8815,true],
                "Area": 499.9462
            },
            {
                "Tm": [78.3167,true],
                "Area": 1097.0781
            },
            {
                "Tm": [79.2487,true],
                "Area": 1318.3026
            }
        ],
        "delta_Tm": [1.7434,true]
    }"""; dicttype=OrderedDict)
    thermal_consistency_response_test(response)
end

# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_single_channel
#
# ? not implemented in Rails yet
#
# ********************************************************************************

# request body: 

# MySQL query used: 
#
# SELECT fluorescence_value, well_num, cycle_num
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
#     ORDER BY well_num, cycle_num
# ;

function optical_test_single_channel_request_test(request)
    signals=["baseline", "excitation"]
    n_wells=length(request["baseline"]["fluorescence_value"])
    @assert (isa(request,OrderedDict))
    @assert (length(request)==length(signals))
    for signal in signals
        @assert (haskey(request,signal))
        @assert (isa(request[signal],OrderedDict))
        @assert (length(request[signal])==1)
        @assert (haskey(request[signal],"fluorescence_value"))
        @assert (isa(request[signal]["fluorescence_value"],Array))
        @assert (length(request[signal]["fluorescence_value"])==n_wells)
        for i in range(1,n_wells)
            @assert (isa(request[signal]["fluorescence_value"][i],Number))
        end
    end
    true
end

function example_optical_single_channel_request_test()
    request=JSON.parse("""{
        "baseline": {
            "fluorescence_value":  [1.01, 1.02,    1.15, 1.16]
        },
        "excitation": {
            "fluorescence_value":  [1.01, 1.02,    1.15, 1.16]
        }
    }"""; dicttype=OrderedDict)
    optical_test_single_channel_request_test(request)
end

# success response body (optical_test_single_channel): 

function optical_test_single_channel_response_test(response)
    @assert (isa(response,OrderedDict))
    @assert (length(response)==1)
    @assert (haskey(response,"optical_data"))
    @assert (isa(response["optical_data"],Array))
    for i in range(1,length(response["optical_data"]))
        @assert (isa(response["optical_data"][i],OrderedDict))
        @assert (length(response["optical_data"][i])==3)
        @assert (haskey(response["optical_data"][i],"baseline"))
        @assert (haskey(response["optical_data"][i],"excitation"))
        @assert (haskey(response["optical_data"][i],"valid"))
        @assert (isa(response["optical_data"][i]["baseline"],Number))
        @assert (isa(response["optical_data"][i]["excitation"],Number))
        @assert (isa(response["optical_data"][i]["valid"],Bool))
    end
    true
end

function example_optical_single_channel_response_test()
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
        }
    ]}"""; dicttype=OrderedDict)
    optical_test_single_channel_response_test(response)
end


# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_dual_channel
#
# not implemented in Rails yet
#
# ********************************************************************************

# request body: 

# MySQL query used: 
#
# SELECT fluorescence_value, well_num, cycle_num
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
#     ORDER BY well_num, cycle_num
# ;

function optical_single_channel_request_test(request)
    signals=["baseline","water","HEX","FAM"]
    n_wells=length(request["baseline"]["fluorescence_value"])
    @assert (isa(request,OrderedDict))
    @assert (length(request)==length(signals))
    for signal in signals
        @assert (haskey(request,signal))
        @assert (isa(request[signal],OrderedDict))
        @assert (length(request[signal])==1)
        @assert (haskey(request[signal],"fluorescence_value"))
        @assert (isa(request[signal]["fluorescence_value"],Array))
        @assert (length(request[signal]["fluorescence_value"])==n_wells)
        for i in range(1,n_wells)
            @assert (isa(request[signal]["fluorescence_value"][i],Number))
        end
    end
    true
end

function example_optical_dual_channel_request_test()
    request=JSON.parse("""{
        "baseline": {
            "fluorescence_value":  [1.01, 1.02,    1.15, 1.16]
        },

        "water": {
            "fluorescence_value":  [1.01, 1.02,    1.15, 1.16]
        },

        "FAM": {
            "fluorescence_value":  [1.01, 1.02,    1.15, 1.16]
        },

        "HEX": {
            "fluorescence_value":  [1.01, 1.02,    1.15, 1.16]
        }
    }"""; dicttype=OrderedDict)
    optical_dual_channel_request_test(request)
end

# run(`curl \
#     --header "Content-Type: application/json" \
#     --request "GET" \
#     --data $(JSON.json(request))
#     http://localhost:3000/experiments/250/optical_test_dual_channel`)



# success response body (optical_test_dual_channel): 

function optical_dual_channel_response_test(response)
    @assert (isa(response,OrderedDict))
    if (length(response)==1)
        @assert (isa(response,OrderedDict))
        @assert (haskey(response,"error"))
        @assert (isa(response["error"],String))
        return true
    end
    # else
    signals=["baseline","water","HEX","FAM"]
    @assert (length(response)==2)
    @assert (haskey(response,"optical_data"))
    @assert (isa(response["optical_data"],Array))
    n_wells=length(response["optical_data"])
    for i in range(1,n_wells) # well
        @assert (isa(response["optical_data"][i],OrderedDict))
        @assert (length(response["optical_data"][i])==length(signals))
        for signal in signals
            @assert (haskey(response["optical_data"][i],signal))
            @assert (isa(response["optical_data"][i][signal],Array))
            @assert (length(response["optical_data"][i][signal])==2)
            for j in range(1,2) # channel
                @assert (isa(response["optical_data"][i][signal][j],Array))
                @assert (length(response["optical_data"][i][signal][j])==2)
                @assert (isa(response["optical_data"][i][signal][j][1],Number))
                @assert (isa(response["optical_data"][i][signal][j][2],Bool))
            end
        end
    end
    @assert (haskey(response,"Ch1:Ch2"))
    @assert (isa(response["Ch1:Ch2"],OrderedDict))
    @assert (length(response["Ch1:Ch2"])==2)
    for signal in signals[3:4]
        @assert (haskey(response["Ch1:Ch2"],signal))
        @assert (isa(response["Ch1:Ch2"][signal],Array))
        @assert (length(response["Ch1:Ch2"][signal])==n_wells)
        for i in range(1,n_wells) # well
            @assert (isa(response["Ch1:Ch2"][signal][i],Number))
        end
    end
    true
end

function example_optical_dual_channel_response_test()
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
        }
    }"""; dicttype=OrderedDict)
    optical_dual_channel_response_test(response)
end

# error response body: 

function error_optical_dual_channel_response_test()
    response=JSON.parse("""{
        "error": "xxxx"
    }"""; dicttype=OrderedDict)
    optical_dual_channel_response_test(response)
end


# ********************************************************************************
#
#                               R U N   E X A M P L E S
#
# ********************************************************************************

function run_examples()
    examples = [
        :example_amplification_standard_curve_request_test,
        :standard_curve_response_test,
        :singlechannel_amplification_request_test,
        :dualchannel_amplification_request_test,
        :singlechannel_amplification_response_test,
        :dualchannel_amplification_response_test,
        :error_amplification_response_test,
        :singlechannel_meltcurve_request_test,
        :dualchannel_meltcurve_request_test,
        :singlechannel_meltcurve_response_test,
        :dualchannel_meltcurve_response_test,
        :error_meltcurve_response_test,
        :example_loadscript_response_test,
        :error_loadscript_response_test,
        :singlechannel_optical_cal_request_test,
        :dualchannel_optical_cal_request_test,
        :valid_optical_cal_response_test,
        :invalid_optical_cal_response_test,
        :example_thermal_performance_diagnostic_request_test,
        :example_thermal_performance_diagnostic_response_test,
        :single_channel_thermal_consistency_request_test,
        :dual_channel_thermal_consistency_request_test,
        :example_thermal_consistency_response_test,
        :example_optical_single_channel_request_test,
        :example_optical_single_channel_response_test,
        :example_optical_dual_channel_request_test,
        :example_optical_dual_channel_response_test,
        :error_optical_dual_channel_response_test
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
# run_examples() # every test should return true

