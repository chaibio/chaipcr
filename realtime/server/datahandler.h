#ifndef DATAHANDLER_H
#define DATAHANDLER_H

#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/Net/HTTPServerResponse.h>

class DataHandler : public Poco::Net::HTTPRequestHandler
{
public:
    DataHandler();
    DataHandler(Poco::Net::HTTPResponse::HTTPStatus status);

    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response) final;

    inline Poco::Net::HTTPResponse::HTTPStatus getStatus() const { return _status; }
    inline void setStatus(Poco::Net::HTTPResponse::HTTPStatus status) { _status = status; }

protected:
    virtual void processRequest(Poco::Net::HTTPServerRequest &request) = 0;
    virtual void processResponse(Poco::Net::HTTPServerResponse &response);

private:
    Poco::Net::HTTPResponse::HTTPStatus _status;
};

#endif // DATAHANDLER_H
