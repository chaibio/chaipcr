#include "pocoincludes.h"

#include "statushandler.h"

using namespace Poco::Net;

////////////////////////////////////////////////////////////////////////////////
// Class StatusHandler
StatusHandler::StatusHandler(HTTPResponse::HTTPStatus status)
{
    setStatus(status);
}

StatusHandler::~StatusHandler()
{

}

void StatusHandler::handleRequest(HTTPServerRequest &, HTTPServerResponse &response)
{
    response.setStatus(getStatus());
}
