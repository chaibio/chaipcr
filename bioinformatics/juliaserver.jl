## juliaserver.jl
#
## sets up server to listen on channel 8081
#
## in future it might be preferable to migrate to HTTP.jl
## which has more features than HttpServer.jl and is
## under active development.
## (Tom Price, Dec 2018)

import HttpServer: HttpHandler, Server, run
import QpcrAnalysis
import MicroLogging: @error


## Functions like this will be defined as `req2res` in module "QpcrAnalysis"
# function amplification(experiment_id, request_body)
#   ## return true, json response
#   ## or return false, json error response
#   return true, request_body
# end

http = HttpServer.HttpHandler() do req ::HttpServer.Request, res ::HttpServer.Response
    log_info("at HttpHandler() with method $req.resource")

    const code0 =
        if ismatch(r"^/experiments/", req.resource)
            const nodes = split(req.resource, '/')
            if (length(nodes) >= 4)
                const experiment_id = parse(Int, nodes[3])
                const action = String(nodes[4])
                const request_body = String(req.data)
                log_debug("request body is\n$request_body")

                ## calls to http://localhost/experiments/0/ will activate a slow test mode
                if (experiment_id == 0)
                    const kwargs = Dict{Symbol,Bool}(
                        :verify  => true)
                else
                    const kwargs = Dict{Symbol,Bool}()
                end

                const success, response_body = QpcrAnalysis.dispatch(action, request_body; kwargs...)
                log_debug("success is $success")
                log_debug("response body is\n$response_body")

                ## return code
                (success) ? 200 : 500
            else
                0
            end
        else
            0
        end

    const code =
        if code0 == 0
            const err_msg = "method \"$req.resource\" not found"
            response_body = Dict(:error => err_msg)
            MicroLogging.@error(string(now()) * " $err_msg")
            ## return code
            404
        else
            code0
        end

    log_debug("returning from HttpHandler()")
    res = HttpServer.Response(response_body)
    res.status = code
    log_debug("result is\n$res")
    return res
end

server = HttpServer.Server(http)
HttpServer.run(server, 8081)
