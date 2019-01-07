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
        # time functions second time around (after compilation)
        # filter results using `grep -e 'Making dispatch call:' -e 'allocations:'`
        timing = QpcrAnalysis.time_dispatch(test_functions)
    else
        println("Test functions failed check:")
        println(check)
    end
end

# results 2019-01-05
# commit 88e502ecb3ec8b642a376c1964af21d6c6350668
#
# amplification single channel, 10.1 sec (3.88 M allocations: 241.9 MiB, 0.97% gc time)
# amplification dual channel, 22.7 sec (8.35 M allocations: 512.7 MiB, 1.53% gc time)
# meltcurve single channel, 32.8 sec (12.5 M allocations: 821.6 MiB, 0.97% gc time)
# meltcurve dual channel, 70.8 sec (31.2 M allocations: 1.91 GiB, 1.34% gc time)
# standard curve single channel, 0.18 sec (55.4 k allocations: 3.44 MiB, 5.56% gc time)
# optical cal single channel, 0.10 sec (33.3 k allocations: 2.03 MiB)
# optical cal dual channel, 0.22 sec (77.3 k allocations: 4.70 MiB)
# thermal perf. diagnostic single channel, 1.00 sec (296.2 k alloc.: 18.3 MiB, 1.10% gc time)
# thermal perf. diagnostic dual channel, 0.79 sec (225.6 k allocations: 13.9 MiB)
# thermal consistency single channel, 9.03 sec (2.58 M allocations: 173.6 MiB, 0.84% gc time)
# thermal consistency dual channel, 17.3 sec (9.01 M allocations: 576.7 MiB, 1.38% gc time)
# optical test single channel, 0.09 sec (31.5 k allocations: 1.96 MiB)
# optical test dual channel, 1.40 sec (481.5 k allocations: 29.9 MiB, 0.66% gc time)


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
                            verify=false)
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

# time performance
function time_dispatch(test_functions ::Associative)
    OrderedDict(map(keys(test_functions)) do testname
        println("Making dispatch call: $testname")
        @timev result = test_functions[testname]()
        testname => result[1] && result[2]["valid"]
        end)
end

