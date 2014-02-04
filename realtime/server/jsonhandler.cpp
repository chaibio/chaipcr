#include "jsonhandler.h"

#include <iostream>
#include <exception>

using namespace Poco::Net;
using namespace boost::property_tree;
using namespace std;

void JSONHandler::handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response)
{
    istream &requestStream = request.stream();
    ptree requestPt, responsePt;

    try
    {
        read_json(requestStream, requestPt);
        createData(requestPt, responsePt);
    }
    catch (json_parser_error &ex)
    {
        cout << "Failed to parse JSON: " << ex.what() << '\n';

        setStatus(HTTPResponse::HTTP_BAD_REQUEST);
        setErrorString(ex.what());

        responsePt.clear();
        JSONHandler::createData(requestPt, responsePt);
    }
    catch (exception &ex)
    {
        cout << "Error occured: " << ex.what() << '\n';

        setStatus(HTTPResponse::HTTP_INTERNAL_SERVER_ERROR);
        setErrorString(ex.what());

        responsePt.clear();
        JSONHandler::createData(requestPt, responsePt);
    }

    try
    {
        ostream &responseStream = response.send();
        write_json(responseStream, responsePt, false);
        responseStream.flush();

        response.setContentType("text/html");
    }
    catch (exception &ex)
    {
        cout << "Failed to write JSON: " << ex.what() << '\n';

        setStatus(HTTPResponse::HTTP_INTERNAL_SERVER_ERROR);
    }

    StatusHandler::handleRequest(request, response);
}

void JSONHandler::createData(const ptree &, ptree &responsePt)
{
    if (getStatus() == HTTPResponse::HTTP_OK)
        responsePt.put("status.status", true);
    else
    {
        responsePt.put("status.status", false);
        responsePt.put("status.error", getErrorString());
    }
}
