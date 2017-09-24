# allelic discrimination (ad)

# 4 groups
const DEFAULT_encgr = [0 1 0 1; 0 0 1 1] # NTC, homo ch1, homo ch2, hetero
const DEFAULT_init_FACTORS = [1, 1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
const DEFAULT_apg_LABELS = ["ntc", "homo_a", "homo_b", "hetero", "unclassified"]

# # 3 groups without NTC
# const DEFAULT_egr = [1 0 1; 0 1 1] # homo ch1, homo ch2, hetero
# const DEFAULT_init_FACTORS = [1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
# const DEFAULT_eg_LABELS = ["homo_a", "homo_b", "hetero", "unclassified"]

const CATEG_WELL_VEC = [
    ("rbbs_ary3", Colon()),
    ("blsub_fluos", Colon()),
    ("d0", Colon()),
    ("cq", Colon())
]

# const CTRL_WELL_VEC = fill(Vector{Int}(), length(DEFAULT_init_FACTORS)) # All empty. NTC, homo ch1, homo ch2, hetero
const CTRL_WELL_DICT = OrderedDict{Vector{Int},Vector{Int}}() # key is genotype (Vector{Int}), value is well numbers (Vector{Int})
# # example
# const CTRL_WELL_DICT = OrderedDict(
#     [0, 0] => [1, 2], # NTC, well 1 and 2
#     [1, 0] => [3, 4], # homo ch1, well 3 and 4
#     [0, 1] => [5, 6], # homo ch2, well 5 and 6
#     [1, 1] => [7, 8] # hetero, well 7 and 8
# )
# # old approach
# const CTRL_WELL_DICT = DefaultOrderedDict(Vector{Int}, Vector{Int}, Vector{Int}())

# nrn
NRN_SELF = x -> x
NRN_NOT = x -> 1 .- x

# # may be needed if not always called by `process_amp_1sr`
# type AllelicDiscriminationResult #
#     cluster_result::ClusteringResult
#     # assignments_adj::Vector{Int}
#     assignments_adj_labels::Vector{String}
# end # type


# start with bottom-level function, goes step-wise


function prep_input_4ad(
    full_amp_out::AmpStepRampOutput, # one step/ramp of amplification output
    categ::String="fluo",
    well_idc::Union{AbstractVector,Colon}=Colon(),
    cycs::Union{Integer,AbstractVector}=1 # relevant if `categ == "fluo"`, last available cycle
    )

    num_cycs, num_wells, num_channels = size(full_amp_out.fr_ary3)

    nrn = NRN_SELF

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
        data_t = map(full_amp_out.d0) do d0
            isnan(d0) ? 0 : d0
        end

    elseif categ == "cq"
        data_t = map(full_amp_out.cq) do cq_val
            isnan(cq_val) ? AbstractFloat(num_cycs) : cq_val # `Interger` resulted in `InexactError()`
        end # do cq_val
        nrn = NRN_NOT
    end # if categ

    data = transpose(data_t[well_idc, :])

    return (data, nrn)

end # prep_data_4ad


function do_cluster_analysis(
    data::AbstractMatrix,
    init_centers::AbstractMatrix,
    cluster_method::String="k-medoids"
    )

    # get pair-wise distance (cost) matrix
    num_wells = size(data)[2]
    data_winit = hcat(data, init_centers)
    num_centers = size(init_centers)[2]
    num_wells_winit = num_wells + num_centers
    cost_mtx_winit = [norm(data_winit[:, i] .- data_winit[:, j], 2) for i in 1:num_wells_winit, j in 1:num_wells_winit]

    # clustering
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
        cluster_result = kmedoids!(cost_mtx_winit, Vector{Int}((1:num_centers) + num_wells))
        centers = data_winit[:, cluster_result.medoids]
    end # if cluster_method

    # get silhouettes
    well_idc = 1:num_wells
    slhts = silhouettes(cluster_result, cost_mtx_winit[well_idc, well_idc])
    slht_mean = mean(slhts)

    # add to collection, TBD list or dict
    return ClusterAnalysisResult(
        init_centers,
        cost_mtx_winit,
        cluster_result,
        centers,
        slhts,
        slht_mean
    )

end # do_cluster_analysis


function assign_genos(
    data::AbstractMatrix,
    nrn::Function,
    expected_ncg_raw::AbstractMatrix=DEFAULT_encgr,
    ctrl_well_dict::OrderedDict=CTRL_WELL_DICT,
    cluster_method::String="k-means",
    # below not specified by `process_ad` as of right now
    init_factors::AbstractVector=DEFAULT_init_FACTORS, # for `init_centers`
    slht_lb::Real=0; # lower limit of silhouette
    apg_labels::AbstractVector=DEFAULT_apg_LABELS # apg = all possible genotypes. Julia v0.6.0 on 2017-06-25: `apg_labels::Vector{AbstractString}=DEFAULT_eg_LABELS` resulted in "ERROR: MethodError: no method matching #assign_genos#301(::Array{AbstractString,1}, ::QpcrAnalysis.#assign_genos, ::Array{Float64,2}, ::Array{Float64,2}, ::Float64)"
    )

    num_channels, num_wells = size(data)

    well_idc = 1:num_wells

    max_num_genos = 2 ^ num_channels # 2 comes from the binary possible values, i.e. presence/absence of signal for each channel

    unclassfied_assignment = max_num_genos + 1
    if length(apg_labels) != unclassfied_assignment
        error("The number of labels does not equal the number of all possible genotypes.")
    end

    if any(map(i -> length(unique(data[i, :])) == 1, 1:num_channels)) # for any channel, all the data points are the same (would result in "AssertionError: !(isempty(grp))" for `kmedoids`)

        car = do_cluster_analysis(data .+ rand(size(data)...), rand(num_channels, 2), cluster_method)
        car.cluster_result.assignments = fill(unclassfied_assignment, num_wells)

        cluster_result = car.cluster_result
        best_i = 1
        expected_genos_vec = Vector{Vector{Int}}()
        car_vec = [car]

        assignments_adj_labels = fill(apg_labels[end], num_wells)

    else

        channel_extrema = hcat(minimum(data, 2), maximum(data, 2))

        expected_genos_all = nrn(vcat([
            hcat(fill(
                hcat(map([0, 1]) do geno
                    fill(geno, 1, 2 ^ (i-1))
                end...),
                2 ^ (num_channels - i)
            )...)
            for i in 1:num_channels
        ]...)) # each column is a vector of binary geno whose length is number of channels (0 => channel min, 1 => channel max)
        geno_idc_all = 1:size(expected_genos_all)[2]

        # determine initial centers based on extrema for each channel, defined here instead of in the for-loop for possible non-control genotypes to avoid repetitively computing the same inital centers
        init_centers_all = [
            channel_extrema[
                channel_i,
                expected_genos_all[channel_i, geno_i] + 1 # allele == 0 => channel_extrema[,1], allele == 1 => channel_extrema[,2]
            ]
            for channel_i in 1:num_channels, geno_i in 1:max_num_genos
        ] .* transpose(init_factors)

        # control genotypes
        ctrl_genos = collect(keys(ctrl_well_dict)) # Vector{Vector{Int}}
        ctrl_geno_bool_vec = map(geno_idc_all) do geno_idx
            expected_genos_all[:, geno_idx] in ctrl_genos
        end
        ctrl_geno_idc = geno_idc_all[ctrl_geno_bool_vec]
        num_ctrl_genos = length(ctrl_geno_idc)

        # update initial centers according to controls with known genotypes if present
        for i in 1:length(ctrl_genos)
            ctrl_well_nums = ctrl_well_dict[ctrl_genos[i]]
            ctrl_well_data = data[:, ctrl_well_nums]
            init_centers_all[:, ctrl_geno_idc[i]] = (ctrl_well_data, 2)
        end # for i


        if length(expected_ncg_raw) != 0 # expected genotypes specified for non-control wells

            expected_ncg = nrn(expected_ncg_raw)
            non_ctrl_geno_idc = map(1:size(expected_ncg)[2]) do encg_idx
                encg = expected_ncg[:, encg_idx]
                for geno_idx in 1:size(expected_genos_all)[2]
                    eg = expected_genos_all[:, geno_idx]
                    if encg == eg
                        return geno_idx
                    end # if
                end # for
            end # do
            geno_idc = vcat(ctrl_geno_idc, non_ctrl_geno_idc)
            init_centers = init_centers_all[:, geno_idc]
            car = do_cluster_analysis(data, init_centers, cluster_method)

            best_i = 1
            expected_genos_vec = [expected_genos_all[geno_idc]]
            car_vec = [car]

        else # no expected genotypes specified for non-control wells, perform cluster analysis on all possible combinations of genotypes

            # non-control genotypes
            non_ctrl_geno_idc = geno_idc_all[.!ctrl_geno_bool_vec]
            # num_non_ctrl_genos = length(non_ctrl_geno_idc)

            # initial conditions for `while` loop
            expected_genos_vec = Vector{Vector{Int}}()
            car_vec = Vector{ClusterAnalysisResult}()
            num_genos = max_num_genos

            while num_genos >= 2 # `p_` = possible
                for num_expected_ncg in (num_genos - num_ctrl_genos):-1:0
                    possible_ncg_idc_vec = combinations(non_ctrl_geno_idc, num_expected_ncg)
                    for possible_ncg_idc in possible_ncg_idc_vec
                        geno_idc = vcat(ctrl_geno_idc, possible_ncg_idc)
                        push!(expected_genos_vec, expected_genos_all[geno_idc])
                        init_centers = init_centers_all[geno_idc]
                        push!(car_vec, do_cluster_analysis(data, init_centers, cluster_method))
                    end # for possible_ncg_idc
                end # for num_expected_ncg
                num_genos -= 1
            end # while

            # find the best model (possible combination of genotypes resulting in largest silhouette mean)
            best_i = findmax(map(car -> car.slht_mean, car_vec))[2]
            expected_genos = expected_genos_vec[best_i]
            car = car_vec[best_i]

        end # if length


        init_centers, cost_mtx_winit, cluster_result, centers, slhts, slht_mean = map(fn -> getfield(car, fn), fieldnames(car))

        assignments_raw = cluster_result.assignments[well_idc] # when `cluster_method == "k-medoids"`

        # check whether the controls are assigned with the correct genos, if not, assign as unclassified
        for ctrl_geno in keys(ctrl_well_dict)
            for i in 1:size(expected_genos)[2]
                if expected_genos[:, i] == ctrl_geno
                    expected_ctrl_assignment = i
                    break
                end # if
            end # for i
            for ctrl_well_num in ctrl_well_dict[ctrl_geno]
                if assignments_raw[ctrl_well_num] != expected_ctrl_assignment
                    assignments_raw[ctrl_well_num] = unclassfied_assignment
                end # if
            end # for ctrl_well_num
        end # for ctrl_geno


        # # `relative_diff_closest_dists`, not used for now
        #
        # # compute distances of data points to centers
        # dist2centers_vec = map(1:size(data)[2]) do i_well
        #     dist_coords = data[:, i_well] .- centers # type KmedoidsResult has no field centers
        #     map(1:num_genos) do i_geno
        #         norm(dist_coords[:, i_geno], 2)
        #     end # do i_geno
        # end # do i_well
        #
        # # compute relative difference between the distances of each data point to the two centers it is closest to
        # relative_diff_closest_dists = map(dist2centers_vec) do dist2centers
        #     sorted_d2c = sort(dist2centers)
        #     d2c_min1, d2c_min2 = sorted_d2c[1:2]
        #     (d2c_min2 - d2c_min1) / d2c_min1
        # end # do dist2centers
        # println("rdcd: \n", relative_diff_closest_dists)


        # assign as unclassified the wells where `relative_diff_closest_dist` is below the lower bound `slht_lb`, i.e. unclear which geno should be assigned
        assignments_adj = map(1:length(assignments_raw)) do i
            slhts[i] > slht_lb ? assignments_raw[i] : unclassfied_assignment
        end # do i # previously `assignments_raw .* (relative_diff_closest_dists .> slht_lb)`
        assignments_adj_labels = map(a -> apg_labels[a], assignments_adj)

    end # if any

    return (assignments_adj_labels, AssignGenosResult(
        cluster_result,
        best_i,
        expected_genos_vec,
        car_vec
    ))

end # assign_genos


function process_ad(
    full_amp_out::AmpStepRampOutput,
    cycs::Union{Integer,AbstractVector}, # relevant if `categ == "fluo"`, last available cycle
    ctrl_well_dict::OrderedDict,
    cluster_method::String, # for `assign_genos`
    expected_ncg_raw::AbstractMatrix=DEFAULT_encgr, # each column is a vector of binary geno whose length is number of channels (0 => no signal, 1 => yes signal)
    categ_well_vec::AbstractVector=CATEG_WELL_VEC,

    )

    # output
    # OrderedDict(
    #     categ => Clustering.ClusteringResult,
    # )

    assignments_adj_labels_dict = OrderedDict{String,Vector{String}}()
    agr_dict = OrderedDict{String,AssignGenosResult}()

    for categ_well_tuple in categ_well_vec
        categ, well_idc = categ_well_tuple
        assignments_adj_labels_dict[categ], agr_dict[categ] = assign_genos(prep_input_4ad(
            full_amp_out,
            categ,
            well_idc,
            cycs
        )..., expected_ncg_raw, ctrl_well_dict, cluster_method)
    end # for

    return (assignments_adj_labels_dict, agr_dict)

end # process_ad_sr




#
