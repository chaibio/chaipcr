## juliaserver.jl
#
## sets up server to listen on channel 8081
#
## in future it might be preferable to migrate to HTTP.jl
## which has more features than HttpServer.jl and is
## under active development.
## (Tom Price, Dec 2018)

## usage:
## cd("QpcrAnalysis")
## julia -e 'push!(LOAD_PATH,pwd()); include("../juliaserver.jl")'

import HTTP: listen, setstatus, setheader, URIs.splitpath
import JSON: json
import QpcrAnalysis
import Memento: getlogger, gethandlers, debug, info, error
import FunctionalData.@p


## set up logging
logger = getlogger("QpcrAnalysis")
debug(logger, "logfile " * (@p gethandlers logger|values|collect|getindex _ 1|getfield _ :io|getfield _ :filepath))

HTTP.listen("127.0.0.1", 8081) do http
    info(logger, "at HttpHandler() with target $(http.message.target)")
    const code0 = 0 |
        (ismatch(r"^/experiments/", http.message.target) &&
            begin
                const nodes = HTTP.URIs.splitpath(http.message.target)
                (length(nodes) >= 3 &&
                    begin
                        const experiment_id = parse(Int, nodes[2])
                        const action = String(nodes[3])
                        const request_body = read(http, String)
                        debug(logger, "request body:$request_body")

                        ## calls to http://localhost/experiments/0/
                        ## will activate a slow test mode
                        const kwargs = Dict{Symbol,Bool}(
                            (experiment_id == 0) ? :verify => true : ())

                        ## dispatch request to Julia engine
                        const success, response_body =
                            QpcrAnalysis.dispatch(action, request_body; kwargs...)
                        ## return value
                        (success) ? 200 : 500
                    end) ## length(nodes) >= 3
            end) ## ismatch(r"^/experiments/"

    const code = code0 |
        (code0 == 0 &&
            begin
                const err_msg = "no method for target \"$(http.message.target)\""
                response_body = JSON.json(Dict(:error => err_msg))
                ## return value
                404
            end)

    debug(logger, "returning from HttpHandler()")
    debug(logger, "status: $code")
    debug(logger, "response body: $response_body")
    HTTP.setstatus(http, code)
    HTTP.setheader(http, "Server"           => "Julia/$VERSION")
    HTTP.setheader(http, "Content-Type"     => "text/html; charset=utf-8")
    HTTP.setheader(http, "Content-Language" => "en")
    HTTP.setheader(http, "Date"             => Dates.format(now(Dates.UTC), Dates.RFC1123Format))
    write(http, response_body)
end

info(logger, "Listening on: 127.0.0.1:8081")


#
