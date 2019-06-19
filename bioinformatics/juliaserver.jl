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
using MicroLogger


## Functions like this will be defined as `req2res` in module "QpcrAnalysis"
# function amplification(experiment_id, request_body)
#   ## return true, json response
#   ## or return false, json error response
#   return true, request_body
# end

http = HttpServer.HttpHandler() do req ::HttpServer.Request, res ::HttpServer.Response
    @info(string(now()) * " at HttpHandler() with method $req.resource\n")

    const code0 =
        if ismatch(r"^/experiments/", req.resource)
            const nodes = split(req.resource, '/')
            if (length(nodes) >= 4)
                const experiment_id = parse(Int, nodes[3])
                const action = String(nodes[4])
                const request_body = String(req.data)
                @debug(string(now()) * " request body is\n$request_body\n")

                ## calls to http://localhost/experiments/0/ will activate a verbose test mode
                if (experiment_id == 0)
                    const kwargs = Dict{Symbol,Bool}(
                        :verbose => true,
                        :verify  => true)
                else
                    const kwargs = Dict{Symbol,Bool}()
                end

                const success, response_body = QpcrAnalysis.dispatch(action, request_body; kwargs...)
                @debug(string(now()) * " success is $success\n")
                @debug(string(now()) * " response body is\n$response_body\n")

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
            @error(string(now()) * " $err_msg\n")
            ## return code
            404
        else
            code0
        end

    @debug(string(now()) * " returning from HttpHandler()\n")
    res = HttpServer.Response(response_body)
    res.status = code
    @debug(string(now()) * " result is\n$res\n")
    return res
end

server = HttpServer.Server(http)
HttpServer.run(server, 8081)
