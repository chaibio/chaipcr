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
import QpcrAnalysis

## set up logging
logger = getlogger("QpcrAnalysis")
debug(logger, "******************** Julia Server is started ********************")

## headers
const RESPONSE_HEADERS = HTTP.mkheaders([
    "Server"           => "Julia/$VERSION",
    "Content-Type"     => "text/html; charset=utf-8",
    "Content-Language" => "en",
    "Date"             => Dates.format(now(Dates.UTC), Dates.RFC1123Format)])


global julia_running = false

## set up REST endpoints to dispatch to service functions
HTTP.listen() do req::HTTP.Request
	global julia_running

	if julia_running == true
		# Julia can process only one request at a time
		warn(logger, "Julia is still processing an existing request, reject new request with 503")
		return HTTP.Response(503, RESPONSE_HEADERS; body=JSON.json(Dict(:error => "Julia is busy")))
	end

	julia_running = true

    info(logger, "Julia webserver has received $(req.method) request to http://127.0.0.1:8081$(req.target)")

    code =
        if req.method == "GET" ## per HTTP RFC, this is actually a POST request because it contains body data
            const nodes = HTTP.URIs.splitpath(req.target)
            if length(nodes) >= 3
                experiment_id = nodes[2]
                action        = nodes[3]
                request_body  = String(req.body)

                ## calls to http://localhost/experiments/0/
                ## will activate a slow test mode
                kwargs = Dict{Symbol,Bool}(
                    (experiment_id == "0") ? :verify => true : ())

                ## dispatch request to Julia engine
                debug(logger, "Calling QpcrAnalysis.dispatch()")
                success, response_body =
                    QpcrAnalysis.dispatch(action, request_body; kwargs...)
                debug(logger, "Returning from QpcrAnalysis.dispatch(): success=$success")
                code = (success) ? 200 : 500
            else ## length(nodes) < 3
                404
            end
        else ## not GET
            404
        end
    (code == 404) && (response_body = JSON.json(Dict(:error => "not found")))

    debug(logger, "Julia finish processing: status: $code, response body: $response_body")

	julia_running = false

    return HTTP.Response(code, RESPONSE_HEADERS; body=response_body)

end ## HTTP.serve

info(logger, "Webserver listening on: http://127.0.0.1:8081")


#
