#include "jsonhandler.h"

#include <iostream>
#include <exception>

using namespace Poco::Net;
using namespace boost::property_tree;
using namespace std;

void JSONHandler::handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response)
{
    try
    {
        istream &requestStream = request.stream();
        ptree requestPt;

        read_json(requestStream, requestPt);

        ptree responsePt;
        createData(requestPt, responsePt);

        if (getStatus() == HTTPResponse::HTTP_OK)
        {
            ostream &responseStream = response.send();
            write_json(responseStream, responsePt, false);
            responseStream.flush();

            response.setContentType("text/html");
        }
    }
    catch (json_parser_error &ex)
    {
        cout << "Reading JSON from request failed: " << ex.what() << '\n';

        setStatus(HTTPResponse::HTTP_BAD_REQUEST);
    }
    catch (exception &ex)
    {
        cout << "Error occured: " << ex.what() << '\n';

        setStatus(HTTPResponse::HTTP_INTERNAL_SERVER_ERROR);
    }

    StatusHandler::handleRequest(request, response);
}

void JSONHandler::createData(const ptree &, ptree &responsePt)
{
    if (getStatus() == HTTPResponse::HTTP_OK)
    {
        responsePt.put("status", true);
    }
}
