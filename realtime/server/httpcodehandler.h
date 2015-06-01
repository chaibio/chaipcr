#ifndef HTTPCODEHANDLER_H
#define HTTPCODEHANDLER_H

#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPServerResponse.h>

class HTTPCodeHandler : public Poco::Net::HTTPRequestHandler
{
public:
    HTTPCodeHandler(Poco::Net::HTTPResponse::HTTPStatus status = Poco::Net::HTTPResponse::HTTP_OK, const std::string &reason = "");

    inline Poco::Net::HTTPResponse::HTTPStatus status() const { return _status; }
    inline void setStatus(Poco::Net::HTTPResponse::HTTPStatus status) { _status = status; }

    inline const std::string& reason() const { return _reason; }
    inline void setReason(const std::string &reason) { _reason = reason; }

    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response) final;

private:
    Poco::Net::HTTPResponse::HTTPStatus _status;
    std::string _reason;
};

#endif // HTTPCODEHANDLER_H
