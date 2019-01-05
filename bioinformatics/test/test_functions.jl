## test_functions.jl
#
## Author: Tom Price
## Date: Dec 2018
#
## automated test script for Julia API
## this code should be run at startup in fresh julia REPL

import FactCheck: clear_results
import DataFrames: DataFrame
import DataStructures: OrderedDict
import BSON: bson
import JSON: json, parse, parsefile

td = readdlm("$(QpcrAnalysis.LOAD_FROM_DIR)/../test/data/test_data.csv",',',header=true)
const TEST_DATA = DataFrame([slicedim(td[1],2,i) for i in 1:size(td[1])[2]],map(Symbol,td[2][:]))


# example code to generate, run, and save tests
# BSON preferred to JLD because it can save functions and closures
if (const RUN_THIS_CODE_INTERACTIVELY_NOT_ON_INCLUDE = false)
    cd("/home/vagrant/chaipcr/bioinformatics/QpcrAnalysis")
    push!(LOAD_PATH,pwd())
    using QpcrAnalysis
    test_functions = QpcrAnalysis.generate_tests()
    check = QpcrAnalysis.test_dispatch(test_functions)
    if all(values(check))
        BSON.bson("../test/data/dispatch_tests.bson",test_functions)
        println("All test functions checked and saved")
    else
        println("Test functions failed check:")
        println(results)
    end
end


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
                        response_body = string(JSON.json(response))
                        response_parsed = JSON.parse(response_body,dicttype=OrderedDict)
                        QpcrAnalysis.verify_response(action_t,response_parsed)
                        ok = true
                    else # continue tests after errors reported
                        (ok, response_body) = QpcrAnalysis.dispatch(
                            action,
                            body;
                            verbose=verbose,
                            verify=true)
                        response_parsed = JSON.parse(response_body,dicttype=OrderedDict)
                    end # if debug
                    QpcrAnalysis.print_v(println,verbose,"Passed $testname\n")
                    return (ok, response_parsed)
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

# run test functions
# returns true for every test that runs without errors
function test_dispatch(test_functions ::Associative)
    OrderedDict(map(keys(test_functions)) do testname
        println("Making dispatch call: $testname")
        result = test_functions[testname]()
        testname => result[1] && result[2]["valid"]
        end)
end
