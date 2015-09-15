#include <boost/property_tree/json_parser.hpp>
#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/Net/HTTPServerResponse.h>

#include <iostream>

#include "jsonhandler.h"

using namespace Poco::Net;
using namespace boost::property_tree;
using namespace std;

JSONHandler::JSONHandler()
{
    setStatus(HTTPResponse::HTTP_OK);
}

JSONHandler::JSONHandler(HTTPResponse::HTTPStatus code, const string &errorMessage)
{
    setStatus(code);
    setErrorString(errorMessage);
}

void JSONHandler::handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response)
{
    istream &requestStream = request.stream();
    ptree requestPt, responsePt;

    try
    {
        if (request.getContentLength() > 0)
            read_json(requestStream, requestPt);

        processData(requestPt, responsePt);
    }
    catch (json_parser_error &ex)
    {
        cout << "JSONHandler::handleRequest - Failed to parse JSON: " << ex.what() << '\n';

        setStatus(HTTPResponse::HTTP_BAD_REQUEST);
        setErrorString(ex.what());

        responsePt.clear();
        JSONHandler::processData(requestPt, responsePt);
    }
    catch (exception &ex)
    {
        cout << "JSONHandler::handleRequest - Error occured: " << ex.what() << '\n';

        setStatus(HTTPResponse::HTTP_INTERNAL_SERVER_ERROR);
        setErrorString(ex.what());

        responsePt.clear();
        JSONHandler::processData(requestPt, responsePt);
    }

    try
    {
        response.setStatusAndReason(getStatus(), Poco::Net::HTTPServerResponse::getReasonForStatus(getStatus()));

        //CORS
        response.add("Access-Control-Allow-Origin", "*");
        response.add("Access-Control-Allow-Headers", "X-Requested-With, X-Prototype-Version, X-CSRF-Token, Authorization");

        if (!responsePt.empty())
        {
            response.setContentType("text/json");

            ostream &responseStream = response.send();
            write_json(responseStream, responsePt);
            responseStream.flush();
        }
        else
            response.send().flush();
    }
    catch (exception &ex)
    {
        cout << "JSONHandler::handleRequest - Failed to write JSON: " << ex.what() << '\n';
    }
}

void JSONHandler::processData(const ptree &, ptree &responsePt)
{
    if (getStatus() == HTTPResponse::HTTP_OK)
        responsePt.put("status.status", true);
    else
    {
        responsePt.put("status.status", false);
        responsePt.put("status.error", getErrorString());
    }
}
