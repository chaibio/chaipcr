#ifndef _STATUSHANDLER_H_
#define _STATUSHANDLER_H_

#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/Net/HTTPServerResponse.h>

////////////////////////////////////////////////////////////////////////////////
// Class StatusHandler
class StatusHandler: public Poco::Net::HTTPRequestHandler
{
public:
    StatusHandler(Poco::Net::HTTPResponse::HTTPStatus status = Poco::Net::HTTPResponse::HTTP_OK);
    ~StatusHandler();

    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response);

protected:
    inline void setStatus(Poco::Net::HTTPResponse::HTTPStatus status) {this->status = status;}
    inline Poco::Net::HTTPResponse::HTTPStatus getStatus() const {return status;}

private:
    Poco::Net::HTTPResponse::HTTPStatus status;
};
	
#endif
