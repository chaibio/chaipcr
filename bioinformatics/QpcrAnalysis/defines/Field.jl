#===============================================================================

    Field.jl

    container for data associated with a field in a macro-generated struct
    and associated methods for use in the struct-generating macro

    Author: Tom Price
    Date:   July 2019

===============================================================================#



#===============================================================================
    struct >>
===============================================================================#

struct Field
    name        ::Symbol
    typ         ::Type{T} where {T}
    default     ::Any
end



#===============================================================================
    constructor >>
===============================================================================#

Field(name ::Symbol, typ ::Type{T} where {T}) =
    Field(name, typ, nothing)



#===============================================================================
    methods >>
===============================================================================#

   var_arg(f ::Field) = Expr(:(::), f.name, f.typ)

    kw_arg(f ::Field) = Expr(:kw, var_arg(f), f.default)

no_default(f ::Field) = f.default === nothing

subset_schema(schema ::AbstractArray{Field}, x ::AbstractArray{Symbol}) =
    schema[indexin(x, schema |> mold(field(:name)))]

