## test_functions.jl
#
## Author: Tom Price
## Date: Dec 2018
#
## automated test script for Julia API
## this code should be run at startup in fresh julia REPL

# example test
if (const RUN_THIS_CODE_INTERACTIVELY_NOT_ON_INCLUDE = false)
    cd("/home/vagrant/chaipcr/bioinformatics/QpcrAnalysis")
    push!(LOAD_PATH,pwd())
    using QpcrAnalysis
    # test code: precompilation should ensure
    # that the first and second runs are equally fast
    include("../test/test_functions.jl") # this file
    test_functions = generate_tests()
    t1 = @elapsed test_functions["amplification dual channel"]()
    t2 = @elapsed test_functions["amplification dual channel"]()
end

import FactCheck: clear_results
import DataFrames: DataFrame
import DataStructures: OrderedDict
import BSON: bson, load

td = readdlm("$(QpcrAnalysis.LOAD_FROM_DIR)/../test/data/test_data.csv",',',header=true)
const TEST_DATA = DataFrame([slicedim(td[1],2,i) for i in 1:size(td[1])[2]],map(Symbol,td[2][:]))

function generate_tests(;
    debug     ::Bool =false,
    verbose   ::Bool =true,
    verify    ::Bool =true
)
    test_functions = OrderedDict()
    strip = [" single"," dual"," channel"]
    for i in 1:size(TEST_DATA)[1]
        for channel_num in [:single_channel,:dual_channel]
            datafile = TEST_DATA[i,channel_num]
            if (datafile != "")
                action = TEST_DATA[i,:action]
                action_t = QpcrAnalysis.Action_DICT[action]()
                request = JSON.parsefile("$(QpcrAnalysis.LOAD_FROM_DIR)/../test/data/$datafile.json",dicttype=OrderedDict)
                body = String(JSON.json(request))

                function test_function()
                    QpcrAnalysis.print_v(println,verbose,"Testing $testname")
                    FactCheck.clear_results()
                    if (debug) # errors fail out
                        QpcrAnalysis.verify_request(action_t,request)
                        response = QpcrAnalysis.act(action_t,request;verbose=verbose)
                        response_body = JSON.json(response)
                        response_parsed = JSON.parse(response_body,dicttype=OrderedDict)
                        QpcrAnalysis.verify_response(action_t,response_parsed)
                        ok = true
                    else # continue tests after errors reported
			tic()
                        (ok, response_body) = QpcrAnalysis.dispatch(
                            action,
                            body;
                            verbose=verbose,
                            verify=verify)
                        response_parsed = JSON.parse(response_body,dicttype=OrderedDict)
                    end # if debug
<<<<<<< HEAD
                    QpcrAnalysis.print_v(println,verbose,"Passed $testname")
		    toc()
                    println("=================\n")
                    return (ok, response_body)
=======
                    QpcrAnalysis.print_v(println,verbose,"Passed $testname\n")
                    return (ok, response_parsed)
>>>>>>> julia-test-merge
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
function run_tests(
    test_functions ::Associative =generate_tests()
)
    check = OrderedDict(map(keys(test_functions)) do testname
        result = test_functions[testname]()
        testname => result[1] && result[2]["valid"]
    end)
    @assert all(values(check)) # check that all test results are positive
end

# package test functions for production
function test_dispatch(
    test_functions ::Associative =OrderedDict()
)
    test_functions = generate_tests(debug=false,verbose=false,verify=false)
    run_tests(test_functions) # the tests should work!
    # save test functions as BSON object for convenient loading
    # (NB. JLD format does not allow functions or closures)
    BSON.bson("../test/data/dispatch_tests.bson", test_functions)
    # to reload and run:
    # using QpcrAnalysis
    # import DataStructures.OrderedDict
    # test_functions = BSON.load("../test/data/dispatch_tests.bson")
    # run_tests(test_functions)
end
