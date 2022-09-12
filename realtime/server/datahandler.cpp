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

#include "datahandler.h"
#include "logger.h"

#include <iostream>

#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/Net/HTTPServerResponse.h>
#include <Poco/Net/MultipartReader.h>
#include <Poco/Net/MessageHeader.h>

DataHandler::DataHandler()
    :DataHandler(Poco::Net::HTTPResponse::HTTP_OK)
{

}

DataHandler::DataHandler(Poco::Net::HTTPResponse::HTTPStatus status)
{
    setStatus(status);
}

void DataHandler::handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response)
{
    //APP_DEBUGGER << "DataHandler::handleRequest " << std::endl;

    try
    {
        processRequest(request);

        response.setStatusAndReason(getStatus(), Poco::Net::HTTPServerResponse::getReasonForStatus(getStatus()));

        //CORS
        response.add("Access-Control-Allow-Methods", "POST, PUT, OPTIONS");
        response.add("Access-Control-Allow-Origin", "*");
        response.add("Access-Control-Allow-Headers", "Content-Type");

        if (request.getMethod() == "GET")
            response.add("Cache-Control", "no-store, must-revalidateExpires: 0");

        processResponse(response);
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "DataHandler::handleRequest - " << ex.what() << std::endl;

        response.setStatusAndReason(Poco::Net::HTTPResponse::HTTP_INTERNAL_SERVER_ERROR, Poco::Net::HTTPServerResponse::getReasonForStatus(getStatus()));
        response.send().flush();
    }
    catch (...)
    {
        APP_LOGGER << "DataHandler::handleRequest - unknown error" << std::endl;

        response.setStatusAndReason(Poco::Net::HTTPResponse::HTTP_INTERNAL_SERVER_ERROR, Poco::Net::HTTPServerResponse::getReasonForStatus(getStatus()));
        response.send().flush();
    }
}

void DataHandler::processResponse(Poco::Net::HTTPServerResponse &response)
{
    //APP_DEBUGGER << "DataHandler::processResponse " << std::endl;

    response.send().flush();
}
