function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(HDF5.blosc_set_local), Int32, Int32, Int32})
    precompile(Tuple{typeof(HDF5.h5t_get_member_offset), Int32, Int64})
    precompile(Tuple{typeof(HDF5.blosc_filter), UInt32, UInt64, Ptr{UInt32}, UInt64, Ptr{UInt64}, Ptr{Ptr{Void}}})
    precompile(Tuple{typeof(HDF5.h5t_get_member_class), Int32, Int64})
    precompile(Tuple{typeof(HDF5.register_blosc)})
    precompile(Tuple{typeof(HDF5.h5p_set_layout), Int32, Int64})
    precompile(Tuple{typeof(HDF5.p_create), Int32, Bool})
    precompile(Tuple{typeof(HDF5.h5p_set_char_encoding), Int32, Int64})
    precompile(Tuple{typeof(HDF5.h5p_set_create_intermediate_group), Int32, Int64})
    precompile(Tuple{typeof(HDF5.__init__)})
end
