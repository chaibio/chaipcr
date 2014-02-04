#ifndef JSONHANDLER_H
#define JSONHANDLER_H

#include "statushandler.h"

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

class JSONHandler : public StatusHandler
{
public:
    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response) final;

protected:
    virtual void createData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);
};

#endif // JSONHANDLER_H
