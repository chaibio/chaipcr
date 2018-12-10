# allelic_discrimination.jl

import DataStructures.OrderedDict
import Clustering.ClusteringResult

# 4 groups
const DEFAULT_encgr = Array{Int,2}(0, 0)
# const DEFAULT_encgr = [0 1 0 1; 0 0 1 1] # NTC, homo ch1, homo ch2, hetero
const DEFAULT_init_FACTORS = [1, 1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
const DEFAULT_apg_LABELS = ["ntc", "homo_1", "homo_2", "hetero", "unclassified"] # [0 1 0 1; 0 0 1 1]
# const DEFAULT_apg_LABELS = ["hetero", "homo_2", "homo_1", "ntc", "unclassified"] # [1 0 1 0; 1 1 0 0]

# # 3 groups without NTC
# const DEFAULT_egr = [1 0 1; 0 1 1] # homo ch1, homo ch2, hetero
# const DEFAULT_init_FACTORS = [1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
# const DEFAULT_eg_LABELS = ["homo_a", "homo_b", "hetero", "unclassified"]

const CATEG_WELL_VEC = [
    ("rbbs_ary3",   Colon()),
    ("blsub_fluos", Colon()),
    ("d0",          Colon()),
    ("cq",          Colon())
]

# const CTRL_WELL_VEC = fill(Vector{Int}(), length(DEFAULT_init_FACTORS)) # All empty. NTC, homo ch1, homo ch2, hetero
const CTRL_WELL_DICT = OrderedDict{Vector{Int},Vector{Int}}() # key is genotype (Vector{Int}), value is well numbers (Vector{Int})
# # example
# const CTRL_WELL_DICT = OrderedDict(
#     [0, 0] => [1, 2], # NTC, well 1 and 2
#     [1, 0] => [3, 4], # homo ch1, well 3 and 4
#     [0, 1] => [5, 6], # homo ch2, well 5 and 6
#     [1, 1] => [7, 8]  # hetero, well 7 and 8
# )
# # old approach
# const CTRL_WELL_DICT = DefaultOrderedDict(Vector{Int}, Vector{Int}, Vector{Int}())

# nrn: whether to flip the binary genotype or not
NRN_SELF = x -> x
NRN_NOT = x -> 1 .- x

# # may be needed if not always called by `process_amp_1sr`
# type AllelicDiscriminationResult #
#     cluster_result ::ClusteringResult
#     # assignments_adj ::Vector{Int}
#     assignments_adj_labels ::Vector{String}
# end # type


# start with bottom-level function, goes step-wise


function prep_input_4ad(
    full_amp_out ::AmpStepRampOutput, # one step/ramp of amplification output
    categ ::String="fluo",
    well_idc ::Union{AbstractVector,Colon}=Colon(),
    cycs ::Union{Integer,AbstractVector}=1 # relevant if `categ == "fluo"`, last available cycle
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
    raw_data ::AbstractMatrix,
    init_centers ::AbstractMatrix,
    cluster_method ::String="k-means-medoids",
    norm_l ::Real=2
    )

    num_wells = size(raw_data)[2]

    # # add slope 2/1 scaled as another dimension
    # slope_vec = raw_data[2,:] ./ raw_data[1,:]
    # new_data = vcat(raw_data, transpose(slope_vec) .* mean(raw_data[1:2,:], 1) ./ median(slope_vec))
    # init_centers = vcat(init_centers, ones(1, size(init_centers)[2]))

    new_data = raw_data # not additional info

    # get pair-wise distance (cost) matrix
    data_winit = hcat(new_data, init_centers)
    num_centers = size(init_centers)[2]
    num_wells_winit = num_wells + num_centers
    dist_mtx_winit = [
        norm(data_winit[:, i] .- data_winit[:, j], norm_l)
        for i in 1:num_wells_winit, j in 1:num_wells_winit
    ]

    # clustering
    if cluster_method in ["k-means", "k-means-medoids"]
        # run k-means whether finally using k-means or k-medoids
        cluster_result = kmeans!(new_data, copy(init_centers)) # ideally the element with the same index between `init_centers` and `cluster_result.centers` should be for the same genotype
        if cluster_method == "k-means"
            centers = cluster_result.centers
        elseif cluster_method == "k-means-medoids"
            init_centers = cluster_result.centers # using centers found by k-means
        end
    end
    if cluster_method in ["k-means-medoids", "k-medoids"]
        cluster_result = kmedoids!(dist_mtx_winit, Vector{Int}((1:num_centers) + num_wells))
        centers = data_winit[:, cluster_result.medoids]
    end # if cluster_method

    # get silhouettes
    well_idc = 1:num_wells
    assignments_woinit = cluster_result.assignments[well_idc]
    counts_woinit = map(1:maximum(assignments_woinit)) do assignment
        sum(assignments_woinit .== assignment)
    end # do assignment
    slhts = silhouettes(
        assignments_woinit,
        counts_woinit,
        dist_mtx_winit[well_idc, well_idc]
    )
    slht_mean = mean(slhts)


    # let's designate a data point in group g1 as g1_dp1, another data point in group g1 as g1_dp2, the distance between g1_dp1 and g1_dp2 as g1_dist1to2, and the minimum among all g1_dist1to2, g1_dist1to3 ... g1_dist1toX as g1_dist1min. Then among all g1_dist1min, g1_dist2min ... g1_distXmin, find the maximum g1_dist_within_min_max.
    # then look at g1 vs. other groups. for each other group g2, g3 ... gY, find as g1_dist_between_min as the minimum distance between a data point in g1 and a data point in other group. Record the boolean value g1_bool evaluated as `g1_dist_within_min_max < g1_dist_between_min`
    # break if all the boolean values g1_bool, g2_bool ... gY_bool are true

    dist_mtx = dist_mtx_winit[well_idc, well_idc]

    check_dist_vec = map(1:num_centers) do grp_i

        gi_bool_vec = (assignments_woinit .== grp_i)
        if sum(gi_bool_vec) == 0
            return [0 0]
        end
        gi_idc = well_idc[gi_bool_vec]

        dist_mtx_between = dist_mtx[gi_bool_vec, .!gi_bool_vec]
        dist_between_min = length(dist_mtx_between) == 0 ? 0 : minimum(dist_mtx_between)

        dist_within_margin_max = 0
        update_dwmm = false

        if sum(gi_bool_vec) == 2
            dist_within_margin_max = getindex(dist_mtx, gi_idc...)

        elseif sum(gi_bool_vec) > 2
            # find the edge whose length always ranked 2nd (can tie 1st or 3rd) in any triangle that forms within grp_i and contains this edge, then assign `dist_within_margin_max` the length of this edge
            for edge in combinations(gi_idc, 2)
                dist_edge = getindex(dist_mtx, edge...)
                for gi_idx_ne in gi_idc
                    if !(gi_idx_ne in edge)
                        gi_idx_e1, gi_idx_e2 = edge
                        update_dwmm = true
                        if (dist_mtx[gi_idx_ne, gi_idx_e1] - dist_edge) * (dist_mtx[gi_idx_ne, gi_idx_e2] - dist_edge) > 0 # edge not ranked 2nd
                            update_dwmm = false
                            break
                        end # if
                    end # if
                end # for gi_idx_ne
                if update_dwmm
                    dist_within_margin_max = dist_edge
                end # if
            end # for edge
        end # if

        return [dist_within_margin_max dist_between_min]

    end # do grp_i

    # `dist_mtx` has been modified

    check_dist_mtx = vcat(check_dist_vec...)

    check_dist_bool = maximum(check_dist_mtx[:, 1]) < minimum(check_dist_mtx[:, 2])


    # add to collection, TBD list or dict
    return ClusterAnalysisResult(
        init_centers,
        dist_mtx_winit,
        cluster_result,
        centers,
        slhts,
        slht_mean,
        check_dist_mtx,
        check_dist_bool
    )

end # do_cluster_analysis


# steps to assign genotypes:
# 1. check whether expected genotypes are specified, if yes use them, if not start with all possible genotypes determined by number of channels
# 2.
function assign_genos(
    data ::AbstractMatrix,
    nrn ::Function,
    ntc_bool_vec ::Vector{Bool},
    expected_ncg_raw ::AbstractMatrix=DEFAULT_encgr,
    ctrl_well_dict ::OrderedDict=CTRL_WELL_DICT,
    cluster_method ::String="k-means-medoids",
    norm_l ::Real=2,
    # below not specified by `process_ad` as of right now
    init_factors ::AbstractVector=DEFAULT_init_FACTORS, # for `init_centers`
    slht_lb ::Real=0; # lower limit of silhouette
    apg_labels ::AbstractVector=DEFAULT_apg_LABELS # apg = all possible genotypes. Julia v0.6.0 on 2017-06-25: `apg_labels ::Vector{AbstractString}=DEFAULT_eg_LABELS` resulted in "ERROR: MethodError: no method matching #assign_genos#301( ::Array{AbstractString,1}, ::QpcrAnalysis.#assign_genos, ::Array{Float64,2}, ::Array{Float64,2}, ::Float64)"
    )

    num_channels, num_wells = size(data)

    ntc_geno = fill(0, num_channels)

    well_idc = 1:num_wells

    max_num_genos = 2 ^ num_channels # 2 comes from the binary possible values, i.e. presence/absence of signal for each channel

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

    ntc_geno_idx = find(geno_idx -> all(expected_genos_all[:, geno_idx] .== ntc_geno), geno_idc_all)[1]

    non_ntc_geno_idc = geno_idc_all[geno_idc_all .!= ntc_geno_idx]
    non_ntc_geno_combin = expected_genos_all[:, non_ntc_geno_idc]

    unclassified_assignment = max_num_genos + 1
    if length(apg_labels) != unclassified_assignment
        error("The number of labels does not equal the number of all possible genotypes.")
    end

    if any(map(i -> length(unique(data[i, :])) == 1, 1:num_channels)) # for any channel, all the data points are the same (would result in "AssertionError: !(isempty(grp))" for `kmedoids`)

        car = do_cluster_analysis(data .+ rand(size(data)...), rand(num_channels, 2), cluster_method, norm_l)
        car.cluster_result.assignments = fill(unclassified_assignment, num_wells)

        cluster_result = car.cluster_result
        best_i = 1
        best_geno_combins = Vector{Matrix{Int}}()
        ucc_dict = OrderedDict{Set{Vector{AbstractFloat}},UniqCombinCenters}()

        assignments_adj_labels = fill(apg_labels[end], num_wells)

    else

        channel_extrema = hcat(minimum(data, 2), maximum(data, 2))

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
            ctrl_well_idc = ctrl_well_dict[ctrl_genos[i]] .+ 1 # transform 0-indexed well_nums to 1-indexed well_idc
            ctrl_well_data = data[:, ctrl_well_idc]
            init_centers_all[:, ctrl_geno_idc[i]] = mean(ctrl_well_data, 2)
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
            car = do_cluster_analysis(data, init_centers, cluster_method, norm_l)

            best_i = 1
            car_vec = [car]

        else # no expected genotypes specified for non-control wells, perform cluster analysis on all possible combinations of genotypes

            # non-control genotypes
            non_ctrl_geno_idc = geno_idc_all[.!ctrl_geno_bool_vec]
            # num_non_ctrl_genos = length(non_ctrl_geno_idc)

            # initial conditions for `while` loop
            num_genos = max_num_genos
            ucc_dict = OrderedDict{Set{Vector{AbstractFloat}},UniqCombinCenters}()

            good_enough = false

            while num_genos >= 2 # `p_` = possible

                good_enough_vec = Vector{Bool}()

                for num_expected_ncg in (num_genos - num_ctrl_genos) : -1 : max(2 - num_ctrl_genos, 0)

                    possible_ncg_idc_vec = combinations(non_ctrl_geno_idc, num_expected_ncg)

                    good_enough_vec = Vector{Bool}()

                    for possible_ncg_idc in possible_ncg_idc_vec

                        geno_idc = vcat(ctrl_geno_idc, possible_ncg_idc)
                        geno_combin = expected_genos_all[:, geno_idc]

                        init_centers = init_centers_all[:, geno_idc]
                        car = do_cluster_analysis(data, init_centers, cluster_method, norm_l)

                        centers = car.centers
                        center_set = Set(map(1:size(centers)[2]) do i
                            centers[:, i]
                        end) # do i
                        if !(center_set in keys(ucc_dict))
                            ucc_dict[center_set] = UniqCombinCenters(
                                center_set,
                                car,
                                car.slht_mean,
                                [geno_combin]
                            )
                        else
                            push!(ucc_dict[center_set].geno_combins, geno_combin) # assuming that for any two clustering results with the same set of final centers, cr_1 and cr_2, the same data point is assigned to the same center point in both cr_1 and cr_2
                            if geno_combin == non_ntc_geno_combin # `geno_combin` includes all genotypes except NTC
                                ucc_dict[center_set].car = car
                            end # if num_genos
                        end # if !

                        push!(good_enough_vec, car.check_dist_bool)

                    end # for possible_ncg_idc

                    if any(good_enough_vec)
                        good_enough = true
                        break
                    end

                end # for num_expected_ncg

                if good_enough
                    break
                end

                num_genos -= 1

            end # while

            # find the best model (possible combination of genotypes resulting in largest silhouette mean)
            ucc_vec = collect(values(ucc_dict))
            best_i = findmax(map(ucc -> ucc.slht_mean, ucc_vec))[2]
            # expected_genos = expected_genos_vec[best_i]
            best_ucc = ucc_vec[best_i]
            best_num_genos = length(best_ucc.uniq_combin_centers)
            # println("best_num_genos ", best_num_genos)
            best_geno_combins = best_ucc.geno_combins
            car = best_ucc.car

        end # if length

        init_centers, dist_mtx_winit, cluster_result, centers, slhts, slht_mean = map(fn -> getfield(car, fn), fieldnames(car))

        all_unclassified = true

        if best_num_genos >= max_num_genos - 1 # can call genotypes

            all_unclassified = false

            assignments_raw = cluster_result.assignments[well_idc] # when `cluster_method == "k-medoids"`

            if best_num_genos == max_num_genos
                ref_center_idc = 1:max_num_genos
                # assignments_agp_idc = assignments_raw
            elseif best_num_genos == max_num_genos - 1
                ref_center_idc = non_ntc_geno_idc
                # assignments_agp_idc = map(a -> non_ntc_geno_idc[a], assignments_raw)
            # no possible case for `else`
            end

            expected_genos = expected_genos_all[:, ref_center_idc]

            dist_optm_init_centers = [
                norm(centers[:, i] .- init_centers_all[:, j], norm_l)
                for i in 1:best_num_genos, j in 1:max_num_genos
            ]

            # println(init_centers_all)

            # re-assign centers based on distance to initial centers
            # (work liks US medical residency match) find max for each dimension as reference point, compare centers to reference point, assign genotype based on min distance between center/medoid and reference point; if a center/medoid has min distance (among all centers/medoids) to multiple reference point, this group is unclassified
            # (why?) don't forget to change [0, 1] to [1, 0] and default labels
            new_center_idc = zeros(Int, best_num_genos)
            while any(new_center_idc .== 0)
                for i in 1:best_num_genos
                    if new_center_idc[i] == 0
                        min_dist_ij, closest_j = findmin(dist_optm_init_centers[i, :])
                        if !(closest_j in new_center_idc)
                            min_dist_ji, closest_i = findmin(dist_optm_init_centers[:, closest_j])
                            if closest_i == i
                                new_center_idc[i] = closest_j
                                dist_optm_init_centers[i, :] = +Inf
                                dist_optm_init_centers[:, closest_j] = +Inf
                            end # if closest_i
                        end # if !
                    end # if new_center_idc
                end # for i
                # println(dist_optm_init_centers)
                # println(new_center_idc)
            end # while

            # println("new_center_idc ", new_center_idc)

            if num_channels == 2 && all(sum(expected_genos_all[:, new_center_idc], 1) .< 2) # dual channel, no hetero, only homo1, homo2, ntc

                ntc_center = centers[:, new_center_idc .== ntc_geno_idx]

                homo1_center = centers[:, map(new_center_idc) do nci
                    all(expected_genos_all[:, nci] .== [1, 0])
                end] # do i

                homo2_center = centers[:, map(new_center_idc) do nci
                    all(expected_genos_all[:, nci] .== [0, 1])
                end] # do i

                vec_n1 = homo1_center .- ntc_center
                vec_n2 = homo2_center .- ntc_center

                angle_1n2 = acos(dot(vec_n1, vec_n2) / (norm(vec_n1) * norm(vec_n2)))

                if angle_1n2 > 0.5 * pi
                    new_center_idc[new_center_idc .== ntc_geno_idx] = find(geno_idc_all) do geno_idx
                        all(expected_genos_all[:, geno_idx] .== [1, 1])
                    end[1] # change ntc to hetero
                end

            end # if num_channels

            # # is this necessary?
            # if best_num_genos == max_num_genos - 1 && ntc_geno_idx in new_center_idc
            #     all_unclassified = true
            # end

            # # (!!!! needs testing) check whether the controls are assigned with the correct genos, if not, assign as unclassified
            # for ctrl_geno in keys(ctrl_well_dict)
            #     for i in 1:size(expected_genos)[2]
            #         if expected_genos[:, i] == ctrl_geno
            #             expected_ctrl_assignment = i # needs to use `centers`, `assignments_agp_idc`
            #             break
            #         end # if
            #     end # for i
            #     for ctrl_well_num in ctrl_well_dict[ctrl_geno]
            #         if assignments_agp_idc[ctrl_well_num] != expected_ctrl_assignment
            #             assignments_agp_idc .= unclassified_assignment # Because assignments of different clusters depend on one another, if control well(s) is/are assigned incorrectly, the other wells may be assigned incorrectly as well.
            #         end # if
            #     end # for ctrl_well_num
            # end # for ctrl_geno
            # for which contrast (1, 0). Venn diagram showing overlapping among the significant for each contrast.
            # write.table(twl_cic[apply(twl_cic[,contrast_vec], 1, function(row_) sum(row_) > 0),], sprintf()

            assignments_agp_idc = new_center_idc[assignments_raw]
            # values of `new_center_idc` are permuted from `geno_idc_all`, which correspond to order of `expected_genos_all`.
            # `new_center_idc` is ordered same as centers, whose order corresponds to values of `assignments_raw`.
            # values of `assignments_raw` correspond to order of centers

        end # if best_num_genos


        if all_unclassified
            assignments_adj = fill(unclassified_assignment, num_wells)
        else # assign as unclassified the wells where silhouette is below the lower bound `slht_lb`, i.e. unclear which geno should be assigned
            assignments_adj = map(1:length(assignments_agp_idc)) do i
                slhts[i] < slht_lb ? unclassified_assignment: assignments_agp_idc[i]
            end # do i # previously `assignments_agp_idc .* (relative_diff_closest_dists .> slht_lb)`
        end # if all_unclassified

        assignments_adj_labels = map(a -> apg_labels[a], assignments_adj)

    end # if any(map


    return (assignments_adj_labels, AssignGenosResult(
        # best
        cluster_result,
        
        best_i,
        best_geno_combins,
        # all
        expected_genos_all,
        ucc_dict
    ))

end # assign_genos


function process_ad(
    full_amp_out ::AmpStepRampOutput,
    cycs ::Union{Integer,AbstractVector}, # relevant if `categ == "fluo"`, last available cycle
    ctrl_well_dict ::OrderedDict,
    cluster_method ::String, # for `assign_genos`
    norm_l ::Real, # for `assign_genos`
    expected_ncg_raw ::AbstractMatrix=DEFAULT_encgr, # each column is a vector of binary geno whose length is number of channels (0 => no signal, 1 => yes signal)
    categ_well_vec ::AbstractVector=CATEG_WELL_VEC,
    )

    # output
    # OrderedDict(
    #     categ => Clustering.ClusteringResult,
    # )

    assignments_adj_labels_dict = OrderedDict{String,Vector{String}}()
    agr_dict = OrderedDict{String,AssignGenosResult}()

    # indicate a well as NTC if all the channels have NaN as Cq
    ntc_bool_vec = map(1:length(full_amp_out.fluo_well_nums)) do i
        all(isnan.(full_amp_out.cq[i,:]))
    end

    for categ_well_tuple in categ_well_vec
        categ, well_idc = categ_well_tuple
        assignments_adj_labels_dict[categ], agr_dict[categ] = assign_genos(prep_input_4ad(
            full_amp_out,
            categ,
            well_idc,
            cycs
        )...,
        ntc_bool_vec, expected_ncg_raw, ctrl_well_dict, cluster_method, norm_l)
    end # for

    return (assignments_adj_labels_dict, agr_dict)

end # process_ad




#
