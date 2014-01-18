#ifndef _STATUSHANDLER_H_
#define _STATUSHANDLER_H_

#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/Net/HTTPServerResponse.h>

////////////////////////////////////////////////////////////////////////////////
// Class StatusHandler
class StatusHandler: public Poco::Net::HTTPRequestHandler {
public:
	virtual void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response);
};
	
#endif
