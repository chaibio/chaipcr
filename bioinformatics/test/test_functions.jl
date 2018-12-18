# test_functions.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# automated test script for Julia API

import FactCheck: clear_results
import DataFrames: DataFrame, rename
import DataStructures: OrderedDict
import QpcrAnalysis: dispatch, act, verify_request, verify_response, print_v

td  = readdlm("../test/data/test_data.csv",',',header=true)
td1 = DataFrame(td[1])
global const TEST_DATA = rename(td1,zip(names(td1),map(x->Symbol(x),squeeze(td[2],1))))

function test_dispatch(;
    debug     ::Bool =false,
    verbose   ::Bool =true
)
    test_results = OrderedDict()
    strip = [" single"," dual"," channel"]
    for i in 1:size(TEST_DATA)[1]
        for j in [:single_channel,:dual_channel]
            datafile = TEST_DATA[i,j]
            if (datafile != "")
                testname = replace(TEST_DATA[i,:action],r"_"=>" ")
                for str in strip
                    testname = replace(testname,str=>"")
                end
                testname = replace("$testname "*string(j),r"_"=>" ")
                QpcrAnalysis.print_v(println,verbose,"Testing $testname")

                request = JSON.parsefile("../test/data/$datafile.json",dicttype=OrderedDict)
                body = String(JSON.json(request))
                FactCheck.clear_results()

                if (debug) # errors fail out
                    action_t=QpcrAnalysis.Action_DICT[TEST_DATA[i,:action]]()
                    QpcrAnalysis.verify_request(action_t,request)
                    response = QpcrAnalysis.act(action_t,request;verbose=verbose)
                    response_body = JSON.parse(JSON.json(response),dicttype=OrderedDict)
                    QpcrAnalysis.verify_response(action_t,response_body)
                    ok = true
                else # continue tests after errors reported
                    (ok, response_body) = QpcrAnalysis.dispatch(TEST_DATA[i,:action],body;  verbose=verbose,verify=true)
                end # if debug

                test_results[testname] = ok     
                QpcrAnalysis.print_v(println,verbose,"Passed $testname\n")     
            end # if datafile
        end # single/dual channel (j)
    end # next action (i)
    return test_results
end