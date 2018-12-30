function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(JLD._gen_h5convert!), Int})
    precompile(Tuple{typeof(JLD.__init__)})
end
