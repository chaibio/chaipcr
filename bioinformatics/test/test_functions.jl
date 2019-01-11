## test_functions.jl
#
## Author: Tom Price
## Date: Dec 2018
#
## automated test script for Julia API
## this code should be run at startup in fresh julia REPL

const BBB = match(r"beaglebone",readlines(`uname -a`)[1]) != nothing
const RUN_THIS_CODE_INTERACTIVELY_NOT_ON_INCLUDE = false

import DataFrames: DataFrame
import DataStructures: OrderedDict
import JSON: json, parse, parsefile

@static if !BBB
    import FactCheck: clear_results
    import BSON: bson
end

const td = readdlm(
    "$(QpcrAnalysis.LOAD_FROM_DIR)/../test/data/test_data.csv",',',header=true)
const TEST_DATA = DataFrame([
    slicedim(td[1],2,i) for i in 1:size(td[1])[2]],
    map(Symbol,td[2][:]))

# example code to generate, run, and save tests
# BSON preferred to JLD because it can save functions and closures
if (RUN_THIS_CODE_INTERACTIVELY_NOT_ON_INCLUDE & !BBB)
    cd("/home/vagrant/chaipcr/bioinformatics/QpcrAnalysis")
    push!(LOAD_PATH,pwd())
    using QpcrAnalysis
    test_functions = QpcrAnalysis.generate_tests(debug=false)
    d1=test_functions["meltcurve single channel"]()
    @timev d2=test_functions["meltcurve single channel"]()

    check = QpcrAnalysis.test_dispatch(test_functions)
    if all(values(check))
        BSON.bson("../test/data/dispatch_tests.bson",test_functions)
        println("All test functions checked and saved")
        # time functions second time around (after compilation)
        timing = QpcrAnalysis.time_dispatch(test_functions)
    else
        println("Test functions failed check:")
        println(check)
    end
end

# timing tests on BBB
if (RUN_THIS_CODE_INTERACTIVELY_NOT_ON_INCLUDE & BBB)
    ENV["JULIA_ENV"]="production"
    cd("/root/chaipcr/bioinformatics/QpcrAnalysis")
    push!(LOAD_PATH,pwd())
    using QpcrAnalysis
    include("../test/test_functions.jl") # this file
    test_functions = generate_tests()
    check = test_dispatch(test_functions)
    if all(values(check))
        println("All test functions passed check")
        # time functions second time around (after compilation)
        timing = time_dispatch(test_functions)
    else
        println("Test functions failed check:")
        println(check)
    end
end

function generate_tests(;
    debug     ::Bool =false,
    verbose   ::Bool =false
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
                    @static BBB || FactCheck.clear_results()
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
                    if (ok && response_parsed["valid"] )
                        QpcrAnalysis.print_v(println,verbose,"Passed $testname\n")
                    else
                        QpcrAnalysis.print_v(println,verbose,"Failed $testname\n")
                    end
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


# BBB results 2019-01-07
# run by Tom Price as root@10.0.100.231

# Making dispatch call: amplification single channel
#   6.335094 seconds (315.82 k allocations: 13.261 MiB, 3.85% gc time)
# elapsed time (ns): 6335093972
# gc time (ns):      243881118
# bytes allocated:   13905496
# pool allocs:       314368
# non-pool GC allocs:412
# malloc() calls:    550
# realloc() calls:   493
# GC pauses:         2

# Making dispatch call: amplification dual channel
#  13.940308 seconds (690.34 k allocations: 29.719 MiB, 3.35% gc time)
# elapsed time (ns): 13940307816
# gc time (ns):      467057318
# bytes allocated:   31162632
# pool allocs:       687248
# non-pool GC allocs:997
# malloc() calls:    1114
# realloc() calls:   984
# GC pauses:         5

# Making dispatch call: meltcurve single channel
#   4.068145 seconds (700.27 k allocations: 88.775 MiB, 11.46% gc time)
# elapsed time (ns): 4068144765
# gc time (ns):      466131773
# bytes allocated:   93087712
# pool allocs:       699164
# non-pool GC allocs:644
# malloc() calls:    355
# realloc() calls:   105
# GC pauses:         14

# Making dispatch call: meltcurve dual channel
#  48.444924 seconds (8.27 M allocations: 393.947 MiB, 10.21% gc time)
# elapsed time (ns): 48444923803
# gc time (ns):      4946285937
# bytes allocated:   413083800
# pool allocs:       8271275
# non-pool GC allocs:1419
# malloc() calls:    702
# realloc() calls:   202
# GC pauses:         63
# full collections:  1

# Making dispatch call: standard curve single channel
#   0.084199 seconds (1.90 k allocations: 86.211 KiB)
# elapsed time (ns): 84198636
# bytes allocated:   88280
# pool allocs:       1900
# non-pool GC allocs:2

# Making dispatch call: optical cal single channel
#   0.008529 seconds (752 allocations: 28.359 KiB)
# elapsed time (ns): 8529347
# bytes allocated:   29040
# pool allocs:       752

# Making dispatch call: optical cal dual channel
#   0.023195 seconds (2.73 k allocations: 112.789 KiB)
# elapsed time (ns): 23195099
# bytes allocated:   115496
# pool allocs:       2734

# Making dispatch call: thermal performance diagnostic single channel
#   0.024872 seconds (6.20 k allocations: 206.281 KiB)
# elapsed time (ns): 24872069
# bytes allocated:   211232
# pool allocs:       6197
# non-pool GC allocs:3

# Making dispatch call: thermal performance diagnostic dual channel
#   0.020857 seconds (4.77 k allocations: 159.742 KiB)
# elapsed time (ns): 20857365
# bytes allocated:   163576
# pool allocs:       4767
# non-pool GC allocs:3

# Making dispatch call: thermal consistency single channel
#   1.408891 seconds (196.18 k allocations: 27.054 MiB, 16.47% gc time)
# elapsed time (ns): 1408891471
# gc time (ns):      232104860
# bytes allocated:   28368096
# pool allocs:       195557
# non-pool GC allocs:451
# malloc() calls:    90
# realloc() calls:   83
# GC pauses:         4

# Making dispatch call: thermal consistency dual channel
#  19.650871 seconds (3.35 M allocations: 168.469 MiB, 8.63% gc time)
# elapsed time (ns): 19650871467
# gc time (ns):      1696740250
# bytes allocated:   176652784
# pool allocs:       3345526
# non-pool GC allocs:986
# malloc() calls:    178
# realloc() calls:   163
# GC pauses:         27

# Making dispatch call: optical test single channel
#   0.002865 seconds (309 allocations: 12.695 KiB)
# elapsed time (ns): 2865254
# bytes allocated:   13000
# pool allocs:       309

# Making dispatch call: optical test dual channel
#   0.024774 seconds (4.14 k allocations: 175.016 KiB)
# elapsed time (ns): 24774074
# bytes allocated:   179216
# pool allocs:       4135
# non-pool GC allocs:1
# realloc() calls:   1

