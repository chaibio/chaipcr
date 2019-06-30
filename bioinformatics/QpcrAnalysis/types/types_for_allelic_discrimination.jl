## types_for_allelic_discrimination.jl
##
## needed for `type AmpStepRampOutput` so must be included before "amp.jl"

import Clustering.ClusteringResult

include("ClusteringMethod.jl")


## clustering analysis result from a possible combination of expected genotypes
struct ClusterAnalysisResult
    init_centers        ::Array{Float_T,2} ## no longer necessary because it represents one combination of genotypes, but different combinations of genotypes with the same number of genotypes may result in the same clustering results
    dist_mtx_winit      ::Array{Float_T,2}
    cluster_result      ::ClusteringResult
    centers             ::Array{Float_T,2}
    slhts               ::Vector{Float_T}
    slht_mean           ::Float_T
    check_dist_mtx      ::Array{Float_T,2}
    check_dist_bool     ::Bool
end ## type

mutable struct UniqCombinCenters
    uniq_combin_centers ::Set{Vector{Float_T}}
    car                 ::ClusterAnalysisResult
    slht_mean           ::Float_T
    geno_combins        ::Vector{Matrix{Float_T}}
end ## type

struct AssignGenosResult
    cluster_result      ::ClusteringResult
    best_i              ::Int
    best_genos_combins  ::Vector{Matrix{Int}}
    expected_genos_all  ::Matrix{Int}
    ucc_dict            ::OrderedDict{Set{Vector{Float_T}},UniqCombinCenters}
end ## type

## constant used in allelic_discrimination.jl
const CATEG_WELL_VEC = [
    (:rbbs_ary3,   Colon()),
    (:blsub_fluos, Colon()),
    (:d0,          Colon()),
    (:cq,          Colon())
]

## 3 groups without NTC (non-template control)
# const DEFAULT_egr = [1 0 1; 0 1 1] # homo ch1, homo ch2, hetero
# const DEFAULT_init_FACTORS = [1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
# const DEFAULT_eg_LABELS = ["homo_a", "homo_b", "hetero", "unclassified"]

# const CTRL_WELL_VEC = fill(Vector{Int}(), length(DEFAULT_init_FACTORS)) # All empty. NTC, homo ch1, homo ch2, hetero
const CTRL_WELL_DICT = OrderedDict{Vector{Int},Vector{Int}}() # key is genotype (Vector{Int}), value is well numbers (Vector{Int})
## example
# const CTRL_WELL_DICT = OrderedDict(
#     [0, 0] => [1, 2], # NTC, well 1 and 2
#     [1, 0] => [3, 4], # homo ch1, well 3 and 4
#     [0, 1] => [5, 6], # homo ch2, well 5 and 6
#     [1, 1] => [7, 8]  # hetero, well 7 and 8
# )
## old approach
# const CTRL_WELL_DICT = DefaultOrderedDict(Vector{Int}, Vector{Int}, Vector{Int}())

EMPTY_UCC_DICT = OrderedDict{Set{Vector{Float_T}},UniqCombinCenters}()
EMPTY_BEST_GENO_COMBINS = Vector{Matrix{Int}}()
