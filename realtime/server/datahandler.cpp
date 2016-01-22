#include "datahandler.h"

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
    try
    {
        processRequest(request);

        response.setStatusAndReason(getStatus(), Poco::Net::HTTPServerResponse::getReasonForStatus(getStatus()));

        //CORS
        response.add("Access-Control-Allow-Methods", "POST, PUT, OPTIONS");
        response.add("Access-Control-Allow-Origin", "*");
        response.add("Access-Control-Allow-Headers", "Content-Type");

        processResponse(response);
    }
    catch (const std::exception &ex)
    {
        std::cout << "DataHandler::handleRequest - " << ex.what() << '\n';

        response.setStatusAndReason(Poco::Net::HTTPResponse::HTTP_INTERNAL_SERVER_ERROR, Poco::Net::HTTPServerResponse::getReasonForStatus(getStatus()));
        response.send().flush();
    }
    catch (...)
    {
        std::cout << "DataHandler::handleRequest - unknown error\n";

        response.setStatusAndReason(Poco::Net::HTTPResponse::HTTP_INTERNAL_SERVER_ERROR, Poco::Net::HTTPServerResponse::getReasonForStatus(getStatus()));
        response.send().flush();
    }
}

void DataHandler::processResponse(Poco::Net::HTTPServerResponse &response)
{
    response.send().flush();
}
