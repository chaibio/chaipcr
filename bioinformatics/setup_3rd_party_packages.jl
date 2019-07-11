## setup_3rd_party_packages.jl
#
## installs julia packages
## julia version is 0.6.2

## some annotations
## Tom Price December 2018
#
## Currently the following are not used as much as they might be:
# DataFrames
# Nullables

Pkg.init()
dir = Pkg.Dir.path()
info("Pinning repository $dir")
metadata_dir = joinpath(dir, "METADATA")
if Pkg.Dir.isdir(metadata_dir)
    info("Package directory $dir exists.")
    run(`git -C $metadata_dir reset --hard 62c084ec638baee70c4f361c75304583bf4647da`)
end

function install(
    library ::String,
    vers 	::Vararg{VersionNumber,2}
)
	println("installing library: ", library)
	Pkg.add(library, vers...)
end

install("FunctionalData", v"0.1.2", v"0.1.3-")
install("Match", v"0.4.0", v"0.4.1-")
install("Compat", v"0.61.0", v"0.61.1-")
install("FactCheck", v"0.4.3", v"0.4.4-") ## for testing and precompiling
install("GZip", v"0.3.0", v"0.3.1-")
install("Polynomials", v"0.2.2", v"0.2.3-")
install("IterTools", v"0.2.1", v"0.2.2-")
install("Combinatorics", v"0.6.0", v"0.6.1-")
install("SHA", v"0.5.7", v"0.5.8-")
install("URIParser", v"0.3.1", v"0.3.2-")
install("BinDeps", v"0.8.7", v"0.8.8-")
install("Blosc", v"0.4.2", v"0.4.3-")
install("BinaryProvider", v"0.3.0", v"0.3.1-")
install("Reexport", v"0.1.0", v"0.1.1-")
install("NaNMath", v"0.3.1", v"0.3.2-")
install("MathProgBase", v"0.6.0", v"0.6.1-")
install("DataStructures", v"0.7.4", v"0.7.5-")
install("Missings", v"0.2.7", v"0.2.8-")
install("WeakRefStrings", v"0.4.3", v"0.4.4-")
install("NamedTuples", v"4.0.2", v"4.0.3-")
install("Nullables", v"0.0.3", v"0.0.4-")
install("JSON", v"0.16.4", v"0.16.5-")
install("Syslogs", v"0.1.1", v"0.1.2-")
install("Memento", v"0.6.0", v"0.6.1-")
install("CategoricalArrays", v"0.3.6", v"0.3.7-")
install("Calculus", v"0.2.2", v"0.2.3-")
install("DataStreams", v"0.3.4", v"0.3.5-")
install("DiffBase", v"0.2.0", v"0.2.1-")
install("Distances", v"0.6.0", v"0.6.1-")
install("FileIO", v"0.7.0", v"0.7.1-")
install("SpecialFunctions", v"0.3.6", v"0.3.7-")
install("ForwardDiff", v"0.4.2", v"0.4.3-")
install("LegacyStrings", v"0.3.0", v"0.3.1-")
install("HttpCommon", v"0.4.0", v"0.4.1-")
install("HttpParser", v"0.3.1", v"0.3.2-")
install("MbedTLS", v"0.5.8", v"0.5.9-")
install("IniFile", v"0.4.0", v"0.4.1-")
install("HTTP", v"0.6.9", v"0.7.0-")

install("StaticArrays", v"0.7.0", v"0.7.1-")
install("NearestNeighbors", v"0.3.0", v"0.3.1-")
install("ReverseDiffSparse", v"0.7.3", v"0.7.4-")
install("SortingAlgorithms", v"0.2.0", v"0.2.1-")
install("StatsBase", v"0.22.0", v"0.22.1-")

println("All additional packages")

install("DataFrames", v"0.11.0", v"0.11.1-")
install("HDF5", v"0.8.8", v"0.8.9-")
install("JLD", v"0.8.3", v"0.8.4-") ## needed by Ipopt, JuMP, and NLopt
install("Clustering", v"0.9.1", v"0.9.2-")
install("Ipopt", v"0.2.4", v"0.2.9-")
install("JuMP", v"0.17.1", v"0.17.2-")
#install("HttpServer", v"0.2.0", v"0.2.1-")
install("Dierckx", v"0.3.0", v"0.3.1-")
install("DataArrays", v"0.7.0", v"0.7.1-")
## Packages that are no longer used:

# install("Cairo", v"0.5.1", v"0.5.2-")
# install("CodecZlib", v"0.4.2", v"0.4.3-")
# install("Colors", v"0.8.2", v"0.8.3-")
# install("ColorTypes", v"0.6.7", v"0.6.8-")
# install("FixedPointNumbers", v"0.4.6", v"0.4.7-")
# install("Graphics", v"0.2.0", v"0.2.1-")
# install("Gtk", v"0.13.1", v"0.13.2-")
# install("GtkReactive", v"0.4.0", v"0.4.1-")
# install("IntervalSets", v"0.2.0", v"0.2.1-")
# install("MicroLogging", v"0.2.0", v"0.2.0-")
# install("MySQL", v"0.3.0", v"0.3.1-") # remove MySQL dependency
# install("NLopt", v"0.3.6", v"0.3.7-")
# install("ProfileView", v"0.3.0", v"0.3.1-")
# install("Reactive", v"0.6.0", v"0.6.1-")
# install("RoundingIntegers", v"0.0.3", v"0.0.4-")
# install("TranscodingStreams", v"0.5.1", v"0.5.2-")

Pkg.build(
	"DataArrays",
	"DataStructures",
	"SpecialFunctions",
	"MathProgBase",
	"HDF5",
	"Clustering",
	"Nullables",
	"JSON",
	"JLD",
	"JuMP",
	"Dierckx",
	"Ipopt",
	"DataFrames")
println("Building: Done")

using Clustering, Combinatorics, DataArrays, DataFrames
println("Used Clustering, Combinatorics, DataArrays, DataFrames")
using DataStructures, Dierckx, HDF5, Ipopt, JLD, JSON, JuMP
println("Used DataStructures, Dierckx, HDF5, Ipopt, JLD, JSON, JuMP")
using MathProgBase, Nullables, SpecialFunctions, FactCheck, FunctionalData, Match, Syslogs, Memento, HttpCommon, HttpParser, IniFile, HTTP
println("Used MathProgBase, Nullables, SpecialFunctions, FactCheck,FunctionalData, Match, Syslogs, Memento, HttpCommon, HttpParser, IniFile, HTTP")

println("All packages used")

Pkg.status()
println("Using: Done")

#
