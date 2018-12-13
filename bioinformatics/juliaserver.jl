# juliaserver.jl
#
# sets up server to listen on channel 8081
#
# in future it might be preferable to migrate to HTTP.jl
# which has more features than HttpServer.jl and is
# under active development.
# (Tom Price, Dec 2018)

import HttpServer, QpcrAnalysis


# Functions like this will be defined as `req2res` in module "QpcrAnalysis"
# function amplification(experiment_id, request_body)
# 	# return true, json response
# 	# or return false, json error response
# 	return true, request_body
# end

http = HttpHandler() do req ::HttpServer.Request, res ::HttpServer.Response

	code = 0
	if ismatch(r"^/experiments/", req.resource)
		nodes = split(req.resource, '/')
		if (length(nodes) >= 4)
			experiment_id = parse(Int, nodes[3])
			action = String(nodes[4])
			request_body = String(req.data)
			success, response_body = QpcrAnalysis.dispatch(action, request_body)
			code = (success) ? 200 : 500
		end
	end

	if code == 0
		code = 404
		response_body = Dict(:error => "method \"$req.resource\" not found")
	end

	res = HttpServer.Response(response_body)
	res.status = code
	return res
end

server = HttpServer.Server(http)
HttpServer.run(server, 8081)
