function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(Combinatorics.combinations), Array{Int64, 1}, Int64})
end
