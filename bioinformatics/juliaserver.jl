# juliaserver.jl
#
# sets up server on channel 8081
#
# in future it might be preferable to migrate to HTTP.jl
# which has more features than HttpServer.jl and is
# under active development.
# (Tom Price, Dec 2018)

using HttpServer, QpcrAnalysis


# Functions like this will be defined as `req2res` in module "QpcrAnalysis"
# function amplification(experiment_id, request_body)
# 	# return true, json response
# 	# or return false, json error response
# 	return true, request_body
# end

http = HttpHandler() do req::Request, res::Response
	code = 0
	if ismatch(r"^/experiments/", req.resource)
		nodes = split(req.resource, '/')
		experiment_id = parse(Int, nodes[3])
		action = String(nodes[4])
		request_body = String(req.data)
		success, response_body = QpcrAnalysis.dispatch(action, request_body)
		code = (success) ? 200 : 500
	end

	if code == 0
		code = 404
		response_body = string("{'error': 'method \"", req.resource, "\" not found'}")
	end

	res = Response(response_body)
	res.status = code
	return res
end

server = Server(http)
run(server, 8081)
