#include "pcrincludes.h"
#include "qpcrrequesthandlerfactory.h"

#include "jsonhandler.h"
#include "testcontrolhandler.h"

#include <Poco/URI.h>

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
        if (request.getMethod() == "GET")
        {
            if (requestPath.at(0) == "status")
                return new JSONHandler();
        }
        else if (request.getMethod() == "PUT")
        {
            if (requestPath.at(0) == "testControl")
                return new TestControlHandler();
        }
    }

    return new StatusHandler(HTTPResponse::HTTP_NOT_FOUND);
}
