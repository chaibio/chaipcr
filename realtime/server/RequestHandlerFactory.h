#ifndef _REQUEST_HANDLER_FACTORY_H_
#define _REQUEST_HANDLER_FACTORY_H_

#include <Poco/Net/HTTPRequestHandlerFactory.h>

using namespace Poco::Net;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRRequestHandlerFactory
class QPCRRequestHandlerFactory: public HTTPRequestHandlerFactory {
public:
	virtual HTTPRequestHandler* createRequestHandler(const HTTPServerRequest &request);
};

#endif