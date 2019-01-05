## memory_allocation.jl
#
## Author: Tom Price
## Date: January 2019
#
## Analyse memory usage in dispatch calls
## See https://docs.julialang.org/en/v0.6/manual/profile/#Memory-allocation-analysis-1
## Usage: julia --track-allocation=user memory_allocation.jl


# performance is better with dispatch calls
# in a function rather than global scope
function test_memory_allocation()
    # load dispatch calls & associated data
    test_functions = BSON.load("../test/data/dispatch_tests.bson")
    #
    # perform calls to force compilation
    check = test_dispatch(test_functions)
    println(check)
    #
    # all test results must be positive, or else an error will be raised
    @assert all(values(check))
    #
    # reset allocation counters
    Profile.clear_malloc_data()
    #
    # execute dispatch calls a second time
    check = test_dispatch(test_functions)
end


# start of main code >> 

autorun = joinpath(Base.JULIA_HOME,Base.SYSCONFDIR,"julia/juliarc.jl")
# look for magic number
if !isfile(autorun) || all(map(
    x -> match(r"6004dbc584427ce1297c8e89e547057e",x)==nothing,
    readlines(autorun)))
    # if not found, run these three commands
    # which have not been included in the startup script:
    cd("/home/vagrant/chaipcr/bioinformatics/QpcrAnalysis")
    push!(LOAD_PATH,pwd())
    using QpcrAnalysis
end

import FactCheck: clear_results
import DataFrames: DataFrame
import DataStructures: OrderedDict
import BSON: bson
import JSON: json, parse, parsefile
test_memory_allocation()

# << end of main code



#
