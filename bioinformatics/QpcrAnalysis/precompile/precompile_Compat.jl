function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(Compat.Sys.__init__)})
    precompile(Tuple{typeof(Compat.__init__)})
end
