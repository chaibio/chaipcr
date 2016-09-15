
__precompile__()
module QpcrAnalysis

include("Essentials/Essentials.jl") # does the same thing as `using Basics` except not exportng any names

const ANALYZE_DICT = Essentials.ANALYZE_DICT

analyze_dir = joinpath(Essentials.LOAD_FROM_DIR, "analyze_modules")
analyze_fns = readdir(analyze_dir)
analyze_fns_to_include = map(analyze_fns) do analyze_fn
    joinpath(analyze_dir, analyze_fn)
end
# guids = map(analyze_fns) do analyze_fn
#     splitext(analyze_fn)[1]
# end

for fn in analyze_fns_to_include
    include(fn)
end # Assumption: all the items are includeable .jl files

defined_symbs = names(current_module(), true)
for symb in defined_symbs
    var = @eval $symb
    if isa(var, Module) && isdefined(var, :analyze)
        guid = string(symb)
        if guid in keys(ANALYZE_DICT)
            error("GUID \"$guid\" has been used by an `analyze` function defined in the standard module `Basics`. Please rename your `analyze` module to something else.")
        else
            ANALYZE_DICT[guid] = var.analyze
        end # if guid
    end # if isa
end # for


end # QpcrAnalysis
