//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include "networkmanagerhandler.h"
#include "networkinterfaces.h"
#include "wirelessmanager.h"
#include "qpcrapplication.h"
#include "constants.h"
#include "logger.h"

NetworkManagerHandler::NetworkManagerHandler(const std::string &interfaceName, OperationType type)
{
    _interfaceName = interfaceName;
    _type = type;
}

void NetworkManagerHandler::processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt)
{
    if (_interfaceName == "wlan")
    {
        if (qpcrApp.wirelessManager()->interfaceName().empty())
        {
            setStatus(Poco::Net::HTTPResponse::HTTP_METHOD_NOT_ALLOWED);
            setErrorString("No WIFI interface is present");

            JsonHandler::processData(requestPt, responsePt);

            return;
        }

        _interfaceName = qpcrApp.wirelessManager()->interfaceName();
    }

    switch (_type)
    {
    case GetStat:
        getStat(responsePt);
        break;

    case SetSettings:
        setSettings(requestPt);
        JsonHandler::processData(requestPt, responsePt);
        break;

    case WifiScan:
        wifiScan(responsePt);
        break;

    case WifiConnect:
        wifiConnect();
        JsonHandler::processData(requestPt, responsePt);
        break;

    case WifiDisconnect:
        wifiDisconnect();
        JsonHandler::processData(requestPt, responsePt);
        break;

    default:
        setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
        setErrorString("Unknown opeation type");

        JsonHandler::processData(requestPt, responsePt);

        break;
    }
}

void NetworkManagerHandler::getStat(boost::property_tree::ptree &responsePt)
{
    NetworkInterfaces::InterfaceState state = NetworkInterfaces::getInterfaceState(_interfaceName);
    NetworkInterfaces::InterfaceSettings settings = NetworkInterfaces::readInterfaceSettings(kNetworkInterfacesFile, _interfaceName);

    responsePt.put("interface", _interfaceName);

    if (!state.isEmpty())
    {
        responsePt.put("state.macAddress", state.macAddress);

        if (state.hasAddress())
        {
            responsePt.put("state.flags", state.flags);
            responsePt.put("state.address", state.address);
            responsePt.put("state.maskAddress", state.maskAddress);
            responsePt.put("state.broadcastAddress", state.broadcastAddress);
        }
    }

    if (!settings.isEmpty())
    {
        responsePt.put("settings.type", settings.type);
        responsePt.put("settings.auto", settings.autoConnect);

        for (std::map<std::string, std::string>::const_iterator it = settings.arguments.begin(); it != settings.arguments.end(); ++it)
            responsePt.put("settings." + it->first, it->second);
    }

    if (_interfaceName == qpcrApp.wirelessManager()->interfaceName())
    {
        WirelessManager::ConnectionStatus status = qpcrApp.wirelessManager()->connectionStatus();

        switch (status)
        {
        case WirelessManager::Connecting:
            responsePt.put("state.status", "connecting");
            break;

        case WirelessManager::ConnectionError:
            responsePt.put("state.status", "connection_error");
            break;

        case WirelessManager::AuthenticationError:
            responsePt.put("state.status", "authentication_error");
            break;

        case WirelessManager::Connected:
            responsePt.put("state.status", "connected");
            break;

        default:
            responsePt.put("state.status", "not_connected");
            break;
        }
    }
}

void NetworkManagerHandler::setSettings(const boost::property_tree::ptree &requestPt)
{
    APP_LOGGER << "NetworkManagerHandler::setSettings" << std::endl;
    if (requestPt.find("type") != requestPt.not_found())
    {
        APP_LOGGER << "NetworkManagerHandler::setSettings found type" << std::endl;

        NetworkInterfaces::InterfaceSettings settings;
        settings.interface = _interfaceName;
        settings.type = requestPt.get<std::string>("type");
        settings.autoConnect = requestPt.get<bool>("auto", true);

        for (boost::property_tree::ptree::const_iterator it = requestPt.begin(); it != requestPt.end(); ++it)
        {
            if (it->first != "type")
                settings.arguments[it->first] = it->second.get_value<std::string>();
        }

        APP_LOGGER << "NetworkManagerHandler::setSettings adding settings" << std::endl;
        NetworkInterfaces::writeInterfaceSettings(kNetworkInterfacesFile, settings);

        APP_LOGGER << "NetworkManagerHandler::setSettings adding settings " << _interfaceName  << std::endl;
        APP_LOGGER << "NetworkManagerHandler::setSettings adding settings " << qpcrApp.wirelessManager()->interfaceName()  << std::endl;
        if (_interfaceName != qpcrApp.wirelessManager()->interfaceName())
        {
        APP_LOGGER << "NetworkManagerHandler::setSettings about to ifdownup " << _interfaceName  << std::endl;
            NetworkInterfaces::ifdown(_interfaceName);
            NetworkInterfaces::ifup(_interfaceName);
        }
        else
            wifiConnect();
    }
    else
    {
        APP_LOGGER << "NetworkManagerHandler::setSettings no type set " << std::endl;

        setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
        setErrorString("type must be set");
    }
}

void NetworkManagerHandler::wifiScan(boost::property_tree::ptree &responsePt)
{
    std::vector<WirelessManager::ScanResult> scanResult = qpcrApp.wirelessManager()->scanResult();
    boost::property_tree::ptree array;

    for (const WirelessManager::ScanResult &result: scanResult)
    {
        boost::property_tree::ptree ptree;
        ptree.put("ssid", result.ssid);
        ptree.put("quality", result.quality);
        ptree.put("siganl_level", result.siganlLevel);

        switch (result.encryption)
        {
        case WirelessManager::ScanResult::WepEncryption:
            ptree.put("encryption", "wep");
            break;

        case WirelessManager::ScanResult::Wpa1PSKEcryption:
            ptree.put("encryption", "wpa1 psk");
            break;

        case WirelessManager::ScanResult::Wpa18021xEcryption:
            ptree.put("encryption", "wpa1 802.1x");
            break;

        case WirelessManager::ScanResult::Wpa2PSKEcryption:
            ptree.put("encryption", "wpa2 psk");
            break;

        case WirelessManager::ScanResult::Wpa28021xEcryption:
            ptree.put("encryption", "wpa2 802.1x");
            break;

        default:
            ptree.put("encryption", "none");
            break;
        }

        array.push_back(std::make_pair("", ptree));
    }

    responsePt.put_child("scan_result", array);
}

void NetworkManagerHandler::wifiConnect()
{
    APP_LOGGER << "NetworkManagerHandler::wifiConnect " << std::endl;

    qpcrApp.wirelessManager()->connect();
}

void NetworkManagerHandler::wifiDisconnect()
{
    //APP_LOGGER << "wifiDisconnect" << std::endl;
    std::string interface = qpcrApp.wirelessManager()->interfaceName();
    qpcrApp.wirelessManager()->shutdown();
    //APP_LOGGER << "done shutdown" << std::endl;
    NetworkInterfaces::removeInterfaceSettings(kNetworkInterfacesFile, interface);
    //APP_LOGGER << "interface removed" << std::endl;

}
