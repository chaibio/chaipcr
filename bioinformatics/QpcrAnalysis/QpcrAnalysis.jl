## Module QpcrAnalysis.jl



## Notes on using MySQL 0.3.0 instead of current version
## ----
##                   0.3.0                      0.5.2
## connect           mysql_connect(, some_db)   connect(; db=some_db)
## query function    mysql_execute              query
## query return      Array(DataFrame)           NamedTuple
## data container    DataFrame                  NamedTuple
## data access       [1]                        (direct)
## ----
## `connect` examples:
## 0.3.0 `MySQL.mysql_connect(host, username, password, some_db)`
## 0.5.2 `MySQL.connect(host, username, password; db=some_db)`
## `query` examples:
## 0.3.0 `MySQL.mysql_execute(some_query)[1][:some_header]`
## 0.5.2 `MySQL.query(some_query)[:some_header]`



__precompile__()



# using Base

module QpcrAnalysis
const MODULE_NAME = "QpcrAnalysis"

# using Clustering, Combinatorics, DataFrames, DataStructures, Dierckx, Ipopt, JLD, JSON,
# JuMP, MySQL, NamedTuples, DataArrays
## `NLopt` needed on BBB but not on PC ("ERROR: LoadError: Declaring __precompile__(false)
## is not allowed in files that are being precompiled".
## "ERROR: Failed to precompile NLopt to /root/.julia/lib/v0.6/NLopt.ji")
## In addition, `HttpServer` for "juliaserver.jl"

## Other functions than `include` read files from `pwd()` only instead of also `LOAD_PATH`.
## `pwd()` shows the present working directory in module `Main`, instead of the directory
## where "QpcrAnalysis.jl" is located. Therefore `LOAD_FROM_DIR` needs to be defined
## for those functions to find files in the directory where "QpcrAnalysis.jl" is located.
const LOAD_FROM_DIR = LOAD_PATH[find(LOAD_PATH) do path_
    isfile("$path_/$MODULE_NAME.jl")
end][1] # slice by boolean vector returned a one-element vector. Assumption: LOAD_PATH is global

## delete temporary log files if this is the only julia process
cd("/tmp")
if eachmatch(r"julia", read(`ps -eo comm`, String)) |> collect |> length == 1
    foreach(rm, filter(x -> match(r"^julia", x) != nothing, readdir()))
end

## set up logger
using MicroLogging
global_logger(
    configure_logging(
        SimpleLogger(
            open(tempname(), "w")), min_level=:info)) ## :debug for verbose output
@info(string(now()) * " global logger constructed in module QpcrAnalysis\n")

## default data width in production mode:  32 bits (BBB)
## default data width in development mode: 64 bits
const production_env = (get(ENV, "JULIA_ENV", nothing) == "production")
if !production_env
    const Float_T   = Float32
else
    const Float_T   = Float64
end
@info(string(now()) * " Julia is running in " *
    (production_env ? "production" : "development") * " mode\n")

## include each script, generally in the order of workflow

## types and constants
include("types_for_dispatch.jl")
include("types_for_calibration.jl")
include("types_for_allelic_discrimination.jl")
include("types_for_amplification.jl")
include("types_for_meltcurve.jl")
include("types_for_standard_curve.jl")
include("types_for_thermal_consistency.jl")
include("amp_models/types_for_sfc_models.jl")
include("amp_models/types_for_dfc_models.jl")
include("constants.jl")

## shared functions
include("shared.jl")

## this code is hidden from the parser on the BeagleBone
@static if !production_env
    ## development & testing
    import Base.Test
    using FactCheck
    FactCheck.clear_results()

    ## data format verification
    include("../test/verify_request.jl")
    include("../test/verify_response.jl")
    include("../test/test_functions.jl")
end

## dispatch
include("dispatch.jl")

## calibration
include("deconv.jl") # `type K4Deconv` REPL
include("adj_w2wvaf.jl")
include("calib.jl") # `type CalibCalibOutput` currently not in production

## amplification
include("amp_models/sfc_models.jl")
include("amp_models/MAKx.jl")
include("amp_models/MAKERGAUL.jl")
include("amp.jl")
include("allelic_discrimination.jl")

## standard curve
include("standard_curve.jl")

## melt curve
include("multi_channel.jl")
include("supsmu.jl")
include("meltcrv.jl")

## analyze_customized
include("analyze_customized/thermal_performance_diagnostic.jl")
include("analyze_customized/optical_test_single_channel.jl")
include("analyze_customized/optical_test_dual_channel.jl")
include("analyze_customized/optical_cal.jl")
include("analyze_customized/thermal_consistency.jl")
# include("analyze_customized/your_own_analyze_functionality.jl")

## no longer needed
#
## wrap up
# include("test.jl")
# include("__init__.jl")
#
# include("pnmsmu.jl")

@debug(string(now()) * " module QpcrAnalysis loaded\n")
end ## module QpcrAnalysis
