# types for allelic discrimination, needed for `type AmpStepRampOutput`, therefore needed to be included before "amp.jl", can't be in "allelic_discrimination.jl" because in there `prep_input_4ad` utilize `type AmpStepRampOutput`

# clustering analysis result from a possible combination of expected genotypes
type ClusterAnalysisResult
    init_centers::Array{AbstractFloat,2} # no longer necessary because it represents one combination of genotypes, but different combinations of genotypes with the same number of genotypes may result in the same clustering results
    dist_mtx_winit::Array{AbstractFloat,2}
    cluster_result::ClusteringResult
    centers::Array{AbstractFloat,2}
    slhts::Vector{AbstractFloat}
    slht_mean::AbstractFloat
    check_dist_mtx::Array{AbstractFloat,2}
    check_dist_bool::Bool
end # type

type UniqCombinCenters
    uniq_combin_centers::Set{Vector{AbstractFloat}}
    car::ClusterAnalysisResult
    slht_mean::AbstractFloat
    geno_combins::Vector{Matrix{AbstractFloat}}
end # type

type AssignGenosResult
    cluster_result::ClusteringResult
    best_i::Int
    best_genos_combins::Vector{Matrix{Int}}
    expected_genos_all::Matrix{Int}
    ucc_dict::OrderedDict{Set{Vector{AbstractFloat}},UniqCombinCenters}
end # type




#
