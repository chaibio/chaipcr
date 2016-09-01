#

module Essentials

using DataFrames, DataStructures, Dierckx, Ipopt, JLD, JSON, JuMP, MySQL, NLopt # In addition, "HttpServer" for "juliaserver.jl"


# Assumptions
# (1) Integers: channel


# possible errors
# (1) in Julia 0.4.6, `maximum`, `minimum` and `extrema` raises `ArgumentError` over empty collection, while R returns `-Inf` for `max` and `Inf` for `min` over empty collection.


# to change from "ct" to "cq": `min_ct` in "dispatch.jl".




# include files

const MODULE_NAME = "Essentials"

const ANALYZE_DICT = OrderedDict{ByteString,Function}()

const LOAD_FROM_DIR = LOAD_PATH[find(LOAD_PATH) do path_
    isfile("$path_/$MODULE_NAME/$MODULE_NAME.jl")
end][1] # slice by boolean vector returned a one-element vector. Assumption: LOAD_PATH is global

const MODULE_DIR = joinpath(LOAD_FROM_DIR, MODULE_NAME)

items = readdir(MODULE_DIR)

fns_to_include = items[find(items) do item
    item != "$MODULE_NAME.jl" && endswith(item, ".jl")
end]

for fn in fns_to_include
    include(joinpath(MODULE_DIR, fn))
end

fn_k_dict = items[
    find(items) do item
        startswith(item, "k_dict_")
    end
][1]
const K_DICT = load(joinpath(MODULE_DIR, fn_k_dict))


end # module Basics
