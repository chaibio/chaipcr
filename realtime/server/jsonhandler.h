#ifndef JSONHANDLER_H
#define JSONHANDLER_H

#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPServerResponse.h>

#include <boost/property_tree/ptree.hpp>

class JSONHandler : public Poco::Net::HTTPRequestHandler
{
public:
    JSONHandler();

    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response) final;

    inline Poco::Net::HTTPResponse::HTTPStatus getStatus() const { return _status; }
    inline void setStatus(Poco::Net::HTTPResponse::HTTPStatus status) { _status = status; }

    inline const std::string& getErrorString() const { return _errorString; }
    inline void setErrorString(const std::string &text) { _errorString = text; }

protected:
    virtual void processData(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response,
                             const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);

private:
private:
    Poco::Net::HTTPResponse::HTTPStatus _status;
    std::string _errorString;
};

#endif // JSONHANDLER_H
