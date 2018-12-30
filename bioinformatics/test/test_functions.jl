# test_functions.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# automated test script for Julia API

import FactCheck: clear_results
import DataFrames: DataFrame, rename
import DataStructures: OrderedDict
# import QpcrAnalysis: dispatch, act, verify_request, verify_response, print_v, LOAD_FROM_DIR
using QpcrAnalysis

td = readdlm("$(QpcrAnalysis.LOAD_FROM_DIR)/../test/data/test_data.csv",',',header=true)
const TEST_DATA = DataFrame([slicedim(td[1],2,i) for i in 1:size(td[1])[2]],map(Symbol,td[2][:]))

function generate_tests(;
    debug     ::Bool =false,
    verbose   ::Bool =true
)
    test_functions = OrderedDict()
    strip = [" single"," dual"," channel"]
    for i in 1:size(TEST_DATA)[1]
        for channel_num in [:single_channel,:dual_channel]
            datafile = TEST_DATA[i,channel_num]
            if (datafile != "")
                action = TEST_DATA[i,:action]
                action_t = QpcrAnalysis.Action_DICT[action]()
                request = JSON.parsefile("../test/data/$datafile.json",dicttype=OrderedDict)
                body = String(JSON.json(request))

                function test_function()
                    QpcrAnalysis.print_v(println,verbose,"Testing $testname")
                    FactCheck.clear_results()
                    if (debug) # errors fail out
                        QpcrAnalysis.verify_request(action_t,request)
                        response = QpcrAnalysis.act(action_t,request;verbose=verbose)
                        response_body = JSON.parse(JSON.json(response),dicttype=OrderedDict)
                        QpcrAnalysis.verify_response(action_t,response_body)
                        ok = true
                    else # continue tests after errors reported
                        (ok, response_body) = QpcrAnalysis.dispatch(
                            action,body;
                            verbose=verbose,verify=true)
                    end # if debug
                    QpcrAnalysis.print_v(println,verbose,"Passed $testname\n")
                    ok
                end

                testname = replace(TEST_DATA[i,:action],r"_"=>" ")
                for str in strip
                    testname = replace(testname,str=>"")
                end
                testname = replace("$testname "*string(channel_num),r"_"=>" ")
                test_functions[testname] = test_function
            end # if datafile
        end # single/dual channel (channel_num)
    end # next action (i)
    return test_functions
end

function test_dispatch()
    # run test functions
    test_functions = generate_tests()
    test_results = OrderedDict()
    for testname in keys(test_functions)
        test_results[testname] = test_functions[testname]() 
    end
    return test_results
end

function example_test()
    # this code run at startup in fresh julia REPL
    cd("/home/vagrant/chaipcr/bioinformatics/QpcrAnalysis")
    push!(LOAD_PATH,pwd())
    using QpcrAnalysis
    include("../test/test_functions.jl")

    # test code: precompilation should ensure
    # that the first and second runs are equally fast
    test_functions=generate_tests()
    @time test_functions["amplification dual channel"])
    @time test_functions["amplification dual channel"])
end