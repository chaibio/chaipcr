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
    test_functions = generate_tests(debug=false)
    r = test_functions["amplification dual channel"]()

    test_functions = generate_tests()
    t1 = @elapsed test_functions["amplification dual channel"]()
    t2 = @elapsed test_functions["amplification dual channel"]()

    # save test functions as JLD object for convenient loading
    jldopen("../test/data/dispatch_tests.jld", "w") do file
        addrequire(file, "types_for_dispatch.jl")
        addrequire(file, "types_for_calibration.jl")
        addrequire(file, "types_for_allelic_discrimination.jl")
        addrequire(file, "types_for_amplification.jl")
        addrequire(file, "types_for_meltcurve.jl")
        addrequire(file, "types_for_standard_curve.jl")
        addrequire(file, "types_for_thermal_consistency.jl")
        addrequire(file, "amp_models/types_for_sfc_models.jl")
        addrequire(file, "amp_models/types_for_dfc_models.jl")
        addrequire(file, "constants.jl")
        write(file, "x", x)
    end
end

import FactCheck: clear_results
import DataFrames: DataFrame, rename
import DataStructures: OrderedDict

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
                            action,
                            body;
                            verbose=verbose,
                            verify=true)
                    end # if debug
                    QpcrAnalysis.print_v(println,verbose,"Passed $testname\n")
                    return (ok, response_body)
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
function test_dispatch()
    test_functions = generate_tests()
    OrderedDict(map(
        testname -> testname => test_functions[testname](),
        keys(test_functions)))
end
