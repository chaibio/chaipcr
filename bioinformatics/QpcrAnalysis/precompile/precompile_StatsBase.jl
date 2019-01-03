function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(StatsBase.sample), Base.Random.MersenneTwister, StatsBase.Weights{Float64, Float64, Array{Float64, 1}}})
    precompile(Tuple{typeof(StatsBase.sample), Base.Random.MersenneTwister, Base.UnitRange{Int64}, StatsBase.Weights{Float64, Float64, Array{Float64, 1}}})
end
