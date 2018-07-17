# types for allelic discrimination, needed for `type AmpStepRampOutput`, therefore needed to be included before "amp.jl", can't be in "allelic_discrimination.jl" because in there `prep_input_4ad` utilize `type AmpStepRampOutput`

# clustering analysis result from a possible combination of expected genotypes
type ClusterAnalysisResult
    init_centers::Array{Float64,2} # no longer necessary because it represents one combination of genotypes, but different combinations of genotypes with the same number of genotypes may result in the same clustering results
    dist_mtx_winit::Array{Float64,2}
    cluster_result::ClusteringResult
    centers::Array{Float64,2}
    slhts::Vector{Float64}
    slht_mean::Float64
    check_dist_mtx::Array{Float64,2}
    check_dist_bool::Bool
end # type

type UniqCombinCenters
    uniq_combin_centers::Set{Vector{Float64}}
    car::ClusterAnalysisResult
    slht_mean::Float64
    geno_combins::Vector{Matrix{Float64}}
end # type

type AssignGenosResult
    cluster_result::ClusteringResult
    best_i::Int
    best_genos_combins::Vector{Matrix{Int}}
    expected_genos_all::Matrix{Int}
    ucc_dict::OrderedDict{Set{Vector{Float64}},UniqCombinCenters}
end # type




#
