#include "pocoincludes.h"

#include "httpstatushandler.h"

using namespace Poco::Net;

////////////////////////////////////////////////////////////////////////////////
// Class StatusHandler
HTTPStatusHandler::HTTPStatusHandler(HTTPResponse::HTTPStatus status)
{
    setStatus(status);
}

HTTPStatusHandler::~HTTPStatusHandler()
{

}

void HTTPStatusHandler::handleRequest(HTTPServerRequest &, HTTPServerResponse &response)
{
    response.setStatus(getStatus());
}
