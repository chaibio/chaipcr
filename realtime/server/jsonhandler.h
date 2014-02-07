#ifndef JSONHANDLER_H
#define JSONHANDLER_H

#include "statushandler.h"

class JSONHandler : public StatusHandler
{
public:
    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response) final;

protected:
    virtual void createData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);
};

#endif // JSONHANDLER_H
