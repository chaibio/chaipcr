#include "wirelessmanagerhandler.h"
#include "qpcrapplication.h"
#include "wirelessmanager.h"

WirelessManagerHandler::WirelessManagerHandler(OperationType operation)
{
    _operation = operation;
}

void WirelessManagerHandler::processData(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response,
                                         const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt)
{
    switch (_operation)
    {
    case Scan:
    {
        std::vector<std::string> scanResult = qpcrApp.wirelessManager()->scanResult();
        boost::property_tree::ptree array;

        for (const std::string &ssid: scanResult)
        {
            boost::property_tree::ptree ptree;
            ptree.put("ssid", ssid);

            array.push_back(std::make_pair("", ptree));
        }

        responsePt.put_child("scan_result", array);

        break;
    }

    case Connect:
    {
        qpcrApp.wirelessManager()->connect(requestPt.get<std::string>("ssid"), requestPt.get<std::string>("password"));

        JSONHandler::processData(request, response, requestPt, responsePt);

        break;
    }

    case Shutdown:
    {
        qpcrApp.wirelessManager()->shutdown();

        JSONHandler::processData(request, response, requestPt, responsePt);

        break;
    }

    default: //Status
    {
        WirelessManager::ConnectionStatus status = qpcrApp.wirelessManager()->connectionStatus();

        switch (status)
        {
        case WirelessManager::Connecting:
            responsePt.put("wifi.status", "Connecting");
            break;

        case WirelessManager::ConnectionError:
            responsePt.put("wifi.status", "ConnectionError");
            break;

        case WirelessManager::AuthenticationError:
            responsePt.put("wifi.status", "AuthenticationError");
            break;

        case WirelessManager::Connected:
            responsePt.put("wifi.status", "Connected");
            break;

        default:
            responsePt.put("wifi.status", "NotConnected");
            break;
        }

        break;
    }
    }
}
