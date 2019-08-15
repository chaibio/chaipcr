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

import HTTP: serve, Request, Response, HandlerFunction, mkheaders, URI, URIs.splitpath
import JSON.json
import Memento: getlogger, gethandlers, debug, info, error
import FunctionalData.@p
import QpcrAnalysis


function get_response(req ::HTTP.Request)
    info(logger, "Julia webserver has received $(req.method) request to http://127.0.0.1:8081$(req.target)")
    debug(logger, "at get_response() with target $(req.target)")
    const code =
        if req.method == "GET" ## per HTTP RFC, this is actually a POST request because it contains body data
            const nodes = HTTP.URIs.splitpath(req.target)
            if length(nodes) >= 3
                const experiment_id = nodes[2]
                const action        = nodes[3]
                const request_body  = String(req.body)
                debug(logger, "request body: " * request_body)

                ## calls to http://localhost/experiments/0/
                ## will activate a slow test mode
                const kwargs = Dict{Symbol,Bool}(
                    (experiment_id == "0") ? :verify => true : ())

                ## dispatch request to Julia engine
                debug(logger, "calling QpcrAnalysis.dispatch() from get_response()")
                const success, response_body =
                    QpcrAnalysis.dispatch(action, request_body; kwargs...)
                debug(logger, "at get_response() receiving results from QpcrAnalysis.dispatch()")
                ## code =
                (success) ? 200 : 500
            else ## length(nodes) < 3
                404
            end
        else ## not GET
            404
        end
    (code == 404) && (const response_body = JSON.json(Dict(:error => "not found")))
    #
    debug(logger, "returning from get_response()")
    debug(logger, "status: $code")
    debug(logger, "response body: $response_body")
    return HTTP.Response(code, RESPONSE_HEADERS; body=response_body)
end ## get_response

## set up logging
logger = getlogger("QpcrAnalysis")
logIO = (@p gethandlers logger|values|collect|getindex _ 1|getfield _ :io)
debug(logger, "logfile " * getfield(logIO, :filepath))

## headers
const RESPONSE_HEADERS = HTTP.mkheaders([
    "Server"           => "Julia/$VERSION",
    "Content-Type"     => "text/html; charset=utf-8",
    "Content-Language" => "en",
    "Date"             => Dates.format(now(Dates.UTC), Dates.RFC1123Format)])

## set up REST endpoints to dispatch to service functions
HTTP.serve(
    host    = ip"127.0.0.1",
    port    = 8081,
    handler = HandlerFunction(get_response),
    logger  = logIO,
    verbose = true) ## logs server activity
info(logger, "Webserver listening on: http://127.0.0.1:8081")


#
