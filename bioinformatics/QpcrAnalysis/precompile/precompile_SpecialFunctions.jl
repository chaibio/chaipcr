function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(SpecialFunctions._besselj), Float64, Base.Complex{Float64}, Int32})
    precompile(Tuple{typeof(SpecialFunctions._biry), Base.Complex{Float64}, Int32, Int32})
    precompile(Tuple{typeof(SpecialFunctions._bessely), Float64, Base.Complex{Float64}, Int32})
    precompile(Tuple{typeof(SpecialFunctions._airy), Base.Complex{Float64}, Int32, Int32})
    precompile(Tuple{typeof(SpecialFunctions.pow_oftype), Float64, Float64, Float64})
    precompile(Tuple{typeof(SpecialFunctions.cotderiv), Int64, Float64})
end
