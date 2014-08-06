#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/URI.h>

#include "testcontrolhandler.h"
#include "statushandler.h"
#include "controlhandler.h"

#include "qpcrrequesthandlerfactory.h"

using namespace std;
using namespace Poco;
using namespace Poco::Net;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRRequestHandlerFactory
HTTPRequestHandler* QPCRRequestHandlerFactory::createRequestHandler(const HTTPServerRequest &request)
{
    vector<string> requestPath;
    URI(request.getURI()).getPathSegments(requestPath);

    if (!requestPath.empty())
    {
        if (request.getMethod() == "GET")
        {
            if (requestPath.at(0) == "status")
                return new StatusHandler();
        }
        else if (request.getMethod() == "PUT")
        {
            if (requestPath.at(0) == "testControl")
                return new TestControlHandler();
        }
        else if (request.getMethod() == "POST")
        {
            if (requestPath.at(0) == "control")
            {
                if (requestPath.at(1) == "start")
                    return new ControlHandler(ControlHandler::StartExperiment);
                else if (requestPath.at(1) == "stop")
                    return new ControlHandler(ControlHandler::StopExperiment);
            }
        }
    }

    return new HTTPStatusHandler(HTTPResponse::HTTP_NOT_FOUND);
}
