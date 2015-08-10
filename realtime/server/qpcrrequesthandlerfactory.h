#ifndef _REQUEST_HANDLER_FACTORY_H_
#define _REQUEST_HANDLER_FACTORY_H_

#include <Poco/Net/HTTPRequestHandlerFactory.h>

////////////////////////////////////////////////////////////////////////////////
// Class QPCRRequestHandlerFactory
class QPCRRequestHandlerFactory: public Poco::Net::HTTPRequestHandlerFactory
{
public:
    virtual Poco::Net::HTTPRequestHandler* createRequestHandler(const Poco::Net::HTTPServerRequest &request);

private:
    bool checkUserAuthorization(const Poco::Net::HTTPServerRequest &request);
};

#endif
