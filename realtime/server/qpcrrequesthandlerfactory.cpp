#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/URI.h>
#include <Poco/SHA1Engine.h>

#include <utility>
#include <boost/tokenizer.hpp>

#include "httpcodehandler.h"
#include "testcontrolhandler.h"
#include "statushandler.h"
#include "controlhandler.h"
#include "settingshandler.h"
#include "logdatahandler.h"
#include "networkmanagerhandler.h"
#include "updatehandler.h"

#include "qpcrrequesthandlerfactory.h"
#include "experimentcontroller.h"

using namespace std;
using namespace Poco;
using namespace Poco::Net;

const boost::chrono::hours USER_CACHE_DURATION(1);

////////////////////////////////////////////////////////////////////////////////
// Class QPCRRequestHandlerFactory
HTTPRequestHandler* QPCRRequestHandlerFactory::createRequestHandler(const HTTPServerRequest &request)
{
    try
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
                if (requestPath.size() >= 2 && requestPath.at(0) == "network")
                {
                    if (requestPath.size() == 2)
                        return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::GetStat);
                    else if (requestPath.at(2) == "scan")
                        return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::WifiScan);
                }
            }
            else if (method == "PUT")
            {
                if (requestPath.size() == 2 && requestPath.at(0) == "network")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::SetSettings);
            }
            else if (method == "POST" && requestPath.size() == 3)
            {
                if (requestPath.at(2) == "connect")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::WifiConnect);
                else if (requestPath.at(2) == "disconnect")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::WifiDisconnect);
            }

            if (checkUserAuthorization(request))
            {
                if (method == "GET")
                {
                    if (requestPath.at(0) == "status")
                        return new StatusHandler();
                }
                else if (method == "PUT")
                {
                    if (requestPath.at(0) == "test_control")
                        return new TestControlHandler();
                    else if (requestPath.at(0) == "settings")
                        return new SettingsHandler();
                    else if (requestPath.at(0) == "log_data")
                        return new LogDataHandler();
                }
                else if (method == "POST")
                {
                    if (requestPath.size() == 2)
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
                        else if (requestPath.at(0) == "device" && requestPath.at(1) == "check_for_updates")
                            return new UpdateHandler(UpdateHandler::CheckUpdate);
                    }
                }
            }
            else
                return new JSONHandler(HTTPResponse::HTTP_UNAUTHORIZED, "You must be logged in");
        }

        return new HTTPCodeHandler(HTTPResponse::HTTP_NOT_FOUND);
    }
    catch (const std::exception &ex)
    {
        return new JSONHandler(HTTPResponse::HTTP_INTERNAL_SERVER_ERROR, std::string("Exception occured: ") + ex.what());
    }
    catch (...)
    {
        return new JSONHandler(HTTPResponse::HTTP_INTERNAL_SERVER_ERROR, "Unknown exception occured");
    }
}

bool QPCRRequestHandlerFactory::checkUserAuthorization(const HTTPServerRequest &request)
{
    std::string token;

    if (request.has("Authorization"))
    {
        token = request.get("Authorization");
        token.erase(0, 6); //Remove "Token "
    }

    if (checkUserAuthorization(token))
        return true;
    else
    {
        std::string query = URI(request.getURI()).getQuery();
        boost::tokenizer<boost::char_separator<char>> tokens(query, boost::char_separator<char>("&"));

        for (const std::string &argument: tokens)
        {
            if (argument.find("access_token=") == 0)
            {
                token = argument.substr(std::string("access_token=").size());
                break;
            }
        }
    }

    return checkUserAuthorization(token);
}

bool QPCRRequestHandlerFactory::checkUserAuthorization(string token)
{
    if (token.empty())
        return false;

    Poco::SHA1Engine engine;
    engine.update(token);

    token = Poco::SHA1Engine::digestToHex(engine.digest());

    int id = getCachedUserId(token);

    if (id != -1)
        return true;
    else
    {
        id = ExperimentController::getInstance()->getUserId(token);

        if (id != -1)
        {
            addCachedUser(token, id);
            return true;
        }
    }

    return false;
}

int QPCRRequestHandlerFactory::getCachedUserId(const string &token)
{
    std::map<std::string, CachedUser>::iterator it = _cachedUsers.find(token);

    if (it != _cachedUsers.end())
    {
        if ((boost::chrono::system_clock::now() - it->second.cacheTime) < USER_CACHE_DURATION)
            return it->second.id;
        else
            _cachedUsers.erase(it);
    }

    return -1;
}

void QPCRRequestHandlerFactory::addCachedUser(const string &token, int id)
{
    _cachedUsers.insert(std::make_pair(token, CachedUser(id)));
}
