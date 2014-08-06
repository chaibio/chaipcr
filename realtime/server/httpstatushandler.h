#ifndef _HTTPSTATUSHANDLER_H_
#define _HTTPSTATUSHANDLER_H_

#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPServerResponse.h>

////////////////////////////////////////////////////////////////////////////////
// Class StatusHandler
class HTTPStatusHandler: public Poco::Net::HTTPRequestHandler
{
public:
    HTTPStatusHandler(Poco::Net::HTTPServerResponse::HTTPStatus status = Poco::Net::HTTPServerResponse::HTTP_OK);
    ~HTTPStatusHandler();

    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response);

    inline Poco::Net::HTTPResponse::HTTPStatus getStatus() const {return status;}
    inline std::string getErrorString() const {return errorString;}

protected:
    inline void setStatus(Poco::Net::HTTPServerResponse::HTTPStatus status) {this->status = status;}
    inline void setErrorString(const std::string &errorString) {this->errorString = errorString;}

private:
    Poco::Net::HTTPServerResponse::HTTPStatus status;
    std::string errorString;
};
	
#endif
