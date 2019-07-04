## allelic_discrimination.jl
##
## clusters data to identify allele groups

import DataStructures.OrderedDict
import Clustering: ClusteringResult, kmeans!, kmedoids!, silhouettes
import Combinatorics.combinations
import StatsBase.counts
import Memento: debug, info, error


## constants >>

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

const CTRL_WELL_DICT = OrderedDict{Vector{Int},Vector{Int}}() ## key is genotype (Vector{Int}), value is well numbers (Vector{Int})
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

const CATEG_WELL_VEC = [
    (:rbbs_ary3,   Colon()),
    (:blsub_fluos, Colon()),
    (:d0,          Colon()),
    (:cq,          Colon())]


## function definitions >>

## nrn: whether to flip the binary genotype or not
NRN_SELF = identity
NRN_NOT  = x -> 1 .- x

## start with bottom-level function, goes step-wise
function prep_input_4ad(
    ## one step/ramp of amplification output
    full_amp_out    ::AmpStepRampOutput,
    categ           ::Symbol = :fluo,
    well_idc        ::Union{AbstractVector, Colon} =Colon(),
    ## relevant if `categ == :fluo`, last available cycle
    cycs            ::Union{Integer, AbstractVector} =1
)
    num_cycs, n_wells, num_channels = size(full_amp_out.fr_ary3)
    nrn = NRN_SELF
    #
    if categ in [:rbbs_ary3, :blsub_fluos]
        fluos = getfield(full_amp_out, Symbol(categ))
        if cycs == 0
            cycs = num_cycs
        end ## if cycs == 0
        if isa(cycs, Integer)
            cycs = (cycs:cycs) ## `blsub_fluos[an_integer, :, :]` results in size `(n_wells, num_channels)` instead of `(1, n_wells, num_channels)`
        end ## if isa(cycs, Integer)
        data_t = reshape(mean(fluos[cycs, :, :], 1), n_wells, num_channels)
    #
    elseif categ == :d0
        data_t = map(full_amp_out.d0) do d0
            isnan(d0) ? 0 : d0
        end
    #
    elseif categ == :cq
        data_t = map(full_amp_out.cq) do cq_val
            isnan(cq_val) ? AbstractFloat(num_cycs) : cq_val ## `Integer` resulted in `InexactError()`
        end ## do cq_val
        nrn = NRN_NOT
    #
    ## any other value of `categ`: do nothing
    end ## if categ
    #
    data = transpose(data_t[well_idc, :])
    return (data, nrn)
end ## prep_data_4ad


function do_cluster_analysis(
    raw_data        ::AbstractMatrix,
    init_centers    ::AbstractMatrix,
    cluster_method  ::ClusteringMethod = K_means_medoids,
    norm_l          ::Real =2
)
    ## get pair-wise distance (cost) matrix
    ## matrix is symmetric with zeros on major diagonal
    ## calculate upper triangle and convert to Symmetric
    function calc_dist_mtx()
        _dist_mtx = zeros(Float_T,n_wells,n_wells)
        for j in colon(2,n_wells) ## columns
            for i in colon(1,j - 1) ## rows
                _dist_mtx[i,j] = norm(raw_data[:, i] .- raw_data[:, j], norm_l)
            end
        end
        return _dist_mtx |> Symmetric |> Matrix ## kmedoids! does not accept ::Symmetric
    end

    ## cluster analysis methods
    function clustering(::Val{K_means}, _init_centers)
        ## ideally the element with the same index between
        ## `init_centers` and `cluster_result.centers` should be for the same genotype
        _cluster_result = kmeans!(raw_data, _init_centers)
        return (_cluster_result, _cluster_result.centers)
    end

    ## Issue: how to use output from k-means clustering as input for k-medoids ???
    clustering(::Val{K_means_medoids}, _init_centers) =
        clustering(Val{K_medoids}(), clustering(Val{K_means}(), _init_centers)[2])

    function clustering(::Val{K_medoids}, _)
        ## _init_centers is [2 x num_centers] matrix, kmedoids! requires vector
        ## use dummy values 1:num_centers for now
        _cluster_result = kmedoids!(dist_mtx, collect(1:num_centers)) ## dist_mtx not dist_mtx_winit
        return (_cluster_result, raw_data[:, _cluster_result.medoids]) ## raw_data not data_winit
    end

    clustering(unknown_cluster_method, _) =
        throw(ArgumentError, "clustering method \"$unknown_cluster_method\" not implemented")

    ## get cluster silhouettes
    get_silhouettes() =
        silhouettes(
            assignments_woinit,
            counts(assignments_woinit),
            dist_mtx)

    ## let's designate a data point in group g1 as g1_dp1,
    ## another data point in group g1 as g1_dp2,
    ## the distance between g1_dp1 and g1_dp2 as g1_dist1to2,
    ## and the minimum among all g1_dist1to2, g1_dist1to3 ... g1_dist1toX as g1_dist1min.
    ## Then among all g1_dist1min, g1_dist2min ... g1_distXmin,
    ## find the maximum g1_dist_within_min_max.
    ## then look at g1 vs. other groups. for each other group g2, g3 ... gY,
    ## find as g1_dist_between_min as the minimum distance
    ## between a data point in g1 and a data point in other group.
    ## Record the boolean value g1_bool evaluated
    ## as `g1_dist_within_min_max < g1_dist_between_min`
    ## break if all the boolean values g1_bool, g2_bool ... gY_bool are true
    function check_groups()

        function check_grp(gi_bool_vec)

            dist_between_min() =
                (sum_gi_bool_vec == 0 || sum_gi_bool_vec == num_centers) ?
                    0.0 :
                    minimum(dist_mtx[gi_bool_vec, .!gi_bool_vec])

            function dist_within_margin_max()

                ## find the edge whose length always ranked 2nd
                ## (can tie 1st or 3rd) in any triangle that forms
                ## within grp_i and contains this edge,
                ## then assign `dist_within_margin_max` the length of this edge
                function calc_dist_within_margin_max()

                    is_second_longest(gi_idx_ne) =
                        prod(gi_idx_e -> dist_mtx[gi_idx_ne, gi_idx_e] - dist_edge, edge) <= 0.0

                    edge_always_second_longest() =
                        setdiff(gi_idc, edge) |> is_second_longest |> all
                    ## end of function definitions nested within calc_dist_within_margin_max()

                    ## vectorized code
                    edge = ()
                    dist_edge = 0.0
                    for edge in combinations(gi_idc, 2)
                        dist_edge = dist_mtx[edge...]
                        edge_always_second_longest() && return dist_edge
                    end
                    0.0
                    ## devectorized code
                    # _dist_within_margin_max = 0.0
                    # update_dwmm = false
                    # for edge in combinations(gi_idc, 2)
                    #     gi_idx_e1, gi_idx_e2 = edge
                    #     dist_edge = dist_mtx[gi_idx_e1, gi_idx_e2]
                    #     for gi_idx_ne in gi_idc
                    #         if !(gi_idx_ne in edge)
                    #             update_dwmm = true
                    #             if  (dist_mtx[gi_idx_ne, gi_idx_e1] - dist_edge) *
                    #                 (dist_mtx[gi_idx_ne, gi_idx_e2] - dist_edge) > 0.0 # edge not ranked 2nd
                    #                     update_dwmm = false
                    #                     break
                    #             end ## if
                    #         end ## if
                    #     end ## for gi_idx_ne
                    #     if update_dwmm
                    #         _dist_within_margin_max = dist_edge
                    #         break
                    #     end ## if
                    # end ## for edge
                    # return _dist_within_margin_max
                end ## calc_dist_within_margin_max()
                ## end of function definition nested within dist_within_margin_max()

                (sum_gi_bool_vec <= 1) && return 0.0
                const gi_idc = well_idc[gi_bool_vec]
                (sum_gi_bool_vec == 2) && return getindex(dist_mtx, gi_idc...)
                calc_dist_within_margin_max()
            end
            ## end of function definitions nested within check_grp()

            const sum_gi_bool_vec = sum(gi_bool_vec)
            [dist_within_margin_max() dist_between_min()]
        end ## check_grp()
        ## end of function definition nested within check_groups()

        mapreduce(
            grp_i -> check_grp(assignments_woinit .== grp_i),
            vcat,
            1:num_centers)
    end ## check_groups()
    ## end of function definitions nested within do_cluster_analysis()

    ## add slope 2/1 scaled as another dimension
    # slope_vec = raw_data[2,:] ./ raw_data[1,:]
    # new_data = vcat(raw_data, transpose(slope_vec) .* mean(raw_data[1:2,:], 1) ./ median(slope_vec))
    # init_centers = vcat(init_centers, ones(1, size(init_centers)[2]))

    const n_wells = size(raw_data,2)
    const well_idc = 1:n_wells
    const num_centers = size(init_centers,2)
    const dist_mtx = calc_dist_mtx()
    # const n_wells_winit = n_wells + num_centers
    # dist_mtx_winit = calc_dist_mtx_winit(init_centers)
    const (cluster_result, centers) =
        clustering(Val{cluster_method}(), copy(init_centers))
    const assignments_woinit = cluster_result.assignments[well_idc]
    const slhts = get_silhouettes()
    const slht_mean = mean(slhts)
    const check_dist_mtx = check_groups()
    const check_dist_bool = maximum(check_dist_mtx[:, 1]) < minimum(check_dist_mtx[:, 2])

    ## add to collection, TBD list or dict
    return ClusterAnalysisResult(
        init_centers,
        dist_mtx,
        cluster_result,
        centers,
        slhts,
        slht_mean,
        check_dist_mtx,
        check_dist_bool
    )
end ## do_cluster_analysis()


## steps to assign genotypes:
## 1. check whether expected genotypes are specified:
##    if yes use them,
##    if not start with all possible genotypes determined by number of channels
## 2.
function assign_genos(
    data                ::AbstractMatrix,
    nrn                 ::Function,
    ntc_bool_vec        ::Vector{Bool},
    expected_ncg_raw    ::AbstractMatrix =DEFAULT_encgr,
    ctrl_well_dict      ::OrderedDict =CTRL_WELL_DICT,
    cluster_method      ::ClusteringMethod = :K_means_medoids,
    norm_l              ::Real =2,
    ## below not specified by `process_ad` as of right now
    init_factors        ::AbstractVector =DEFAULT_init_FACTORS, # for `init_centers`
    slht_lb             ::Real =0; # lower limit of silhouette
    apg_labels          ::AbstractVector =DEFAULT_apg_LABELS
    ## `apg` - all possible genotypes.
    ## Julia v0.6.0 on 2017-06-25:
    ## `apg_labels ::Vector{AbstractString} =DEFAULT_eg_LABELS` resulted in
    ## "ERROR: MethodError: no method matching #assign_genos#301( ::Array{AbstractString,1},
    ## ::QpcrAnalysis.#assign_genos, ::Array{Float64,2}, ::Array{Float64,2}, ::Float64)"
)
    function calc_expected_genos_all()
        f(c ::Int) = 
            reduce(
                hcat,
                fill(
                    mapreduce(
                        geno -> fill(geno, 1, 2^(c-1)),
                        hcat,
                        [0, 1]),
                    2^(num_channels - c)))
        mapreduce(
            f,
            vcat,
            1:num_channels
        ) |> nrn
    end ## calc_expected_genos_all()

    ## for any channel, all the data points are the same
    ## (would result in "AssertionError: !(isempty(grp))" for `kmedoids`)
    function channel_all_equal()
        car = do_cluster_analysis(
                data .+ rand(size(data)...),
                rand(num_channels, 2),
                cluster_method,
                norm_l)
        car.cluster_result.assignments = fill(unclassified_assignment, n_wells)
        return (
            fill(apg_labels[end], n_wells), ## assignments_adj_labels
            AssignGenosResult(
                car.cluster_result, ## cluster_result
                1, ## best_i # Potential issue: ucc_dict empty so should return 0 ???
                EMPTY_BEST_GENO_COMBINS, ## best_geno_combins
                expected_genos_all,
                EMPTY_UCC_DICT)) ## ucc_dict
    end ## channel_all_equal()

    calc_init_centers_all() =
        [
            channel_extrema[
                channel_i,
                expected_genos_all[channel_i, geno_i] + 1 ## allele == 0 => channel_extrema[,1], allele == 1 => channel_extrema[,2]
            ]
            for channel_i in 1:num_channels, geno_i in 1:max_num_genos
        ] .* transpose(init_factors)

    ## no expected genotypes specified for non-control wells,
    ## perform cluster analysis on all possible combinations of genotypes
    function best_cluster_model()
        ## non-control genotypes
        const non_ctrl_geno_idc = geno_idc_all[.!ctrl_geno_bool_vec]
        ## initial conditions for `while` loop
        const num_genos = max_num_genos
        _ucc_dict = EMPTY_UCC_DICT
        good_enough = false
        while num_genos >= 2 ## `p_` = possible
            good_enough_vec = Vector{Bool}()
            for num_expected_ncg in
                colon((num_genos - num_ctrl_genos), -1, max(2 - num_ctrl_genos, 0))
                    good_enough_vec = Vector{Bool}()
                    for possible_ncg_idc in combinations(non_ctrl_geno_idc, num_expected_ncg)
                        car, geno_combin, center_set =
                            cluster_geno(vcat(ctrl_geno_idc, possible_ncg_idc))
                        if !(center_set in keys(_ucc_dict))
                            _ucc_dict[center_set] =
                                UniqCombinCenters(
                                    center_set,
                                    car,
                                    car.slht_mean,
                                    [geno_combin])
                        else
                            ## assuming that for any two clustering results
                            ## with the same set of final centers, cr_1 and cr_2,
                            ## the same data point is assigned to the same center point
                            ## in both cr_1 and cr_2
                            push!(_ucc_dict[center_set].geno_combins, geno_combin)
                            ## `geno_combin` includes all genotypes except NTC
                            if geno_combin == non_ntc_geno_combin
                                _ucc_dict[center_set].car = car
                            end ## if num_genos
                        end ## if !
                        push!(good_enough_vec, car.check_dist_bool)
                    end ## for possible_ncg_idc
                    if any(good_enough_vec)
                        good_enough = true
                        break
                    end
            end ## for num_expected_ncg
            good_enough && break
            num_genos -= 1
        end ## while
        ## find the best model (possible combination of genotypes
        ## resulting in largest silhouette mean)
        const ucc_keys = _ucc_dict |> keys |> collect
        const _best_i =
            findmax(
                collect(
                    map(key -> getfield(_ucc_dict[key],:slht_mean), ucc_keys)))[2]
        const _best_ucc = _ucc_dict[ucc_keys[_best_i]]
        # expected_genos = expected_genos_vec[best_i]
        return (_best_i, _best_ucc, _ucc_dict)
    end ## best_cluster_model()

    ## expected genotypes specified for non-control wells
    ## BUG: these 3 variables left undefined in previous code
    ## best_geno_combins, best_num_genos, ucc_dict
    function encg_cluster_model()
        const expected_ncg = nrn(expected_ncg_raw)
        const non_ctrl_geno_idc =
            map(1:size(expected_ncg,2)) do encg_idx
                find(1:size(expected_genos_all,2) do geno_idx
                    expected_ncg[:, encg_idx] == expected_genos_all[:, geno_idx]
                end)[1]
            end
        const (car, geno_combin, center_set) =
            cluster_geno(ctrl_geno_idc, non_ctrl_geno_idc)
        ## ??? is it OK to save cluster model in ucc_dict ???
        const ucc = UniqCombinCenters(
                        center_set,
                        car,
                        car.slht_mean,
                        [geno_combin])
        return (
            1, ## best_1
            ucc, ## best_ucc
            OrderedDict{Set{Vector{Float_T}},UniqCombinCenters}(
                center_set => ucc)) ## ucc_dict
    end

    function cluster_geno(idc...)
        const _geno_idc = vcat(idc...)
        const _car = do_cluster_analysis(
            data,
            init_centers_all[:, _geno_idc], ## init_centers
            cluster_method,
            norm_l)
        const _geno_combin = expected_genos_all[:, _geno_idc]
        const _center_set = Set(_car.centers[:, i] for i in 1:size(_car.centers, 2))
        return (_car, _geno_combin, _center_set)
    end ## cluster_geno()

    ## re-assign centers based on distance to initial centers
    ## (works like US medical residency match)
    ## find max for each dimension as reference point,
    ## compare centers to reference point,
    ## assign genotype based on min distance
    ## between center/medoid and reference point;
    ## if a center/medoid has min distance (among all centers/medoids)
    ## to multiple reference points, this group is unclassified
    ## (why?) don't forget to change [0, 1] to [1, 0] and default labels
    ## Issue: this seems appropriate for k-medoids but not k-means clustering ???
    function calc_new_center_idc()
        dist_optm_init_centers =
            [   norm(car.centers[:, i] .- init_centers_all[:, j], norm_l)
                for i in 1:best_num_genos, j in 1:max_num_genos             ]
        # println(init_centers_all)
        _new_center_idc = zeros(Int, best_num_genos)
        while any(_new_center_idc .== 0)
            for i in 1:best_num_genos
                if _new_center_idc[i] == 0
                    closest_j = findmin(dist_optm_init_centers[i, :])[2]
                    if !(closest_j in _new_center_idc)
                        closest_i = findmin(dist_optm_init_centers[:, closest_j])[2]
                        if closest_i == i
                            _new_center_idc[i] = closest_j
                            dist_optm_init_centers[i, :] = +Inf
                            dist_optm_init_centers[:, closest_j] = +Inf
                        end ## if closest_i
                    end ## if !
                end ## if _new_center_idc
            end ## for i
            # println(dist_optm_init_centers)
            # println(_new_center_idc)
        end ## while
        # println("_new_center_idc ", _new_center_idc)
        return _new_center_idc
    end ## calc_new_center_idc()

    ## if dual channel && no heteros only homo1, homo2, NTC
    function ntc2hetero!(_new_center_idc)
        const ntc_center_idc = (_new_center_idc .== ntc_geno_idx)
        const ntc_center    = car.centers[:, ntc_center_idc]
        const homo1_center  = car.centers[:,
            map(i -> all(expected_genos_all[:, i] .== [1, 0]), _new_center_idc)]
        const homo2_center  = car.centers[:,
            map(i -> all(expected_genos_all[:, i] .== [0, 1]), _new_center_idc)]
        const vec_n1 = homo1_center .- ntc_center
        const vec_n2 = homo2_center .- ntc_center
        const angle_1n2 = acos(dot(vec_n1, vec_n2) / (norm(vec_n1) * norm(vec_n2)))
        if angle_1n2 > 0.5 * pi
            ## change NTC to hetero
            _new_center_idc[ntc_center_idc] =
                find(geno_idc_all) do geno_idx
                    all(expected_genos_all[:, geno_idx] .== [1, 1])
                end[1]
        end ## if
    end ## ntc2hetero!()

    ## << end of function definitions nested within assign_genos()

    debug(logger, "at assign_genos()")
    const (num_channels, n_wells) = size(data)
    const max_num_genos = 2 ^ num_channels ## 2 comes from the binary possible values, i.e. presence/absence of signal for each channel
    const unclassified_assignment = max_num_genos + 1
    if length(apg_labels) != unclassified_assignment
        error(logger, "the number of labels does not equal the number of all possible genotypes")
    end
    ## `expected_genos_all` - each column is a vector of binary geno
    ## whose length is number of channels (0 => channel min, 1 => channel max)
    const expected_genos_all = calc_expected_genos_all()
    ## for any channel, all the data points are the same
    ## (would result in "AssertionError: !(isempty(grp))" for `kmedoids`)
    if any(map(i -> length(unique(data[i, :])) == 1, 1:num_channels))
        return channel_all_equal()
    end
    ## NTC (non-template controls)
    const geno_idc_all = 1:size(expected_genos_all,2)
    const ntc_geno = fill(0, num_channels)
    const ntc_geno_idx =
        find(
            geno_idx -> all(expected_genos_all[:, geno_idx] .== ntc_geno),
            geno_idc_all
        )[1]
    const non_ntc_geno_idc = geno_idc_all[geno_idc_all .!= ntc_geno_idx]
    const non_ntc_geno_combin = expected_genos_all[:, non_ntc_geno_idc]
    ## control genotypes
    const ctrl_genos = ctrl_well_dict |> keys |> collect ## Vector{Vector{Int}}
    const ctrl_geno_bool_vec = map(geno_idc_all) do geno_idx
        expected_genos_all[:, geno_idx] in ctrl_genos
    end
    const ctrl_geno_idc = geno_idc_all[ctrl_geno_bool_vec]
    const num_ctrl_genos = length(ctrl_geno_idc)
    ## determine initial centers based on extrema for each channel,
    ## defined here not in the for-loop for possible non-control genotypes
    ## to avoid repetitively computing the same inital centers
    const channel_extrema = hcat(minimum(data, 2), maximum(data, 2))
    init_centers_all = calc_init_centers_all()
    ## update initial centers according to controls with known genotypes if present
    for i in 1:length(ctrl_genos)
        ctrl_well_idc = ctrl_well_dict[ctrl_genos[i]] .+ 1 ## transform 0-indexed well_nums to 1-indexed well_idc
        ctrl_well_data = data[:, ctrl_well_idc]
        init_centers_all[:, ctrl_geno_idc[i]] = mean(ctrl_well_data, 2)
    end ## next i
    ## are expected genotypes specified for non-control wells?
    const (best_i, best_ucc, ucc_dict) =
        length(expected_ncg_raw) > 0 ?
            encg_cluster_model() :      ## yes
            best_cluster_model()        ## no
    ## use output of best clustering model
    const best_geno_combins = best_ucc.geno_combins
    const best_num_genos = length(best_ucc.uniq_combin_centers)
    const car = best_ucc.car
    # const init_centers, dist_mtx_winit, cluster_result, centers, slhts, slht_mean =
    #     map(fn -> getfield(car, fn), fieldnames(car))
    ## can we call any of the genotypes?
    if (best_num_genos < max_num_genos - 1 ) ## cannot call genotypes
        # const all_unclassified = true
        const assignments_adj = fill(unclassified_assignment, n_wells)
    else # can call genotypes
        # const all_unclassified = false
        #
        ## when `cluster_method == "k-medoids"`
        const assignments_raw = car.cluster_result.assignments[1:n_wells]
        #
        # if best_num_genos == max_num_genos
        #     const ref_center_idc = 1:max_num_genos
        #     # assignments_agp_idc = assignments_raw
        # elseif best_num_genos == max_num_genos - 1
        #     const ref_center_idc = non_ntc_geno_idc
        #     # assignments_agp_idc = map(a -> non_ntc_geno_idc[a], assignments_raw)
        # end ## no possible case for `else`
        # const expected_genos = expected_genos_all[:, ref_center_idc]
        #
        new_center_idc = calc_new_center_idc()
        if num_channels == 2 && all(sum(expected_genos_all[:, new_center_idc], 1) .< 2)
            ## if dual channel && no heteros only homo1, homo2, NTC
            ## change NTC to hetero
            new_center_idc = ntc2hetero!(new_center_idc)
        end ## if num_channels

        ## is this necessary?
        # if best_num_genos == max_num_genos - 1 && ntc_geno_idx in new_center_idc
        #     all_unclassified = true
        # end

        ## (!!!! needs testing) check whether the controls are assigned with the correct genos, if not, assign as unclassified
        # for ctrl_geno in keys(ctrl_well_dict)
        #     for i in 1:size(expected_genos)[2]
        #         if expected_genos[:, i] == ctrl_geno
        #             expected_ctrl_assignment = i ## needs to use `centers`, `assignments_agp_idc`
        #             break
        #         end ## if
        #     end ## for i
        #     for ctrl_well_num in ctrl_well_dict[ctrl_geno]
        #         if assignments_agp_idc[ctrl_well_num] != expected_ctrl_assignment
        #             assignments_agp_idc .= unclassified_assignment # Because assignments of different clusters depend on one another, if control well(s) is/are assigned incorrectly, the other wells may be assigned incorrectly as well.
        #         end ## if
        #     end ## for ctrl_well_num
        # end ## for ctrl_geno
        # for which contrast (1, 0). Venn diagram showing overlapping among the significant for each contrast.
        # write.table(twl_cic[apply(twl_cic[,contrast_vec], 1, function(row_) sum(row_) > 0),], sprintf()

        ## values of `new_center_idc` are permuted from `geno_idc_all`,
        ## which correspond to order of `expected_genos_all`.
        ## `new_center_idc` is ordered same as centers,
        ## whose order corresponds to values of `assignments_raw`.
        ## values of `assignments_raw` correspond to order of centers
        const assignments_agp_idc = new_center_idc[assignments_raw]
        #
        ## assign as unclassified the wells where silhouette is below
        ## the lower bound `slht_lb`, i.e. unclear which geno should be assigned
        ## previously `assignments_agp_idc .* (relative_diff_closest_dists .> slht_lb)`
        const assignments_adj =
            map(i -> (car.slhts[i] < slht_lb) ? unclassified_assignment : assignments_agp_idc[i],
                1:length(assignments_agp_idc))
    end ## if best_num_genos
    const assignments_adj_labels = map(a -> apg_labels[a], assignments_adj)
    return (
        assignments_adj_labels,
        AssignGenosResult(
            ## best
            car.cluster_result,
            best_i,
            best_geno_combins,
            ## all
            expected_genos_all,
            ucc_dict))
end ## assign_genos()


function process_ad(
    full_amp_out        ::AmpStepRampOutput,

    ## relevant if `categ == "fluo"`, last available cycle
    cycs                ::Union{Integer,AbstractVector},

    ctrl_well_dict      ::OrderedDict,
    cluster_method      ::ClusteringMethod, ## for `assign_genos`
    norm_l              ::Real, ## for `assign_genos`

    ## each column is a vector of binary geno whose length is number of channels
    ## (0 => no signal, 1 => yes signal)
    expected_ncg_raw    ::AbstractMatrix =DEFAULT_encgr,

    categ_well_vec      ::AbstractVector =CATEG_WELL_VEC,
)
    debug(logger, "at process_ad()")
    ## indicate a well as NTC (non-template control) if all the channels have NaN as Cq
    const ntc_bool_vec =
        map(1:length(full_amp_out.fluo_well_nums)) do well_idx
            all(isnan.(full_amp_out.cq[well_idx,:]))
        end
    ## output
    assignments_adj_labels_dict = OrderedDict{Symbol,Vector{Symbol}}()
    agr_dict = OrderedDict{Symbol,AssignGenosResult}()
    for categ_well_tuple in categ_well_vec
        categ, well_idc = categ_well_tuple
        data, nrn =
            prep_input_4ad(
                full_amp_out,
                categ,
                well_idc,
                cycs)
        assignments_adj_labels_dict[categ], agr_dict[categ] =
            assign_genos(
                data,
                nrn,
                ntc_bool_vec,
                expected_ncg_raw,
                ctrl_well_dict,
                cluster_method,
                norm_l)
    end ## next categ_well_tuple
    return (assignments_adj_labels_dict, agr_dict)
end ## process_ad()
