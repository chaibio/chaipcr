## ClusterAnalysisResult.jl
##
## clustering analysis result from a possible combination of expected genotypes
##
## Author: Tom Price
## Date:   July 2019

import Clustering.ClusteringResult


struct ClusterAnalysisResult
    init_centers        ::Array{Float_T,2} ## no longer necessary because it represents one combination of genotypes, but different combinations of genotypes with the same number of genotypes may result in the same clustering results
    dist_mtx_winit      ::Array{Float_T,2}
    cluster_result      ::ClusteringResult
    centers             ::Array{Float_T,2}
    slhts               ::Vector{Float_T}
    slht_mean           ::Float_T
    check_dist_mtx      ::Array{Float_T,2}
    check_dist_bool     ::Bool
end
