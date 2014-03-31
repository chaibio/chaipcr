#include "boostincludes.h"
#include "pocoincludes.h"

#include "testcontrolhandler.h"
#include "statushandler.h"

#include "qpcrrequesthandlerfactory.h"

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
                return new StatusHandler();
        }
        else if (request.getMethod() == "PUT")
        {
            if (requestPath.at(0) == "testControl")
                return new TestControlHandler();
        }
    }

    return new HTTPStatusHandler(HTTPResponse::HTTP_NOT_FOUND);
}
