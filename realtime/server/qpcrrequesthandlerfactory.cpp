#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/URI.h>

#include "httpcodehandler.h"
#include "testcontrolhandler.h"
#include "statushandler.h"
#include "controlhandler.h"
#include "settingshandler.h"
#include "logdatahandler.h"

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
            else if (requestPath.at(0) == "settings")
                return new SettingsHandler();
            else if (requestPath.at(0) == "logData")
                return new LogDataHandler();
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

    return new HTTPCodeHandler(HTTPResponse::HTTP_NOT_FOUND);
}
