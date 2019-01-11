# startup.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# This script starts up the chaipcr development environment
# in the Julia REPL from the bioinformatics/test directory

# NB.
# The following are not implemented yet:
# ensure_ci in shared.jl
# get_mysql_data_well in shared.jl


# ;cd ~/chaipcr/bioinformatics/QpcrAnalysis
# ;sudo mount -t vboxsf shared /mnt/share
#
push!(LOAD_PATH,pwd()*"/../QpcrAnalysis")
LOAD_FROM_DIR=pwd()*"/../QpcrAnalysis"

using QpcrAnalysis

import DataStructures.OrderedDict
import JuMP: Model, @variable, @objective, @NLobjective, @constraint, @NLconstraint,
    solve, getvalue, getobjectivevalue
import Ipopt.IpoptSolver
import DataArrays.DataArray
import Clustering: ClusteringResult, kmeans!, kmedoids!, silhouettes
import Combinatorics.combinations
import JSON, BSON, JLD.load
import Dierckx: Spline1D, derivative
import DataFrames: DataFrame, by

# development & testing
import Base.Test
import FactCheck: facts, context, @fact, clear_results, exitstatus, less_than_or_equal
FactCheck.clear_results()

include("../QpcrAnalysis/shared.jl")

# dispatch
include("../QpcrAnalysis/action_types.jl")
include("../QpcrAnalysis/dispatch.jl")

# data format verification
include("../QpcrAnalysis/verify_request.jl")
include("../QpcrAnalysis/verify_response.jl")

# calibration

include("../QpcrAnalysis/deconv.jl")
include("../QpcrAnalysis/adj_w2wvaf.jl")
include("../QpcrAnalysis/calib.jl")

# amplification
include("../QpcrAnalysis/amp_models/types_for_amp_models.jl")
include("../QpcrAnalysis/amp_models/sfc_models.jl")
include("../QpcrAnalysis/amp_models/MAKx.jl")
include("../QpcrAnalysis/amp_models/MAKERGAUL.jl")
include("../QpcrAnalysis/types_for_allelic_discrimination.jl")
include("../QpcrAnalysis/amp.jl")
include("../QpcrAnalysis/allelic_discrimination.jl")

#include("../QpcrAnalysis/standard_curve.jl")

# melt standard_curve
include("../QpcrAnalysis/multi_channel.jl")
include("../QpcrAnalysis/supsmu.jl")
include("../QpcrAnalysis/meltcrv.jl")

# analyze_customized
include("../QpcrAnalysis/analyze_customized/thermal_consistency.jl")
include("../QpcrAnalysis/analyze_customized/thermal_performance_diagnostic.jl")
include("../QpcrAnalysis/analyze_customized/optical_test_single_channel.jl")
include("../QpcrAnalysis/analyze_customized/optical_test_dual_channel.jl")
include("../QpcrAnalysis/analyze_customized/optical_cal.jl")

k = JLD.load("$LOAD_FROM_DIR/k4dcv_ip84_calib79n80n81_vec.jld")["k4dcv"]
kk = K4Deconv(k.k_s,k.k_inv_vec,k.inv_note)
const K4DCV = kk