#include "pcrincludes.h"
#include "StatusHandler.h"

#include "qpcrcycler.h"
#include "optics.h"

using namespace Poco::Net;


////////////////////////////////////////////////////////////////////////////////
// Class StatusHandler
void StatusHandler::handleRequest(HTTPServerRequest &request, HTTPServerResponse &response) {
    response.setStatus(HTTPResponse::HTTP_OK);
    response.setContentType("text/html");

    std::ostream& out = response.send();
    out << "<h1>Hello new world!</h1>"
        << "<p>Host: "   << request.getHost()   << "</p>"
        << "<p>Method: " << request.getMethod() << "</p>"
        << "<p>URI: "    << request.getURI()    << "</p>"
		<< "<p>Lid open: " << QPCRCycler::instance()->optics().lidOpen() << "</p";
    out.flush();
}
