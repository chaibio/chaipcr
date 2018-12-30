function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(ForwardDiff.isconstant), ForwardDiff.Dual{4, Float64}})
    precompile(Tuple{typeof(ForwardDiff.tupexpr), typeof(identity), Int64})
end
