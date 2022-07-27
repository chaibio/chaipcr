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

#include "jsonhandler.h"
#include "logger.h"

#include <iostream>

#include <boost/property_tree/json_parser.hpp>

JsonHandler::JsonHandler()
{

}

JsonHandler::JsonHandler(Poco::Net::HTTPResponse::HTTPStatus status, const std::string &errorMessage)
    :DataHandler(status)
{
    setErrorString(errorMessage);
}

void JsonHandler::processRequest(Poco::Net::HTTPServerRequest &request)
{
    APP_LOGGER << "void JsonHandler::processRequest " << std::endl;
    boost::property_tree::ptree requestPt;

    if (getStatus() != Poco::Net::HTTPResponse::HTTP_OK)
    {
        JsonHandler::processData(requestPt, _responsePt);
        return;
    }

    try
    {
        if (request.getContentLength() > 0)
            boost::property_tree::read_json(request.stream(), requestPt);

        processData(requestPt, _responsePt);
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "JsonHandler::processRequest - error: " << ex.what() << std::endl;

        _responsePt.clear();

        setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
        setErrorString(ex.what());
        JsonHandler::processData(requestPt, _responsePt);
    }
    catch (...)
    {
        APP_LOGGER << "JsonHandler::processRequest - unknown error" << std::endl;

        _responsePt.clear();

        setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
        setErrorString("Unknown error");
        JsonHandler::processData(requestPt, _responsePt);
    }
}

void JsonHandler::processResponse(Poco::Net::HTTPServerResponse &response)
{
    if (!_responsePt.empty())
    {
        response.setContentType("text/json");

        std::ostream &responseStream = response.send();
        write_json(responseStream, _responsePt);
        responseStream.flush();
    }
    else
        response.send().flush();
}

void JsonHandler::processData(const boost::property_tree::ptree &/*requestPt*/, boost::property_tree::ptree &responsePt)
{
    APP_LOGGER << "JsonHandler::processData " << std::endl;

    if (getStatus() == Poco::Net::HTTPResponse::HTTP_OK)
        responsePt.put("status.status", true);
    else
    {
        responsePt.put("status.status", false);
        responsePt.put("status.error", getErrorString());
    }
}
