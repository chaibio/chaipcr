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

    inline Poco::Net::HTTPResponse::HTTPStatus getStatus() const {return status;}
    inline std::string getErrorString() const {return errorString;}

protected:
    inline void setStatus(Poco::Net::HTTPResponse::HTTPStatus status) {this->status = status;}
    inline void setErrorString(const std::string &errorString) {this->errorString = errorString;}

private:
    Poco::Net::HTTPResponse::HTTPStatus status;
    std::string errorString;
};
	
#endif
