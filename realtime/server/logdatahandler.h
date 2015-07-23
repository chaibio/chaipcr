#ifndef LOGDATAHANDLER_H
#define LOGDATAHANDLER_H

#include "jsonhandler.h"

class LogDataHandler : public JSONHandler
{
protected:
    void processData(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response,
                     const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);
};

#endif // LOGDATAHANDLER_H
