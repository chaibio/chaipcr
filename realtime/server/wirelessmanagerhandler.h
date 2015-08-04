#ifndef WIRELESSMANAGERHANDLER_H
#define WIRELESSMANAGERHANDLER_H

#include "jsonhandler.h"

class WirelessManagerHandler : public JSONHandler
{
public:
    enum OperationType
    {
        Scan,
        Connect,
        Shutdown,
        Status
    };

    WirelessManagerHandler(OperationType operation);

    void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);

private:
    OperationType _operation;
};

#endif // WIRELESSMANAGERHANDLER_H
