//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/URI.h>
#include <Poco/SHA1Engine.h>

#include <utility>
#include <boost/tokenizer.hpp>
#include <boost/lexical_cast.hpp>

#include "httpcodehandler.h"
#include "testcontrolhandler.h"
#include "statushandler.h"
#include "controlhandler.h"
#include "settingshandler.h"
#include "networkmanagerhandler.h"
#include "updatehandler.h"
#include "updateuploadhandler.h"
#include "changeexperimenthandler.h"

#include "qpcrrequesthandlerfactory.h"
#include "qpcrapplication.h"
#include "logger.h"

using namespace std;
using namespace Poco;
using namespace Poco::Net;

const boost::chrono::hours USER_CACHE_DURATION(1);

////////////////////////////////////////////////////////////////////////////////
// Class QPCRRequestHandlerFactory
HTTPRequestHandler* QPCRRequestHandlerFactory::createRequestHandler(const HTTPServerRequest &request)
{
    std::cout << "createRequestHandler " << std::endl;

    try
    {
        vector<string> requestPath;
        URI uri(request.getURI());

        uri.getPathSegments(requestPath);
        APP_LOGGER << "createRequestHandler " << request.getURI() << std::endl;

        if (!requestPath.empty())
        {
            APP_LOGGER << "createRequestHandler " << request.getMethod() << ": " << requestPath.size() << " ";
            for(auto a:requestPath)
                APP_LOGGER << a << "|";
            APP_LOGGER << std::endl;
            
            if (request.getMethod() == "GET")
            {
                if (requestPath.size() >= 2 && requestPath.at(0) == "network")
                {
                    if (requestPath.size() == 2)
                        return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::GetStat);
                    else if (requestPath.at(2) == "scan")
                        return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::WifiScan);
                }
            }
            else if (request.getMethod() == "PUT")
            {
                if (requestPath.size() == 2 && requestPath.at(0) == "network")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::SetSettings);
            }
            else if (request.getMethod() == "POST" && requestPath.size() == 3)
            {
                if (requestPath.at(2) == "connect")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::WifiConnect);
                else if (requestPath.at(2) == "disconnect")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::WifiDisconnect);
                else if (requestPath.at(2) == "hotspotselect")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::HotspotSelect);
                else if (requestPath.at(2) == "wifiselect")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::WifiSelect);
                else if (requestPath.at(2) == "hotspotactivate" || requestPath.at(2) == "create_hotspot")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::HotspotActivate);
                else if (requestPath.at(2) == "hotspotdeactivate")
                    return new NetworkManagerHandler(requestPath.at(1), NetworkManagerHandler::HotspotDeactivate);
            }
            else if (request.getMethod() == "OPTIONS")
                return new HTTPCodeHandler(HTTPResponse::HTTP_OK);

            if (checkUserAuthorization(request))
            {
                if (request.getMethod() == "GET")
                {
                    if (requestPath.at(0) == "status")
                        return new StatusHandler();
                }
                else if (request.getMethod() == "PUT")
                {
                    if (requestPath.at(0) == "test_control")
                        return new TestControlHandler(TestControlHandler::MachineSettings);
                    else if (requestPath.at(0) == "settings")
                        return new SettingsHandler();
                    else if (requestPath.at(0) == "stages")
                    {
                        if (uri.getHost() == "localhost" || uri.getHost() == "127.0.0.1")
                            return new ChangeExperimentHandler(ChangeExperimentHandler::StageChange, boost::lexical_cast<int>(requestPath.at(1)));
                        else
                            return new JsonHandler(HTTPResponse::HTTP_UNAUTHORIZED, "Access denied");
                    }
                }
                else if (request.getMethod() == "POST")
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
                        else if (requestPath.at(0) == "device")
                        {
                            if (requestPath.at(1) == "check_for_updates")
                                return new UpdateHandler(UpdateHandler::CheckUpdate);
                            else if (requestPath.at(1) == "update_software")
                                return new UpdateHandler(UpdateHandler::Update);
                            else if (requestPath.at(1) == "upload_software_update")
                                return new UpdateUploadHandler();
                        }
                    }
                    else if (requestPath.size() == 3)
                    {
                        if (requestPath.at(0) == "test" && requestPath.at(1) == "data_logger")
                        {
                            if (requestPath.at(2) == "start")
                                return new TestControlHandler(TestControlHandler::StartADCLogger);
                            else if (requestPath.at(2) == "stop")
                                return new TestControlHandler(TestControlHandler::StopADCLogger);
                            else if (requestPath.at(2) == "trigger")
                                return new TestControlHandler(TestControlHandler::TriggerADCLogger);
                        }
                    }
                }
            }
            else
                return new JsonHandler(HTTPResponse::HTTP_UNAUTHORIZED, "You must be logged in");
        }

        return new HTTPCodeHandler(HTTPResponse::HTTP_NOT_FOUND);
    }
    catch (const std::exception &ex)
    {
        return new JsonHandler(HTTPResponse::HTTP_INTERNAL_SERVER_ERROR, std::string("Exception occured: ") + ex.what());
    }
    catch (...)
    {
        return new JsonHandler(HTTPResponse::HTTP_INTERNAL_SERVER_ERROR, "Unknown exception occured");
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
        id = qpcrApp.getUserId(token);

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
        if ((boost::chrono::steady_clock::now() - it->second.cacheTime) < USER_CACHE_DURATION)
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
