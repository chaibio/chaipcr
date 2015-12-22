#ifndef JSONHANDLER_H
#define JSONHANDLER_H

#include "datahandler.h"

#include <boost/property_tree/ptree.hpp>

class JsonHandler : public DataHandler
{
public:
    JsonHandler();
    JsonHandler(Poco::Net::HTTPResponse::HTTPStatus status, const std::string &errorMessage);

    inline const std::string& getErrorString() const { return _errorString; }
    inline void setErrorString(const std::string &text) { _errorString = text; }

protected:
    void processRequest(Poco::Net::HTTPServerRequest &request) final;
    void processResponse(Poco::Net::HTTPServerResponse &response) final;

    virtual void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);

private:
    boost::property_tree::ptree _responsePt;

    std::string _errorString;
};

#endif // JSONHANDLER_H
