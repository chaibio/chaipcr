#

# using Base

@time __precompile__()
module QpcrAnalysis

using Clustering, Combinatorics, DataFrames, DataStructures, Dierckx, Ipopt, JLD, JSON, JuMP, MySQL, NamedTuples #, NLopt # on BBB but not on PC ("ERROR: LoadError: Declaring __precompile__(false) is not allowed in files that are being precompiled". "ERROR: Failed to precompile NLopt to /root/.julia/lib/v0.6/NLopt.ji") # In addition, "HttpServer" for "juliaserver.jl"


# Assumptions
# (1) Integers: channel


# possible errors
# (1) in Julia 0.4.6, `maximum`, `minimum` and `extrema` raises `ArgumentError` over empty collection, while R returns `-Inf` for `max` and `Inf` for `min` over empty collection.


# to change from "ct" to "cq": `min_ct` in "dispatch.jl".


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
include("test.jl")
include("__init__.jl")

# # no longer needed
# include("pnmsmu.jl")





# include files

# const MODULE_NAME = "Essentials"
#
# const ANALYZE_DICT = OrderedDict{String,Function}()
#
# const LOAD_FROM_DIR = LOAD_PATH[find(LOAD_PATH) do path_
#     isfile("$path_/$MODULE_NAME/$MODULE_NAME.jl")
# end][1] # slice by boolean vector returned a one-element vector. Assumption: LOAD_PATH is global
#
# const MODULE_DIR = joinpath(LOAD_FROM_DIR, MODULE_NAME)
#
# for (root, dirs, fns) in walkdir(MODULE_DIR)
#
#     fn_jls_to_include = fns[find(fns) do fn
#         fn != "$MODULE_NAME.jl" && endswith(fn, ".jl")
#     end]
#
#     for fn_jl in fn_jls_to_include
#         include(joinpath(MODULE_DIR, root, fn_jl))
#     end
#
#     fn_k_dict_vec = fns[
#         find(fns) do fn
#             startswith(fn, "k_dict_")
#         end
#     ]
#     if length(fn_k_dict_vec) > 0
#         const K4DCV = load(joinpath(MODULE_DIR, root, fn_k_dict_vec[1]))["k4dcv"]
#     end
#
# end # for (root ...


end # module QpcrAnalysis
