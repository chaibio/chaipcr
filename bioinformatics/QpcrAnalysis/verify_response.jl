# verify_response.jl
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

function verify_response(
    ::StandardCurve,
    response ::Any
)
    facts() do
        context("Verifying response body") do
            @fact (isa(response,OrderedDict)) --> true
            # @fact (length(response)) --> 1 # allow additional fields
            @fact (haskey(response,"targets")) --> true
            array=response["targets"]
            @fact (isa(array,Vector)) --> true
            for i in range(1,length(array))
                dict=array[i]
                @fact (isa(dict,OrderedDict)) --> true
                @fact (haskey(dict,"target_id")) --> true
                @fact (dict["target_id"]) --> i
                if (length(dict)==2)
                    @fact (haskey(dict,"error")) --> true
                    @fact (isa(dict["error"],String)) --> true
                else
                    @fact (length(dict)) --> 5
                    @fact (haskey(dict,"slope")) --> true
                    @fact (isa(dict["slope"],Number)) --> true
                    @fact (haskey(dict,"offset")) --> true
                    @fact (isa(dict["offset"],Number)) --> true
                    @fact (haskey(dict,"efficiency")) --> true
                    @fact (isa(dict["efficiency"],Number)) --> true
                    @fact (haskey(dict,"r2")) --> true
                    @fact (isa(dict["r2"],Number)) --> true
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

function verify_response(
    ::Amplification,
    response ::Any
)
    facts() do
        context("Verifying response body") do
            @fact (isa(response,OrderedDict)) --> true
            if (haskey(response,"error"))
                @fact (length(response)) --> 1
                @fact (isa(response["error"],String)) --> true
            else
                @fact (length(response)) --> 8
                measurements=["rbbs_ary3","blsub_fluos","dr1_pred","dr2_pred"]
                n_channels=length(response["rbbs_ary3"])
                @fact (n_channels in CHANNELS) --> true
                n_wells=length(response["rbbs_ary3"][1])
                n_steps=length(response["rbbs_ary3"][1][1])
                n_pred=length(response["dr1_pred"][1][1])
                for m in measurements
                    @fact (haskey(response,m)) --> true
                    @fact (isa(response[m],Vector)) --> true
                    @fact (length(response[m])) --> n_channels
                    for c in range(1,n_channels)
                        @fact (isa(response[m][c],Vector)) --> true
                        @fact (length(response[m][c])) --> n_wells
                        for i in range(1,n_wells)
                            @fact (isa(response[m][c][i],Vector)) --> true
                            if (m=="rbbs_ary3" || m=="blsub_fluos")
                                @fact (length(response[m][c][i])) --> n_steps
                                for j in range(1,n_steps)
                                    @fact (isa(response[m][c][i][j],Number) ||
                                        (response[m][c][i][j]==nothing)) --> true
                                end
                            else # dr1_pred, dr2_pred
                                @fact (length(response[m][c][i])) --> n_pred
                                for j in range(1,n_pred)
                                    @fact (isa(response[m][c][i][j],Number) ||
                                        (response[m][c][i][j]==nothing)) --> true
                                end
                            end
                        end
                    end
                end
            end
            statistics=["cq","d0"]
            for s in statistics
                @fact (haskey(response,s)) --> true
                @fact (isa(response[s],Vector)) --> true
                @fact (length(response[s])) --> n_channels
                for c in range(1,n_channels)
                    @fact (isa(response[s][c],Vector)) --> true
                    @fact (length(response[s][c])) --> n_wells
                    for i in range(1,n_wells)
                        @fact (isa(response[s][c][i],Number) ||
                            response[s][c][i]==nothing) --> true
                    end
                end
            end
            @fact (haskey(response,"ct_fluos")) --> true
            @fact (isa(response["ct_fluos"],Vector)) --> true
            @fact (length(response["ct_fluos"])) --> n_channels
            for c in range(1,n_channels)
                @fact (isa(response["ct_fluos"][c],Number) ||
                    response["ct_fluos"][c]==nothing) --> true
            end
            variables=["rbbs_ary3","blsub_fluos","cq","d0"]
            @fact (haskey(response,"assignments_adj_labels_dict")) --> true
            @fact (isa(response["assignments_adj_labels_dict"],OrderedDict)) --> true
            # @fact (length(response["assignments_adj_labels_dict"])) --> n_genotypes
            for g in range(1,length(response["assignments_adj_labels_dict"]))
                @fact (isa(response["assignments_adj_labels_dict"][variables[g]],Vector)) --> true
                @fact (length(response["assignments_adj_labels_dict"][variables[g]])) --> n_wells
                for i in range(1,n_wells)
                    @fact (isa(response["assignments_adj_labels_dict"][variables[g]][i],String)) --> true
                end
            end
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

function verify_response(
    ::MeltCurve,
    response ::Any
)
    facts() do
        context("Verifying response body") do
            @fact (isa(response,OrderedDict)) --> true
            if (haskey(response,"error"))
                @fact (length(response)) --> 1
                @fact (isa(response["error"],String)) --> true
            else
                variables=["melt_curve_data","melt_curve_analysis"]
                @fact length(response) --> length(variables)
                n_channels=length(response["melt_curve_data"])
                n_wells=length(response["melt_curve_data"][1])
                n_grid=length(response["melt_curve_data"][1][1][1])
                for v in variables
                    n = (v=="melt_curve_data") ? 3 : 2
                    @fact (haskey(response,v)) --> true
                    @fact (isa(response[v],Vector)) --> true
                    @fact (length(response[v])) --> n_channels
                    for i in range(1,n_channels) # channel
                        @fact (isa(response[v][i],Vector)) --> true
                        for j in range(1,n_wells) # well
                            @fact (length(response[v][i][j])) --> n
                            for k in range(1,n) # temperature, fluorescence, slope / Tm, area
                                if (v=="melt_curve_data")
                                    @fact abs(length(response[v][i][j][k]) - n_grid) --> less_than_or_equal(1)
                                end
                                @fact (isa(response[v][i][j][k],Vector)) --> true
                                for m in range(1,length(response[v][i][j][k])) # prediction locations / temp maxima
                                    @fact (isa(response[v][i][j][k][m],Number)) --> true
                                end
                            end
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
# call: system/loadscript?script=path%2Fto%2Fanalyze.jl
#
# ********************************************************************************

function verify_response(
    ::LoadScript,
    response ::Any
)
    facts() do
        context("Verifying response body") do
            @fact (isa(response,OrderedDict)) --> true
            if (haskey(response,"error"))
                @fact (length(response)) --> 1
                @fact (isa(response["error"],String)) --> true
            else
                @fact (haskey(response,"script")) --> true
                @fact (isa(response["script"],String)) --> true
            end
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/thermal_performance_diagnostic
#
# ********************************************************************************

function verify_response(
    ::ThermalPerformanceDiagnostic,
    response ::Any
)
    facts() do
        context("Verifying response body") do
            @fact (isa(response,OrderedDict)) --> true
            if (haskey(response,"error"))
                @fact (length(response)) --> 1
                @fact (isa(response["error"],String)) --> true
            else
                @fact (length(response)) --> 3
                @fact (haskey(response,"Heating")) --> true
                @fact (haskey(response,"Cooling")) --> true
                @fact (haskey(response,"Lid")) --> true
                @fact (isa(response["Heating"],OrderedDict)) --> true
                @fact (isa(response["Cooling"],OrderedDict)) --> true
                @fact (isa(response["Lid"],OrderedDict)) --> true
                @fact (length(response["Heating"])) --> 3
                @fact (length(response["Cooling"])) --> 3
                @fact (length(response["Lid"])) --> 2
                @fact (haskey(response["Heating"],"AvgRampRate")) --> true
                @fact (haskey(response["Cooling"],"AvgRampRate")) --> true
                @fact (haskey(response["Lid"],"HeatingRate")) --> true
                @fact (haskey(response["Heating"],"TotalTime")) --> true
                @fact (haskey(response["Cooling"],"TotalTime")) --> true
                @fact (haskey(response["Lid"],"TotalTime")) --> true
                @fact (haskey(response["Heating"],"MaxBlockDeltaT")) --> true
                @fact (haskey(response["Cooling"],"MaxBlockDeltaT")) --> true
                @fact (isa(response["Heating"]["AvgRampRate"],Vector)) --> true
                @fact (isa(response["Cooling"]["AvgRampRate"],Vector)) --> true
                @fact (isa(response["Lid"]["HeatingRate"],Vector)) --> true
                @fact (isa(response["Heating"]["TotalTime"],Vector)) --> true
                @fact (isa(response["Cooling"]["TotalTime"],Vector)) --> true
                @fact (isa(response["Lid"]["TotalTime"],Vector)) --> true
                @fact (isa(response["Heating"]["MaxBlockDeltaT"],Vector)) --> true
                @fact (isa(response["Cooling"]["MaxBlockDeltaT"],Vector)) --> true
                @fact (length(response["Heating"]["AvgRampRate"])) --> 2
                @fact (length(response["Cooling"]["AvgRampRate"])) --> 2
                @fact (length(response["Lid"]["HeatingRate"])) --> 2
                @fact (length(response["Heating"]["TotalTime"])) --> 2
                @fact (length(response["Cooling"]["TotalTime"])) --> 2
                @fact (length(response["Lid"]["TotalTime"])) --> 2
                @fact (length(response["Heating"]["MaxBlockDeltaT"])) --> 2
                @fact (length(response["Cooling"]["MaxBlockDeltaT"])) --> 2
                @fact (isa(response["Heating"]["AvgRampRate"][1],Number)) --> true
                @fact (isa(response["Cooling"]["AvgRampRate"][1],Number)) --> true
                @fact (isa(response["Lid"]["HeatingRate"][1],Number)) --> true
                @fact (isa(response["Heating"]["TotalTime"][1],Number)) --> true
                @fact (isa(response["Cooling"]["TotalTime"][1],Number)) --> true
                @fact (isa(response["Lid"]["TotalTime"][1],Number)) --> true
                @fact (isa(response["Heating"]["MaxBlockDeltaT"][1],Number)) --> true
                @fact (isa(response["Cooling"]["MaxBlockDeltaT"][1],Number)) --> true
                @fact (isa(response["Heating"]["AvgRampRate"][2],Bool)) --> true
                @fact (isa(response["Cooling"]["AvgRampRate"][2],Bool)) --> true
                @fact (isa(response["Lid"]["HeatingRate"][2],Bool)) --> true
                @fact (isa(response["Heating"]["TotalTime"][2],Bool)) --> true
                @fact (isa(response["Cooling"]["TotalTime"][2],Bool)) --> true
                @fact (isa(response["Lid"]["TotalTime"][2],Bool)) --> true
                @fact (isa(response["Heating"]["MaxBlockDeltaT"][2],Bool)) --> true
                @fact (isa(response["Cooling"]["MaxBlockDeltaT"][2],Bool)) --> true
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

function verify_response(
    ::ThermalConsistency,
    response ::Any
)
    facts() do
        context("Verifying response body") do
            @fact (isa(response,OrderedDict)) --> true
            if (haskey(response,"error"))
                @fact (length(response)) --> 1
                @fact (isa(response["error"],String)) --> true
            else
                @fact (length(response)) --> 2
                @fact (haskey(response,"tm_check")) --> true
                @fact (haskey(response,"delta_Tm")) --> true
                @fact (isa(response["tm_check"],Vector)) --> true
                for i in range(1,length(response["tm_check"]))
                    @fact (isa(response["tm_check"][i],OrderedDict)) --> true
                    @fact (length(response["tm_check"][i])) --> 2
                    @fact (haskey(response["tm_check"][i],"Tm")) --> true
                    @fact (haskey(response["tm_check"][i],"area")) --> true
                    @fact (isa(response["tm_check"][i]["Tm"],Vector)) --> true
                    @fact (length(response["tm_check"][i]["Tm"])) --> 2
                    @fact (isa(response["tm_check"][i]["Tm"][1],Number)) --> true
                    @fact (isa(response["tm_check"][i]["Tm"][2],Bool)) --> true
                    @fact (isa(response["tm_check"][i]["area"],Number)) --> true
                end
                @fact (isa(response["delta_Tm"],Vector)) --> true
                @fact (length(response["delta_Tm"])) --> 2
                @fact (isa(response["delta_Tm"][1],Number)) --> true
                @fact (isa(response["delta_Tm"][2],Bool)) --> true
            end
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_cal
#
# ********************************************************************************

# success response body (optical_cal):

function verify_response(
    ::OpticalCal,
    response ::Any
)
    facts() do
        context("Verifying response body") do
            @fact (isa(response,OrderedDict)) --> true
            if (haskey(response,"error"))
                @fact (length(response)) --> 1
                @fact (isa(response["error"],String)) --> true
            else
                @fact (haskey(response,"valid")) --> true
                if (response["valid"]==true)
                    @fact (length(response)) --> 1
                else
                    @fact (response["valid"]) --> false
                    @fact (length(response)) --> 2
                    @fact (haskey(response,"error_message")) --> true
                    @fact (isa(response["error_message"],String)) --> true
                end
            end
        end
    end
    FactCheck.exitstatus()
end



# ********************************************************************************
#
# call: experiments/:experiment_id/optical_test_single_channel
#
# ********************************************************************************

function verify_response(
    ::OpticalTestSingleChannel,
    response ::Any
)
    facts() do
        context("Verifying response body") do
            @fact (isa(response,OrderedDict)) --> true
            @fact (length(response)) --> 1
            if (haskey(response,"error"))
                @fact (isa(response["error"],String)) --> true
            else
                @fact (haskey(response,"optical_data")) --> true
                @fact (isa(response["optical_data"],Vector)) --> true
                for i in range(1,length(response["optical_data"]))
                    @fact (isa(response["optical_data"][i],OrderedDict)) --> true
                    @fact (length(response["optical_data"][i])) --> 3
                    @fact (haskey(response["optical_data"][i],"baseline")) --> true
                    @fact (haskey(response["optical_data"][i],"excitation")) --> true
                    @fact (haskey(response["optical_data"][i],"valid")) --> true
                    @fact (isa(response["optical_data"][i]["baseline"],Number)) --> true
                    @fact (isa(response["optical_data"][i]["excitation"],Number)) --> true
                    @fact (isa(response["optical_data"][i]["valid"],Bool)) --> true
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
# *******************************************************************************

function verify_response(
    ::OpticalTestDualChannel,
    response ::Any
)
    facts() do
        context("Verifying response body") do
            @fact (isa(response,OrderedDict)) --> true
            if (haskey(response,"error"))
                @fact (length(response)) --> 1
                @fact (isa(response["error"],String)) --> true
            else
                signals=["baseline","water","HEX","FAM"]
                @fact (length(response)) --> 2
                @fact (haskey(response,"optical_data")) --> true
                @fact (isa(response["optical_data"],Vector)) --> true
                n_wells=length(response["optical_data"])
                for i in range(1,n_wells) # well
                    @fact (isa(response["optical_data"][i],OrderedDict)) --> true
                    @fact (length(response["optical_data"][i])) --> length(signals)
                    for signal in signals
                        @fact (haskey(response["optical_data"][i],signal)) --> true
                        @fact (isa(response["optical_data"][i][signal],Vector)) --> true
                        @fact (length(response["optical_data"][i][signal])) --> 2
                        for j in range(1,2) # channel
                            @fact (isa(response["optical_data"][i][signal][j],Vector)) --> true
                            @fact (length(response["optical_data"][i][signal][j])) --> 2
                            @fact (isa(response["optical_data"][i][signal][j][1],Number)) --> true
                            @fact (isa(response["optical_data"][i][signal][j][2],Bool)) --> true
                        end
                    end
                end
                @fact (haskey(response,"Ch1:Ch2")) --> true
                @fact (isa(response["Ch1:Ch2"],OrderedDict)) --> true
                @fact (length(response["Ch1:Ch2"])) --> 2
                for signal in signals[3:4]
                    @fact (haskey(response["Ch1:Ch2"],signal)) --> true
                    @fact (isa(response["Ch1:Ch2"][signal],Vector)) --> true
                    @fact (length(response["Ch1:Ch2"][signal])) --> n_wells
                    for i in range(1,n_wells) # well
                        @fact (isa(response["Ch1:Ch2"][signal][i],Number)) --> true
                    end
                end
            end
        end
    end
    FactCheck.exitstatus()
end