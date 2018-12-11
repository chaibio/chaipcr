# Module QpcrAnalysis.jl


# Notes on using MySQL 0.3.0 instead of current version
# ----
#                   0.3.0                      0.5.2
# connect           mysql_connect(, some_db)   connect(; db=some_db)
# query function    mysql_execute              query
# query return      Array(DataFrame)           NamedTuple
# data container    DataFrame                  NamedTuple
# data access       [1]                        (direct)
# ----
# `connect` examples:
# 0.3.0 `MySQL.mysql_connect(host, username, password, some_db)`
# 0.5.2 `MySQL.connect(host, username, password; db=some_db)`
# `query` examples:
# 0.3.0 `MySQL.mysql_execute(some_query)[1][:some_header]`
# 0.5.2 `MySQL.query(some_query)[:some_header]`



# using Base

@time __precompile__()
module QpcrAnalysis

using Clustering, Combinatorics, DataFrames, DataStructures, Dierckx, Ipopt, JLD, JSON, JuMP, MySQL, NamedTuples, DataArrays #, NLopt
# `, DataArrays` needed if `Pkg.add("DataFrames", v"0.11.2", v"0.11.3-")`, but not needed when using latest version as of 2018-04-10
# `, NLopt` on BBB but not on PC ("ERROR: LoadError: Declaring __precompile__(false) is not allowed in files that are being precompiled". "ERROR: Failed to precompile NLopt to /root/.julia/lib/v0.6/NLopt.ji") # In addition, "HttpServer" for "juliaserver.jl"


const MODULE_NAME = "QpcrAnalysis"
# Other functions than `include` read files from `pwd()` only instead of also `LOAD_PATH`. `pwd()` shows the present working directory in module `Main`, instead of the directory where "QpcrAnalysis.jl" is located. Therefore `LOAD_FROM_DIR` needs to be defined for those functions to find files in the directory where "QpcrAnalysis.jl" is located.
const LOAD_FROM_DIR = LOAD_PATH[find(LOAD_PATH) do path_
    isfile("$path_/$MODULE_NAME.jl")
end][1] # slice by boolean vector returned a one-element vector. Assumption: LOAD_PATH is global


# include each script, generally in the order of workflow

include("shared.jl")

# calibration
include("deconv.jl") # `type K4Deconv`
const K4DCV = load("$LOAD_FROM_DIR/k4dcv_ip84_calib79n80n81_vec.jld")["k4dcv"] # sometimes crash REPL
include("adj_w2wvaf.jl")
include("calib.jl") # `type CalibCalibOutput` currently not in production

# amplification
include("amp_models/types_for_amp_models.jl")
include("amp_models/sfc_models.jl")
include("amp_models/MAKx.jl")
include("amp_models/MAKERGAUL.jl")
include("types_for_allelic_discrimination.jl")
include("amp.jl")
include("allelic_discrimination.jl")

include("standard_curve.jl")

# melt curve
include("multi_channel.jl")
include("supsmu.jl")
include("meltcrv.jl")

# analyze_customized
include("analyze_customized/analyze_types.jl")
include("analyze_customized/thermal_performance_diagnostic.jl")
include("analyze_customized/optical_test_single_channel.jl")
include("analyze_customized/optical_test_dual_channel.jl")
include("analyze_customized/optical_cal.jl")
include("analyze_customized/thermal_consistency.jl")
# include("analyze_customized/your_own_analyze_functionality.jl")

# wrap up
include("dispatch.jl")
# include("test.jl")
include("../test/api_test.jl")
# include("__init__.jl")

# # no longer needed
# include("pnmsmu.jl")




end # module QpcrAnalysis
