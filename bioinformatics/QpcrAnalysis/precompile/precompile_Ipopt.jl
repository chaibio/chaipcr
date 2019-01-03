function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(Ipopt.eval_jac_g_wrapper), Int32, Ptr{Float64}, Int32, Int32, Int32, Ptr{Int32}, Ptr{Int32}, Ptr{Float64}, Ptr{Void}})
    precompile(Tuple{typeof(Ipopt.eval_h_wrapper), Int32, Ptr{Float64}, Int32, Float64, Int32, Ptr{Float64}, Int32, Int32, Ptr{Int32}, Ptr{Int32}, Ptr{Float64}, Ptr{Void}})
    precompile(Tuple{typeof(Ipopt.eval_f_wrapper), Int32, Ptr{Float64}, Int32, Ptr{Float64}, Ptr{Void}})
    precompile(Tuple{typeof(Ipopt.eval_grad_f_wrapper), Int32, Ptr{Float64}, Int32, Ptr{Float64}, Ptr{Void}})
    precompile(Tuple{typeof(Ipopt.eval_g_wrapper), Int32, Ptr{Float64}, Int32, Int32, Ptr{Float64}, Ptr{Void}})
    precompile(Tuple{typeof(Ipopt.addOption), Ipopt.IpoptProblem, String, String})
    precompile(Tuple{typeof(Ipopt.solveProblem), Ipopt.IpoptProblem})
    precompile(Tuple{typeof(Ipopt.createProblem), Int64, Array{Float64, 1}, Array{Float64, 1}, Int64, Array{Float64, 1}, Array{Float64, 1}, Int64, Int64, getfield(Ipopt, Symbol("#eval_f_cb#4")){JuMP.NLPEvaluator}, getfield(Ipopt, Symbol("#eval_g_cb#6")){JuMP.NLPEvaluator}, getfield(Ipopt, Symbol("#eval_grad_f_cb#5")){JuMP.NLPEvaluator}, getfield(Ipopt, Symbol("#eval_jac_g_cb#7")){JuMP.NLPEvaluator}, getfield(Ipopt, Symbol("#eval_h_cb#8")){JuMP.NLPEvaluator}})
    precompile(Tuple{typeof(Ipopt.freeProblem), Ipopt.IpoptProblem})
    precompile(Tuple{typeof(Ipopt.addOption), Ipopt.IpoptProblem, String, Int64})
    precompile(Tuple{getfield(Ipopt, Symbol("##call#2#3")), Array{Any, 1}, Type{Int}})
end
