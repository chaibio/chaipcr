
println("Starting precompile template !!!")
push!(LOAD_PATH, "/root/chaipcr/bioinformatics/QpcrAnalysis/")

println("Using time: ")
@time using QpcrAnalysis
println("Done Using!")

# load test functions
include("/root/chaipcr/bioinformatics/test/test_functions.jl")
test_functions = generate_tests( verbose=true )
println("Test functions generated.. running first pass.... JIT timing if exists!")

println("QpcrAnalysis.LOAD_FROM_DIR $(QpcrAnalysis.LOAD_FROM_DIR)")

dispatch_results = OrderedDict(map(
    testname -> testname => test_functions[testname](),
    keys(test_functions)))
println("QpcrAnalysis.LOAD_FROM_DIR $(QpcrAnalysis.LOAD_FROM_DIR)")

test_functions = generate_tests()
  println("Running second pass.... No JIT delay!")
  dispatch_results = OrderedDict(map(
    testname -> testname => test_functions[testname](),
    keys(test_functions)))

println("Done with test functions!")
