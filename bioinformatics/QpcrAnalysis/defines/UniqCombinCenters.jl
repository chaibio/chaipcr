#===============================================================================

    UniqCombinCenters.jl

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import Clustering.ClusteringResult


mutable struct UniqCombinCenters
    uniq_combin_centers ::Set{Vector{Float_T}}
    car                 ::ClusterAnalysisResult
    slht_mean           ::Float_T
    geno_combins        ::Vector{Matrix{Float_T}}
end

const EMPTY_UCC_DICT = OrderedDict{Set{Vector{Float_T}},UniqCombinCenters}()
