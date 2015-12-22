#ifndef NETWORKMANAGERHANDLER_H
#define NETWORKMANAGERHANDLER_H

#include "jsonhandler.h"

class NetworkManagerHandler : public JsonHandler
{
public:
    enum OperationType
    {
        //General operations
        GetStat,
        SetSettings,

        //Wifi
        WifiScan,
        WifiConnect,
        WifiDisconnect
    };

    NetworkManagerHandler(const std::string &interfaceName, OperationType type);

protected:
    void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);

private:
    void getStat(boost::property_tree::ptree &responsePt);
    void setSettings(const boost::property_tree::ptree &requestPt);

    void wifiScan(boost::property_tree::ptree &responsePt);
    void wifiConnect();
    void wifiDisconnect();

private:
    std::string _interfaceName;
    OperationType _type;
};

#endif // NETWORKMANAGERHANDLER_H
