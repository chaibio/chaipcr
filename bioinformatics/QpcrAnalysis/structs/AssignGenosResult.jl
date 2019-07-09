#===========================

	AssignGenosResult.jl

    Author: Tom Price
	Date:   July 2019

============================#

import Clustering.ClusteringResult


struct AssignGenosResult
    cluster_result      ::ClusteringResult
    best_i              ::Int
    best_genos_combins  ::Vector{Matrix{Int}}
    expected_genos_all  ::Matrix{Int}
    ucc_dict            ::OrderedDict{Set{Vector{Float_T}},UniqCombinCenters}
end


## constants >>

const EMPTY_BEST_GENO_COMBINS = Vector{Matrix{Int}}()

## default values for processing preset calibration data with 4 groups
const DEFAULT_encgr = Array{Int,2}(0, 0)
## const DEFAULT_encgr = [0 1 0 1; 0 0 1 1] ## NTC, homo ch1, homo ch2, hetero
const DEFAULT_init_FACTORS = [1, 1, 1, 1] ## sometimes "hetero" may not have very high end-point fluo
const DEFAULT_apg_LABELS = ["ntc", "homo_1", "homo_2", "hetero", "unclassified"] ## [0 1 0 1; 0 0 1 1]
## const DEFAULT_apg_LABELS = ["hetero", "homo_2", "homo_1", "ntc", "unclassified"] ## [1 0 1 0; 1 1 0 0]

## 3 groups without NTC (non-template control)
# const DEFAULT_egr = [1 0 1; 0 1 1] # homo ch1, homo ch2, hetero
# const DEFAULT_init_FACTORS = [1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
# const DEFAULT_eg_LABELS = ["homo_a", "homo_b", "hetero", "unclassified"]

const CTRL_WELL_DICT = OrderedDict{Vector{Int},Vector{Int}}()
## key is genotype (Vector{Int}), value is well numbers (Vector{Int})
## example
# const CTRL_WELL_DICT = OrderedDict(
#     [0, 0] => [1, 2], # NTC, well 1 and 2
#     [1, 0] => [3, 4], # homo ch1, well 3 and 4
#     [0, 1] => [5, 6], # homo ch2, well 5 and 6
#     [1, 1] => [7, 8]  # hetero, well 7 and 8
# )
## old approach
# const CTRL_WELL_DICT = DefaultOrderedDict(Vector{Int}, Vector{Int}, Vector{Int}())

const CATEG_WELL_VEC = [
    (:rbbs_ary3,   Colon()), 	## calibrated_data
    (:blsub_fluos, Colon()),	## baseline_subtracted_data
    (:d0,          Colon()),
    (:cq,          Colon())]
