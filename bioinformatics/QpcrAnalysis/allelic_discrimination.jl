# allelic discrimination (ad)

# 4 groups
const DEFAULT_egr = [0 1 0 1; 0 0 1 1] # NTC, homo ch1, homo ch2, hetero
const DEFAULT_init_FACTORS = [1, 1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
const DEFAULT_eg_LABELS = ["ntc", "homo_a", "homo_b", "hetero", "unclassified"]

# # 3 groups without NTC
# const DEFAULT_egr = [1 0 1; 0 1 1] # homo ch1, homo ch2, hetero
# const DEFAULT_init_FACTORS = [1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
# const DEFAULT_eg_LABELS = ["homo_a", "homo_b", "hetero", "unclassified"]

const CATEG_WELL_VEC = [
    ("rbbs_ary3", []),
    ("blsub_fluos", []),
    ("d0", []),
    ("cq", [])
]

const kmeans_result_EMPTY = kmeans(1. * [1 2 3; 4 5 6], 2)


# # may be needed if not always called by `process_amp_1sr`
# type AllelicDiscriminationResult #
#     cluster_result::ClusteringResult
#     # assignments_adj::Vector{Int}
#     assignments_adj_labels::Vector{String}
# end # type


# start with bottom-level function, goes step-wise


function prep_input_4ad(
    full_amp_out::AmpStepRampOutput, # one step/ramp of amplification output
    expected_genotypes_raw::AbstractMatrix, # each column is a vector of binary genotype whose length is number of channels (0 => no signal, 1 => yes signal)
    categ::String="fluo",
    well_idc::AbstractVector=[],
    cycs::Union{Integer,AbstractVector}=1 # relevant if `categ == "fluo"`, last available cycle
    )

    num_cycs, num_wells, num_channels = size(full_amp_out.fr_ary3)

    expected_genotypes = expected_genotypes_raw

    if categ in ["rbbs_ary3", "blsub_fluos"]
        fluos = getfield(full_amp_out, parse(categ))
        if cycs == 0
            cycs = num_cycs
        end # if cycs == 0
        if isa(cycs, Integer)
            cycs = (cycs:cycs) # `blsub_fluos[an_integer, :, :]` results in size `(num_wells, num_channels)` instead of `(1, num_wells, num_channels)`
        end # if isa(cycs, Integer)
        data_t = reshape(mean(fluos[cycs, :, :], 1), num_wells, num_channels)

    elseif categ == "d0"
        # d0_i_vec = find(full_amp_out.fitted_prebl[1, 1].coef_strs) do coef_str
        #     coef_str == categ
        # end
        # data_t = length(d0_i_vec) == 0 ? zeros(num_wells, num_channels) : full_amp_out.coefs[d0_i_vec[1], :, :] * 1. # without `* 1.`, MethodError: no method matching kmeans!(::Array{AbstractFloat,2}, ::Array{Float64,2}); Closest candidates are: kmeans!(::Array{T<:AbstractFloat,2}, ::Array{T<:AbstractFloat,2}; weights, maxiter, tol, display) where T<:AbstractFloat at E:\for_programs\julia_pkgs\v0.6\Clustering\src\kmeans.jl:27
        data_t = map(full_amp_out.d0) do d0
            isnan(d0) ? 0 : d0
        end

    elseif categ == "cq"
        data_t = map(full_amp_out.cq) do cq_val
            isnan(cq_val) ? AbstractFloat(num_cycs) : cq_val # `Interger` resulted in `InexactError()`
        end # do cq_val
        expected_genotypes = 1 - expected_genotypes_raw
    end # if categ

    if length(well_idc) == 0 # to support JSON format as an empty vector, because can't pass `Colon()` by JSON
        well_idc = Colon()
    end

    data = transpose(data_t[well_idc, :])

    return (data, expected_genotypes)

end # prep_data_4ad


function assign_genotypes(
    data::AbstractMatrix,
    expected_genotypes::AbstractMatrix, # each column is a vector of binary genotype whose length is number of channels (0 => channel min, 1 => channel max)
    cluster_method::String,
    # below not specified by `process_ad` as of right now
    init_factors::AbstractVector=DEFAULT_init_FACTORS, # for `init_centers`
    rdcd_lower::Real=0.1; # lower limit of `relative_diff_closest_dist`
    eg_labels::AbstractVector=DEFAULT_eg_LABELS # Julia v0.6.0 on 2017-06-25: `eg_labels::Vector{AbstractString}=DEFAULT_eg_LABELS` resulted in "ERROR: MethodError: no method matching #assign_genotypes#301(::Array{AbstractString,1}, ::QpcrAnalysis.#assign_genotypes, ::Array{Float64,2}, ::Array{Float64,2}, ::Float64)"
    )

    num_channels, num_wells = size(data)

    if any(map(i -> length(unique(data[i, :])) == 1, 1:num_channels)) # for any channel, all the data points are the same (would result in "AssertionError: !(isempty(grp))" for `kmedoids`)
        cluster_result = kmeans_result_EMPTY
        assignments_adj_labels = fill(eg_labels[end], num_wells) # all unclassified
    else
        channel_extrema = hcat(minimum(data, 2), maximum(data, 2))

        num_genotypes = size(expected_genotypes)[2]
        init_centers = [
            channel_extrema[
                channel_i,
                expected_genotypes[channel_i, genotype_i] + 1 # allele == 0 => channel_extrema[,1], allele == 1 => channel_extrema[,2]
            ]
            for channel_i in 1:num_channels, genotype_i in 1:num_genotypes
        ] .* transpose(init_factors)

        if cluster_method in ["k-means", "k-means-medoids"]
            # run k-means whether finally using k-means or k-medoids
            cluster_result = kmeans!(data, copy(init_centers)) # ideally the element with the same index between `init_centers` and `cluster_result.centers` should be for the same genotype
            if cluster_method == "k-means"
                centers = cluster_result.centers
            elseif cluster_method == "k-means-medoids"
                init_centers = cluster_result.centers # using centers found by k-means
            end
        end
        if cluster_method in ["k-means-medoids", "k-medoids"]
            num_centers = size(init_centers)[2]
            data_winit = hcat(data, init_centers)
            num_wells_winit = num_wells + num_centers
            cost_mtx_winit = [norm(data_winit[:, i] .- data_winit[:, j], 2) for i in 1:num_wells_winit, j in 1:num_wells_winit]
            cluster_result = kmedoids!(cost_mtx_winit, Vector{Int}((1:num_centers) + num_wells))
            centers = data_winit[:, cluster_result.medoids]
        end # if cluster_method

        assignments_raw = cluster_result.assignments[1:num_wells] # when `cluster_method == "k-medoids"`

        dist2centers_vec = map(1:size(data)[2]) do i_well
            dist_coords = data[:, i_well] .- centers # type KmedoidsResult has no field centers
            map(1:num_genotypes) do i_genotype
                norm(dist_coords[:, i_genotype], 2)
            end # do i_genotype
        end # do i_well

        relative_diff_closest_dists = map(dist2centers_vec) do dist2centers
            sorted_d2c = sort(dist2centers)
            d2c_min1, d2c_min2 = sorted_d2c[1:2]
            (d2c_min2 - d2c_min1) / d2c_min1
        end # do dist2centers

        unclassfied_assignment = length(eg_labels)
        assignments_adj = map(1:length(assignments_raw)) do i
            relative_diff_closest_dists[i] > rdcd_lower ? assignments_raw[i] : unclassfied_assignment
        end # do i # previously `assignments_raw .* (relative_diff_closest_dists .> rdcd_lower)`
        assignments_adj_labels = map(a -> eg_labels[a], assignments_adj)

    end # if length(unique

    return (cluster_result, assignments_adj_labels)

end # assign_genotypes


function process_ad(
    full_amp_out::AmpStepRampOutput,
    cycs::Union{Integer,AbstractVector}, # relevant if `categ == "fluo"`, last available cycle
    cluster_method::String, # for `assign_genotypes`
    expected_genotypes_raw::AbstractMatrix=DEFAULT_egr, # each column is a vector of binary genotype whose length is number of channels (0 => no signal, 1 => yes signal)
    categ_well_vec::AbstractVector=CATEG_WELL_VEC,
    )

    # output
    # OrderedDict(
    #     categ => Clustering.ClusteringResult,
    # )

    cluster_result_dict = OrderedDict{String,ClusteringResult}()
    assignments_adj_labels_dict = OrderedDict{String,Vector{String}}()

    for categ_well_tuple in categ_well_vec
        categ, well_idc = categ_well_tuple
        cluster_result_dict[categ], assignments_adj_labels_dict[categ] = assign_genotypes(prep_input_4ad(
            full_amp_out,
            expected_genotypes_raw,
            categ,
            well_idc,
            cycs
        )..., cluster_method)
    end # for

    return (cluster_result_dict, assignments_adj_labels_dict)

end # process_ad_sr




#
