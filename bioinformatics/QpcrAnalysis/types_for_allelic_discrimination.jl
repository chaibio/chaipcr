# types for allelic discrimination, needed for `type AmpStepRampOutput`, therefore needed to be included before "amp.jl", can't be in "allelic_discrimination.jl" because in there `prep_input_4ad` utilize `type AmpStepRampOutput`

# clustering analysis result from a possible combination of expected genotypes
type ClusterAnalysisResult
    init_centers::Array{AbstractFloat,2}
    cost_mtx_winit::Array{AbstractFloat,2}
    cluster_result::ClusteringResult
    centers::Array{AbstractFloat,2}
    slhts::Vector{AbstractFloat}
    slht_mean::AbstractFloat
end # type

# assign genotypes
type AssignGenosResult
    cluster_result::ClusteringResult
    best_i::Int
    expected_genos_vec::Vector{Array{Int,2}}
    car_vec::Vector{ClusterAnalysisResult}
end # type




#
