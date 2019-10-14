#===============================================================================

    AssignGenosResult.jl

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import Clustering.ClusteringResult


struct AssignGenosResult
    cluster_result      ::ClusteringResult
    best_i              ::Int_T
    best_genos_combins  ::Vector{Matrix{Int_T}}
    expected_genos_all  ::Matrix{Int_T}
    ucc_dict            ::OrderedDict{Set{Vector{Float_T}},UniqCombinCenters}
end


## constants >>

const EMPTY_BEST_GENO_COMBINS = Vector{Matrix{Int_T}}()

## default values for processing preset calibration data with 4 groups
const DEFAULT_AMP_ENCGR = Array{Int_T,2}(0, 0)
## const DEFAULT_AMP_ENCGR = [0 1 0 1; 0 0 1 1] ## NTC, homo ch1, homo ch2, hetero
const DEFAULT_AMP_INIT_FACTORS = [1, 1, 1, 1] ## sometimes "hetero" may not have very high end-point fluo
const DEFAULT_AMP_APG_LABELS = ["ntc", "homo_1", "homo_2", "hetero", "unclassified"] ## [0 1 0 1; 0 0 1 1]
## const DEFAULT_AMP_APG_LABELS = ["hetero", "homo_2", "homo_1", "ntc", "unclassified"] ## [1 0 1 0; 1 1 0 0]

## 3 groups without NTC (non-template control)
# const DEFAULT_EGR = [1 0 1; 0 1 1] # homo ch1, homo ch2, hetero
# const DEFAULT_AMP_INIT_FACTORS = [1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
# const DEFAULT_AMP_EG_LABELS = ["homo_a", "homo_b", "hetero", "unclassified"]

const DEFAULT_AMP_CTRL_WELL_DICT = OrderedDict{Vector{Int_T},Vector{Int_T}}()
## key is genotype (Vector{Int}), value is well numbers (Vector{Int_T})
## example
# const DEFAULT_AMP_CTRL_WELL_DICT = OrderedDict(
#     [0, 0] => [1, 2], # NTC, well 1 and 2
#     [1, 0] => [3, 4], # homo ch1, well 3 and 4
#     [0, 1] => [5, 6], # homo ch2, well 5 and 6
#     [1, 1] => [7, 8]  # hetero, well 7 and 8
# )
## old approach
# const DEFAULT_AMP_CTRL_WELL_DICT = DefaultOrderedDict(Vector{Int_T}, Vector{Int_T}, Vector{Int_T}())

const DEFAULT_AMP_CATEG_WELL_VEC = Vector{Pair{Symbol,Any}}([
    :rbbs_ary3      => Colon(),     ## calibrated_data
    :blsub_fluos    => Colon(), ## baseline_subtracted_data
    :d0             => Colon(),
    :cq             => Colon()])

# const DEFAULT_AMP_CYCS                  = 0
const DEFAULT_AMP_CLUSTER_METHOD        = k_means_medoids
const DEFAULT_AMP_NORM_L                = 2
