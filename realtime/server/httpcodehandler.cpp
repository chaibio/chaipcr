#include "httpcodehandler.h"

HTTPCodeHandler::HTTPCodeHandler(Poco::Net::HTTPResponse::HTTPStatus status, const std::string &reason)
{
    setStatus(status);
    setReason(reason);
}

void HTTPCodeHandler::handleRequest(Poco::Net::HTTPServerRequest &/*request*/, Poco::Net::HTTPServerResponse &response)
{
    if (reason().empty())
        response.setStatus(status());
    else
        response.setStatusAndReason(status(), reason());

    response.send().flush();
}
