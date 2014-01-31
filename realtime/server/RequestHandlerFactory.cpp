#include "pcrincludes.h"
#include "RequestHandlerFactory.h"

#include <Poco/Net/HTTPServerRequest.h>
#include "StatusHandler.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRRequestHandlerFactory
HTTPRequestHandler* QPCRRequestHandlerFactory::createRequestHandler(const HTTPServerRequest &request) {
	vector<string> pathSegments;
/*	request.getURI().getPathSegments(pathSegments);
	
	if (pathSegments[0] == "status")*/
		return new StatusHandler();
	//else
		//return nullptr;
}
