#ifndef JSONHANDLER_H
#define JSONHANDLER_H

#include "httpstatushandler.h"

class JSONHandler : public HTTPStatusHandler
{
public:
    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response) final;

protected:
    virtual void createData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);
};

#endif // JSONHANDLER_H
