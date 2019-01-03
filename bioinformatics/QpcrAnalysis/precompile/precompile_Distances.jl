function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(Distances.evaluate), Distances.SqEuclidean, Array{Float64, 1}, Base.SubArray{Float64, 1, Array{Float64, 2}, Tuple{Base.Slice{Base.OneTo{Int64}}, Int64}, true}})
    precompile(Tuple{typeof(Distances.colwise!), Array{Float64, 1}, Distances.SqEuclidean, Array{Float64, 1}, Array{Float64, 2}})
    precompile(Tuple{typeof(Distances.pairwise!), Array{Float64, 2}, Distances.SqEuclidean, Array{Float64, 2}, Array{Float64, 2}})
end
