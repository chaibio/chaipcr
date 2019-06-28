## standard_curve.jl

import JSON
import DataFrames: DataFrame, by
import Match.@match
import Memento: debug, warn, error

## if isnull(sample) well not considered
## what if isnull(cq)


## called by QpcrAnalyze.dispatch
## formerly called function standard_curve
## `/slope` for log (DNA copy#) is on the x-axis and Cq on the y-axis, otherwise `*slope`
function act(
    ::Val{standard_curve},
    req_vec     ::Vector{Any};
    out_format  ::Symbol = :pre_json,
    json_digits ::Integer =JSON_DIGITS,
    qty_base    ::Real =10,
    empty_tre   ::TargetResultEle =EMPTY_TRE,
    empty_gre   ::GroupResultEle  =EMPTY_GRE
)
    debug(logger, "at act(::Val{standard_curve})")
    #
    ## parse data
    const req_df = reqvec2df(req_vec)
    #
    ## empty dataset
    if  size(req_df, 2) == 0 ||
        any(map(symbl -> all(isnan.(req_df[symbl])),[:target, :cq, :qty]))
            const output = OrderedDict(:targets => [], :groups => [], :valid => false)
            return out_format == :json ? JSON.json(output) : output
    end
    #
    ## target result set
    const target_result_df = by(req_df, :target) do chunk_target
        const target_id = chunk_target[1, :target]
        if isnan(target_id)
            empty_tre
        else
            const nna_vec = map(range(1, size(chunk_target, 1))) do i
                !isnan(chunk_target[i, :qty]) && !isnan(chunk_target[i, :cq])
            end
            const used_chunk_target = chunk_target[nna_vec, :]
            ## better to use GLM.jl here
            const x_vec = log.(qty_base, used_chunk_target[:qty])
            const y_vec = used_chunk_target[:cq]
            const b0, b1 = linreg(x_vec, y_vec)
            const eff = exp(-log(e, qty_base) / b1) - 1
            const y_mean = mean(y_vec)
            const ss_res = sum(map(i -> (b0 + b1 * x_vec[i] - y_vec[i])^2, range(1, sum(nna_vec))))
            const ss_tot = sum(map(y -> (y - y_mean)^2, y_vec))
            const r2_ = 1 - ss_res / ss_tot
            ## adjusted R2 ?
            TargetResultEle(
                target_id,
                round.([b1, b0, eff, r2_], json_digits)...)
        end ## if isnan
    end ## do chunk_target

    ## group results calculation commented out
    ## as this calculation is duplicated in the front end
    ## TP 2019/03/12
    #
    ## group result set
    # group_result_df = by(req_df, :sample) do chunk_sample
    #     if isnan(chunk_sample[1, :sample])
    #         return hcat(
    #             DataFrame(target=0),
    #             DataFrame(x1=empty_gre)) ## assuming the default column name is `:x1`
    #     else
    #         return by(chunk_sample, :target) do chunk_target
    #             target_id = chunk_target[1, :target]
    #             if isnan(target_id)
    #                 return empty_gre
    #             else
    #                 cq_vec  = chunk_target[.!isnan.(chunk_target[:cq]), :cq]
    #                 qty_vec = chunk_target[.!isnan.(chunk_target[:qty]), :qty]
    #                 return GroupResultEle(
    #                     chunk_target[:well] |> unique |> sort,
    #                     chunk_target[1, :target],
    #                     round.([
    #                         mean(cq_vec),
    #                         std(cq_vec),
    #                         mean(qty_vec),
    #                         std(qty_vec)
    #                     ], json_digits)...
    #                 )
    #             end ## if
    #         end ## do chunk_target
    #     end ## if
    # end ## do chunk

    ## report results
    (out_format == :full) && return target_result_df

    ## out_format != :full
    ## target result set
    tre_vec = target_result_df[.!isnan.(target_result_df[:target]), 2]
    target_vec = Vector{Any}()
    for tre in tre_vec
        if isnan(tre.slope) && isnan(tre.offset)
            const err_msg = "less 2 valid data points of cq and/or qty available for fitting standard curve"
            warn(logger, err_msg)
            target_result = OrderedDict(
                :target_id => getfield(tre, :target_id),
                :error     => err_msg)
        else
            target_result = tre
        end
        push!(target_vec, target_result)
    end ## next tre

    ## group results reporting commented out
    ## as the calculation is duplicated in the front end
    ## TP 2019/03/12
    #
    ## group result set
    # gre_vec = group_result_df[:, 3]
    # uniq_well_combins = map(x -> x[:well], gre_vec) |> unique
    # grp_vec = Vector{OrderedDict}()
    # for well_combin in uniq_well_combins
    #     if length(well_combin) > 1
    #         grp_target_vec = Vector{OrderedDict}()
    #         gre_idc = find(gre_vec) do gre
    #             gre_wells = getfield(gre, :well)
    #             return length(gre_wells) == length(well_combin) && all(gre_wells .== well_combin)
    #         end
    #         for gre_idx in gre_idc
    #             gre = gre_vec[gre_idx]
    #             target_id = getfield(gre, :target_id)
    #             if target_id != 0
    #                 qty_mean_m, qty_mean_b = scinot(getfield(gre, :qty_mean), json_digits)
    #                 qty_sd_m, qty_sd_b = scinot(getfield(gre, :qty_sd), json_digits)
    #                 push!(grp_target_vec, OrderedDict(
    #                     :target_id              =>  target_id,
    #                     :cq                     =>  OrderedDict(
    #                         :mean               =>      getfield(gre, :cq_mean),
    #                         :standard_deviation =>      getfield(gre, :cq_sd)),
    #                     :quantity               =>  OrderedDict(
    #                         :mean               =>      OrderedDict(
    #                             :m              =>          qty_mean_m,
    #                             :b              =>          qty_mean_b),
    #                         :standard_deviation =>      OrderedDict(
    #                             :m              =>          qty_sd_m,
    #                             :b              =>          qty_sd_b))))
    #             end ## if target_id
    #         end ## do gre_i
    #     push!(grp_vec, OrderedDict(
    #         :wells   => well_combin,
    #         :targets => grp_target_vec))
    #     end ## if
    # end ## do well_combin
    #
    output = OrderedDict(
        :targets => target_vec,
        :groups  => Vector(),
        :valid   => true)
    return out_format == :json ? JSON.json(output) : output
end ## act(::Val{standard_curve})


## dependencies of `standard_curve`

## parse req_vec into a dataframe
function reqvec2df(req_vec ::AbstractVector)
    #
    (length(req_vec) == 0) && return DataFrame()
    #
    well_vec = Vector{Int}()
    channel_vec = Vector{Int}()
    target_vec = Vector{Real}()
    cq_vec = Vector{AbstractFloat}()
    qty_vec = Vector{AbstractFloat}()
    sample_vec = Vector{Real}()
    #
    num_channels = maximum(map(req_vec) do req_ele
        try length(req_ele[WELL_KEY])
        catch
            0
        end ## try
    end) ## do req_ele
    #
    for well_i in range(1, length(req_vec))
        req_ele = req_vec[well_i]
        for channel_i in range(1, num_channels)
            measrmt_dict =
                try req_ele[WELL_KEY][channel_i]
                catch
                    Dict{String,Any}()
                end ## try
            if length(measrmt_dict) == 0
                target = cq = qty = NaN
            else
                target = nothing2NaN(measrmt_dict[TARGET_KEY])
                cq = nothing2NaN(measrmt_dict["cq"])
                qty_dict = measrmt_dict[QUANTITY_KEY]
                qty = nothing2NaN(qty_dict["m"]) * 10.0 ^ nothing2NaN(qty_dict["b"])
            end ## if
            push!(well_vec, well_i)
            push!(channel_vec, channel_i)
            push!(target_vec, target)
            push!(cq_vec, cq)
            push!(qty_vec, qty)
            push!(sample_vec,
                try nothing2NaN(req_ele[SAMPLE_KEY])
                catch
                    NaN
                end) ## try
        end ## for channel_i
    end ## for well_i
    #
    return DataFrame(
        well = well_vec,
        channel = channel_vec,
        target = target_vec,
        cq = cq_vec,
        qty = qty_vec,
        sample = sample_vec)
end

## end: dependencies of `standard_curve`


## generate standard_curve request for testing, and dependency functions;
## not to be used in production

## generate unique integers
function generate_uniq_ints(num_ints ::Integer, S, rng ::AbstractRNG =Base.GLOBAL_RNG)
    if num_ints > length(S)
        error(logger, "num_ints > length(S), i.e. no enough values to choose from")
    end
    uniq_ints = unique(rand(rng, S, num_ints))
    while length(uniq_ints) < num_ints
        uniq_ints = unique(vcat(uniq_ints, rand(rng, S, num_ints - length(uniq_ints))))
    end
    return uniq_ints
end

## insert slice of the same element into array
## by searching along one dimension for positions to insert.
## user specifies element, number of insertion actions, destination array, search dimension.
function insert2ary(
    el2ins,
    num_ins             ::Integer,
    ary                 ::AbstractArray,
    seek2ins_along_dim  ::Integer =1,
    rng                 ::AbstractRNG =Base.GLOBAL_RNG
)
    const dim_len = size(ary)[seek2ins_along_dim]
    const idx_range = 1:(dim_len + num_ins)
    const ins_idc = generate_uniq_ints(num_ins, idx_range, rng)
    const ins_vec = sort(ins_idc) .- (1:num_ins) .+ 1
    const ins_mtx =
        hcat(
            vcat(1, ins_vec),
            vcat(ins_vec .- 1, dim_len))

    const ary_ndims = ndims(ary)
    const ary_ut = Array{Union{eltype(ary),typeof(el2ins)},ary_ndims}(ary)
    select_all_idx_vec = Vector{Any}(fill(Colon(), ary_ndims)) ## make sure eltype is a supertype of Vector{Int}
    const ary_size = size(ary)
    const ins_size = map(range(1, ary_ndims)) do i
        i == seek2ins_along_dim ? 1 : ary_size[i]
    end
    const ins_slice = fill(el2ins, ins_size...)

    const ary_wins =
        getindex(
            cat(seek2ins_along_dim,
                map(range(1, num_ins + 1)) do i
                    select_idx_vec = copy(select_all_idx_vec)
                    setindex!(select_idx_vec, ins_mtx[i,1] : ins_mtx[i,2], seek2ins_along_dim)
                    cat(seek2ins_along_dim, getindex(ary_ut, select_idx_vec...), ins_slice)
                end...), ## do i
            setindex!(select_all_idx_vec, idx_range, seek2ins_along_dim)...)
    return ary_wins
end ## insert2ary


## generate standard_curve request
function generate_req_sc(;
    ## random unless individually specified
    ## NA not counted as a unique value for `num_uniq`

    num_wells ::Integer =16,
    num_channels ::Integer =2,

    target_vec ::AbstractVector =[],
    num_uniq_targets ::Integer =10,
    lb_num_na_targets ::Integer =2,

    cq_vec ::AbstractVector =[],
    cq_bounds ::Tuple =(0.01, 40.0),
    num_na_cqs ::Integer =3,

    qm_vec ::AbstractVector =[],
    qm_bounds ::Tuple =(1, 10),
    qb_vec ::AbstractVector =[],
    qb_bounds ::Tuple{Int,Int} =(-20, 20),
    num_na_qtys ::Integer =0,

    sample_vec ::AbstractVector =[],
    num_uniq_samples ::Integer =4,
    num_na_samples ::Integer =2,

    rng_type ::DataType =MersenneTwister,
    seed ::Integer =1
)
    rng = rng_type(seed)

    println("num_wells: ", num_wells)
    println("num_channels: ", num_channels)

    if num_uniq_targets < num_channels
        num_na_channels = num_channels - num_uniq_targets
        channelwide_num_na_targets = num_na_channels * num_wells
        na_channel_idc = generate_uniq_ints(num_na_channels, 1:num_channels, rng)
        addi_num_na_targets = max(0, lb_num_na_targets - channelwide_num_na_targets)
        println("num_uniq_targets < num_channels. targets will all be na for channel(s) ", join(na_channel_idc, ","))
    else
        channelwide_num_na_targets = 0
        na_channel_idc = Vector{Int}()
        addi_num_na_targets = lb_num_na_targets
    end

    num_measrmts = num_wells * num_channels
    println("num_wells and num_channels mandate num_measrmts to be $num_measrmts (including na)")

    num_targets = length(target_vec)
    if num_targets == 0
        println("randomly generating targets...") ## target values should not be the same across different channels for the same well
        num_nna_targets = num_measrmts - channelwide_num_na_targets - addi_num_na_targets
        target_vec = insert2ary(NaN, addi_num_na_targets, fill(0, num_nna_targets), 1, rng)
        nna_channel_idc = find(1:num_channels) do channel_i
            !(channel_i in na_channel_idc)
        end
        available_targets = 1:num_uniq_targets
        num_uniq_targets_perchannel = Int(floor(num_uniq_targets / num_channels))
        for channel_i in nna_channel_idc
            target_idc_thischannel = ((1:num_wells) .-1) .* num_channels .+ channel_i
            nna_target_idc = target_idc_thischannel[
                map(target_idx -> !isnan(target_vec[target_idx]), target_idc_thischannel)]
            uniq_targets_thischannel =
                generate_uniq_ints(num_uniq_targets_perchannel, available_targets, rng)
            available_targets = setdiff(available_targets, uniq_targets_thischannel)
            nna_target_vec = rand(rng, uniq_targets_thischannel, length(nna_target_idc))
            for nna_idx_i in 1:length(nna_target_idc)
                target_vec[nna_target_idc[nna_idx_i]] = nna_target_vec[nna_idx_i]
            end
        end ## for channel_i

    elseif num_targets != num_measrmts
        error(logger, "target_vec not empty but length not same as num_measrmts")
    end ## if num_targets

    num_cqs = length(cq_vec)
    if num_cqs == 0
        println("randomly generating cq values...")
        num_nna_cqs = num_measrmts - num_na_cqs
        nna_cq_vec = rand(rng, num_nna_cqs) .* -(cq_bounds...) .+ cq_bounds[2] # upperbound - (0,1)seq * scaling_factor
        cq_vec = insert2ary(NaN, num_na_cqs, nna_cq_vec, 1, rng)
    elseif num_cqs != num_measrmts
        error(logger, "cq_vec not empty but length not same as num_measrmts")
    end

    num_qm = length(qm_vec)
    num_qb = length(qb_vec)
    if num_qm == num_qb == 0
        println("randomly generating quantity values...")
        num_nna_qtys = num_measrmts - num_na_qtys
        nna_qm_vec = rand(rng, num_nna_qtys) .* -(qm_bounds...) .+ qm_bounds[2]
        nna_qb_vec = rand(rng, qb_bounds[1]:qb_bounds[2], num_nna_qtys)
        nna_qty_mtx = hcat(nna_qm_vec, nna_qb_vec)
        qty_mtx = insert2ary(NaN, num_na_qtys, nna_qty_mtx, 1, rng)
        qm_vec = qty_mtx[:, 1]
        qb_vec = qty_mtx[:, 2] # not convert to integer due to NaN
    elseif num_qm != num_qb
        error(logger, "lengths of qm_vec and qb_vec not equal")
    elseif num_qm != num_measrmts
        error(logger, "qm_vec and qb_vec with equal non-0 length but not same as num_measrmts")
    end

    num_samples = length(sample_vec)
    if num_samples == 0
        println("randomly generating samples...")
        num_nna_samples = num_wells - num_na_samples
        nna_sample_vec = rand(rng, 1:num_uniq_samples, num_nna_samples)
        sample_vec = insert2ary(NaN, num_na_samples, nna_sample_vec, 1, rng)
    elseif num_samples != num_wells
        error(logger, "sample_vec not empty but length not same as num_wells")
    end

    req_vec = map(1:num_wells) do well_i
        OrderedDict(
            :well   => map(1:num_channels) do channel_i
                    measrmt_i = (well_i - 1) * num_channels + channel_i
                    OrderedDict(
                        :target     => target_vec[measrmt_i],
                        :cq         => cq_vec[measrmt_i],
                        :quantity   => OrderedDict(
                            :m          => qm_vec[measrmt_i],
                            :b          => qb_vec[measrmt_i]))
                end,
            :sample => sample_vec[well_i])
    end ## do well_i

    return (json(req_vec), req_vec)
end ## generate_req_sc




## experimental code >>

## recursive functions to simplify output

function simplify(x ::Number, out_format ::Symbol)
println("Number $x format $out_format")
    x
end

function simplify(tup ::Tuple, out_format ::Symbol)
println("Tuple $tup format $out_format")
    if out_format == :full
        tup
    else
        Tuple([
            simplify(tup[i],out_format) for i in range(1,length(tup))
        ])
    end
end

function simplify(vec ::Vector, out_format ::Symbol)
println("Vector $vec format $out_format")
    if out_format == :full
        vec
    else
        Vector([
            simplify(vec[i],out_format) for i in range(1,length(vec))
        ])
    end
end

function simplify(dict ::Associative, out_format ::Symbol)
println("Dict $dict format $out_format")
    if out_format == :full
        dict
    else
        x = OrderedDict()
        for i in keys(dict)
            x[i] = simplify(dict[i],out_format)
        end
        x
    end
end

function simplify(df ::DataFrame, out_format ::Symbol)
println("DataFrame $df format $out_format")
    if out_format == :full
        df
    else
        x = OrderedDict()
        for i in names(df)
            x[i] = simplify(df[i],out_format)
        end
        x
    end
end

function simplify(r ::Result, out_format ::Symbol)
println("Result $r format $out_format")
    if out_format == :full
        r
    else
        x = OrderedDict()
        if (haskey(x,:well) && length(x[:well])==0)         ||  # empty gre
            (haskey(x,:target_id) && isnan(x[:target_id]))      # empty tre
            return x
        end
        for i in fieldnames(r)
            x[i] = simplify(getfield(r,i),out_format)
        end
        x
    end
end

## << experimental code


## notes
## 2018-04-21. not reproducible:
## Tuple{Float16,Float16}((0.01, 40)) gives (Float16(0.04), Float16(40.0))
## Tuple{Float32,Float16}((0.01, 40)) gives (0.04f0, Float16(40.0))
## Tuple{Float64,Float16}((0.01, 40) gives (0.04, Float16(40.0))
## Tuple{Float64,Float16}((0.001, 40)) gives (0.001, Float16(40.0))
## Tuple{Float16,Float16}((0.001, 40)) gives (Float16(0.004), Float16(40.0))
## then as expected


#
