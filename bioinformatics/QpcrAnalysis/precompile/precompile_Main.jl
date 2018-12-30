function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(Main.test_dispatch)})
    precompile(Tuple{getfield(Main, Symbol("##generate_tests#7")), Bool, Bool, typeof(identity)})
end
