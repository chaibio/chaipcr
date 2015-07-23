#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/URI.h>

#include "httpcodehandler.h"
#include "testcontrolhandler.h"
#include "statushandler.h"
#include "controlhandler.h"
#include "settingshandler.h"
#include "logdatahandler.h"
#include "wirelessmanagerhandler.h"

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
        string method = request.getMethod();

        if (method == "OPTIONS" && request.has("Access-Control-Request-Method"))
            method = request.get("Access-Control-Request-Method");

        if (method == "GET")
        {
            if (requestPath.at(0) == "status")
                return new StatusHandler();
            else if (requestPath.at(0) == "wifi")
            {
                if (requestPath.at(1) == "scan")
                    return new WirelessManagerHandler(WirelessManagerHandler::Scan);
                else if (requestPath.at(1) == "status")
                    return new WirelessManagerHandler(WirelessManagerHandler::Status);
            }
        }
        else if (method == "PUT")
        {
            if (requestPath.at(0) == "testControl")
                return new TestControlHandler();
            else if (requestPath.at(0) == "settings")
                return new SettingsHandler();
            else if (requestPath.at(0) == "logData")
                return new LogDataHandler();
        }
        else if (method == "POST")
        {
            if (requestPath.at(0) == "control")
            {
                if (requestPath.at(1) == "start")
                    return new ControlHandler(ControlHandler::StartExperiment);
                else if (requestPath.at(1) == "resume")
                    return new ControlHandler(ControlHandler::ResumeExperiment);
                else if (requestPath.at(1) == "stop")
                    return new ControlHandler(ControlHandler::StopExperiment);
            }
            else if (requestPath.at(0) == "wifi")
            {
                if (requestPath.at(1) == "connect")
                    return new WirelessManagerHandler(WirelessManagerHandler::Connect);
                else if (requestPath.at(1) == "shutdown")
                    return new WirelessManagerHandler(WirelessManagerHandler::Shutdown);
            }
        }
    }

    return new HTTPCodeHandler(HTTPResponse::HTTP_NOT_FOUND);
}
