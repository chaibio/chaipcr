#!/bin/bash
#
# test_julia_server.sh
#
# Author: Tom Price
# Date: Dec 2018
#
# test Julia server using curl

# first start up Julia on the VM, directing all output to STDERR
# it may be preferable to use these commands from within Julia REPL to examine the Julia output
julia -e 'cd("/home/vagrant/chaipcr/bioinformatics/QpcrAnalysis/");push!(LOAD_PATH,pwd());include("../test/startup.jl");include("../juliaserver.jl")' 2>&1 &

# call using Julia object
# run(`curl \
#     --header "Content-Type: application/json" \
#     --request "GET" \
#     --data $(JSON.json(request)) \
#     http://localhost:8081/experiments/250/amplification`)

while IFS=',' read -ra words; do
    if [[ ${words[0]} != '"action"' ]]; then
        action=$(echo "${words[0]}"|sed 's/^"//;s/"$//')
        for dataset in ${words[2]} ${words[3]}; do
            if [[ $dataset != '""' ]]; then
                filename=$(echo "$dataset.json"|sed 's/^"//;s/".json$/.json/')
                echo "Testing action '$action' with dataset '$filename'"
                exp_id=0 # 0 provides a verbose test mode. other values are ignored
                curl --silent \
                    --header "Content-Type: application/json" \
                    --data @$filename \
                    http://localhost:8081/experiments/$exp_id/$action > _tmp
                echo
            fi
        done
    fi
done < test_data.csv
rm _tmp


#