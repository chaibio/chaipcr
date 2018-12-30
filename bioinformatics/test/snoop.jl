# snoop.jl
#
# Author: Tom Price
# Date: December 2018
#
# snoop on julia compilation
# see https://github.com/timholy/SnoopCompile.jl
#
using SnoopCompile

# Log the compiles
# This only needs to be run once to generate "/tmp/qpcr_compiles.csv"
SnoopCompile.@snoop "/tmp/qpcr_compiles.csv" begin
	cd("/home/vagrant/chaipcr/bioinformatics/QpcrAnalysis")
	push!(LOAD_PATH,pwd())
	using QpcrAnalysis
	include("../test/test_functions.jl")
	results = test_dispatch()
end

# Parse the compiles and generate precompilation scripts
# This can be run repeatedly to tweak the scripts
data = SnoopCompile.read("/tmp/qpcr_compiles.csv")
pc = SnoopCompile.parcel(reverse!(data[2]))
SnoopCompile.write("/tmp/precompile", pc)