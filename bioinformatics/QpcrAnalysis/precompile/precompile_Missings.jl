function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(Missings.ismissing), DataArrays.DataArray{Float64, 1}, Int64})
end
