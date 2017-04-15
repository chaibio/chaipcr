#
# __precompile__() # need to manually add `__precompile__()` to "MySQL.jl". Something about package "MySQL" possibly make it not able to precompile, because the error occurs right before deprecation warning for MySQL is supposed to occur
module Essentials

using DataFrames, DataStructures, Dierckx, Ipopt, JLD, JSON, JuMP, MySQL, NLopt # In addition, "HttpServer" for "juliaserver.jl"


# Assumptions
# (1) Integers: channel


# possible errors
# (1) in Julia 0.4.6, `maximum`, `minimum` and `extrema` raises `ArgumentError` over empty collection, while R returns `-Inf` for `max` and `Inf` for `min` over empty collection.


# to change from "ct" to "cq": `min_ct` in "dispatch.jl".




# `ModT_fc`. Need to be defined before "amp.jl" is `include`d, due to the usage of `ModT_fc` in function signature.

# ref:
# http://docs.julialang.org/en/stable/manual/types/#value-types
# https://discourse.julialang.org/t/avoid-repeating-the-same-using-line-for-enclosed-modules/2549/7

# relevant variable in "amp.jl": ``

abstract Dfc # different formula for each cycle
immutable MAK2 <: Dfc end
immutable MAKERGAUL <: Dfc end

const dfc_dict = OrderedDict("MAK2"=>MAK2, "MAKERGAUL"=>MAKERGAUL) # calling `process_amp` with `dfc=QpcrAnalysis.Essentials.MAK2()` raised error `TypeError: typeassert: expected QpcrAnalysis.Essentials.Dfc, got QpcrAnalysis.Essentials.MAK2`




# include files

const MODULE_NAME = "Essentials"

const ANALYZE_DICT = OrderedDict{AbstractString,Function}()

const LOAD_FROM_DIR = LOAD_PATH[find(LOAD_PATH) do path_
    isfile("$path_/$MODULE_NAME/$MODULE_NAME.jl")
end][1] # slice by boolean vector returned a one-element vector. Assumption: LOAD_PATH is global

const MODULE_DIR = joinpath(LOAD_FROM_DIR, MODULE_NAME)

for (root, dirs, fns) in walkdir(MODULE_DIR)

    fn_jls_to_include = fns[find(fns) do fn
        fn != "$MODULE_NAME.jl" && endswith(fn, ".jl")
    end]

    for fn_jl in fn_jls_to_include
        include(joinpath(MODULE_DIR, root, fn_jl))
    end

    fn_k_dict_vec = fns[
        find(fns) do fn
            startswith(fn, "k_dict_")
        end
    ]
    if length(fn_k_dict_vec) > 0
        const K_DICT = load(joinpath(MODULE_DIR, root, fn_k_dict_vec[1]))
    end

end # for (root ...


end # module Basics
