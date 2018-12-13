
function server_tests()

    # Notes

    # The following are not implemented yet:
    # ensure_ci in shared.jl
    # get_mysql_data_well in shared.jl
    # get_k in deconv.jl <- deconV in deconv.jl <- dcv_aw in calib.jl
    #                    <- analyze_customized/optical_cal.jl

    # startup script
    #
    # ;cd ~/chaipcr/bioinformatics/QpcrAnalysis
    # ;sudo mount -t vboxsf shared /mnt/share
    # 
    #
    push!(LOAD_PATH,pwd())
    LOAD_FROM_DIR=pwd()
    #using QpcrAnalysis

    import DataStructures.OrderedDict
    import JuMP: @variable, @objective, @NLobjective, @constraint,
        Model, solve, getvalue, getobjectivevalue
    import Ipopt.IpoptSolver
    import DataArrays.DataArray
    import Clustering: ClusteringResult, kmeans!, kmedoids!, silhouettes
    import Combinatorics.combinations
    import JLD.load
    import JSON
    include("amp_models/sfc_models.jl")
    include("amp_models/types_for_amp_models.jl")
    include("types_for_allelic_discrimination.jl")
    include("allelic_discrimination.jl") # gives error
    include("/mnt/share/shared.jl")
    include("/mnt/share/deconv.jl")
    include("/mnt/share/action_types.jl")
    include("/mnt/share/amp.jl")
    include("allelic_discrimination.jl")
    calib_info_AIR = -99
    const k = JLD.load("$LOAD_FROM_DIR/k4dcv_ip84_calib79n80n81_vec.jld")["k4dcv"]
    const K4DCV = K4Deconv(k.k_s, k.k_inv_vec, k.inv_note)




    # amplification tests

    include("/mnt/share/action_types.jl")
    include("/mnt/share/verify_request.jl")
    include("/mnt/share/verify_response.jl")
    include("/mnt/share/dispatch.jl")
    include("/mnt/share/amp.jl")
    include("/mnt/share/calib.jl")
    include("/mnt/share/adj_w2wvaf.jl")
    include("/mnt/share/deconv.jl")

    # single channel amplification test
    request = JSON.parsefile("/mnt/share/test_1ch_amp_169.json"; dicttype=OrderedDict)
    (success, response_body) = dispatch("amplification",String(JSON.json(request)))
    success

    # dual channel amplification tests
    request = JSON.parsefile("/mnt/share/xh-amp1.json"; dicttype=OrderedDict)
    (success, response_body) = dispatch("amplification",String(JSON.json(request)))
    success

    # debug version
    request = JSON.parsefile("/mnt/share/xh-amp2.json"; dicttype=OrderedDict)
    action_t=ActionType_DICT["amplification"]()
    verify_request(action_t,request)
    response = act(action_t,request)
    verify_response(action_t,JSON.parse(JSON.json(response),dicttype=OrderedDict))


 
    # meltcurve tests

    include("supsmu.jl")
    include("/mnt/share/action_types.jl")
    include("/mnt/share/verify_request.jl")
    include("/mnt/share/verify_response.jl")
    include("/mnt/share/dispatch.jl")
    include("/mnt/share/calib.jl")
    include("/mnt/share/adj_w2wvaf.jl")
    include("/mnt/share/meltcrv.jl")

    # single channel melting curve test
    request = JSON.parsefile("/mnt/share/test_1ch_mc_170.json"; dicttype=OrderedDict)
    result = dispatch("meltcurve",String(JSON.json(request)))
    (success, response_body) = JSON.parse(result,dicttype=OrderedDict)
    success

    # debug version
    request = JSON.parsefile("/mnt/share/test_1ch_mc_170.json"; dicttype=OrderedDict)
    action_t=ActionType_DICT["meltcurve"]()
    verify_request(action_t,request)
    response = act(action_t,request)
    verify_response(action_t,JSON.parse(JSON.json(response),dicttype=OrderedDict))

    # dual channel melting curve test




    # optical tests

    include("/mnt/share/action_types.jl")
    include("/mnt/share/verify_request.jl")
    include("/mnt/share/verify_response.jl")
    include("/mnt/share/dispatch.jl")
    include("/mnt/share/optical_test_single_channel.jl")

    # single channel optical test
    request = JSON.parsefile("/mnt/share/test_1ch_ot_161.json"; dicttype=OrderedDict)
    result = dispatch("analyze",String(JSON.json(request)))
    success, response_body) = JSON.parse(result[2],dicttype=OrderedDict)
    success
    
    # debug version
    request = JSON.parsefile("/mnt/share/test_1ch_ot_161.json"; dicttype=OrderedDict)
    action_t=ActionType_DICT["optical_test_single_channel"]()
    verify_request(action_t,request)
    response = act(action_t,request)
    verify_response(action_t,JSON.parse(JSON.json(response),dicttype=OrderedDict))




    # test Julia server

    # shell script to start julia server
    # julia -e 'push!(LOAD_PATH,"/home/vagrant/chaipcr/bioinformatics/QpcrAnalysis/");include("/home/vagrant/chaipcr/bioinformatics/QpcrAnalysis/QpcrAnalysis.jl");include("/home/vagrant/chaipcr/bioinformatics/juliaserver.jl")' &

    include("../juliaserver.jl")

    # call using Julia object
    # run(`curl \
    #     --header "Content-Type: application/json" \
    #     --request "GET" \
    #     --data $(JSON.json(request)) \
    #     http://localhost:8081/experiments/250/amplification`)

    # system call\
    # cd bioinformatics/QpcrAnalysis
    # curl \
    #     --header "Content-Type: application/json" \
    #     --data @../test/test_1ch_amp.json \
    #     http://localhost:8081/experiments/250/amplification

    # system call\
    # cd bioinformatics/QpcrAnalysis
    # curl \
    #     --header "Content-Type: application/json" \
    #     --data @../test/test_1ch_meltcurve.json \
    #     http://localhost:8081/experiments/170/meltcurve

end




