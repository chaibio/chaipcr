## AssignGenosResult.jl
##
## Author: Tom Price
## Date:   July 2019

import Clustering.ClusteringResult


struct AssignGenosResult
    cluster_result      ::ClusteringResult
    best_i              ::Int
    best_genos_combins  ::Vector{Matrix{Int}}
    expected_genos_all  ::Matrix{Int}
    ucc_dict            ::OrderedDict{Set{Vector{Float_T}},UniqCombinCenters}
end
