#include "jsonhandler.h"

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
        std::cout << "JsonHandler::processRequest - error: " << ex.what() << '\n';

        _responsePt.clear();

        setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
        setErrorString(ex.what());
        JsonHandler::processData(requestPt, _responsePt);
    }
    catch (...)
    {
        std::cout << "JsonHandler::processRequest - unknown error\n";

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
    if (getStatus() == Poco::Net::HTTPResponse::HTTP_OK)
        responsePt.put("status.status", true);
    else
    {
        responsePt.put("status.status", false);
        responsePt.put("status.error", getErrorString());
    }
}
