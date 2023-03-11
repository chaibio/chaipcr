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
    //APP_DEBUGGER << "Start processing data" << std::endl;
    if (_interfaceName == "wlan")
    {
        if (qpcrApp.wirelessManager()->interfaceName().empty())
        {
            setStatus(Poco::Net::HTTPResponse::HTTP_METHOD_NOT_ALLOWED);
            setErrorString("No WIFI interface is present");

            JsonHandler::processData(requestPt, responsePt);
            APP_DEBUGGER << "No WIFI interface is present" << std::endl;

            return;
        }

        _interfaceName = qpcrApp.wirelessManager()->interfaceName();
    }
    else
    {
        APP_DEBUGGER << "_interfaceName " << _interfaceName << " _type: " << _type << std::endl;
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

    // Hotspot
    case HotspotSelect:
        hotspotSelect();
        JsonHandler::processData(requestPt, responsePt);
        break;
    case WifiSelect:
        wifiSelect();
        JsonHandler::processData(requestPt, responsePt);
        break;
    case HotspotActivate:
        setHotspotSettings(requestPt);
        if(!hotspotActivate())
        {
           setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
           setErrorString("Invalid hotspot settings");
        }

        JsonHandler::processData(requestPt, responsePt);
        break;
    case HotspotDeactivate:
        hotspotDeactivate();
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
        case WirelessManager::HotspotActive:
        {
            responsePt.put("state.status", "hotspot_active");
            std:: string interfacename, hotspot_ssid, hotspot_key;
            
            bool success = WirelessManager::hotspotRetrieveInfo( interfacename, hotspot_ssid, hotspot_key );
            if(success)
            {
                responsePt.put("state.hotspot_ssid", hotspot_ssid);
                responsePt.put("state.hotspot_key", hotspot_key);
                responsePt.put("state.interfacename", interfacename);
            }

            responsePt.put("state.hotspot_ssid_buffered", hotspotSettings().hotspot_ssid);
            responsePt.put("state.hotspot_key_buffered",  hotspotSettings().hotspot_key);
            responsePt.put("state.interfacename_buffered", hotspotSettings().interface);
        }
        break;

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

NetworkInterfaces::InterfaceSettings& NetworkManagerHandler::hotspotSettings()
{
    return qpcrApp.wirelessManager()->hotspotSettings();
}

void NetworkManagerHandler::setHotspotSettings(const boost::property_tree::ptree &requestPt)
{
    APP_DEBUGGER << "NetworkManagerHandler::setHotspotSettings" << std::endl;
/*    if (requestPt.find("password") == requestPt.not_found() && requestPt.find("ssid") == requestPt.not_found() )
    {
        APP_DEBUGGER << "NetworkManagerHandler::setHotspotSettings setting defaults" << std::endl;

        hotspotSettings().arguments.clear();
        hotspotSettings().interface = _interfaceName;
        hotspotSettings().hotspot_ssid = "chaihotspot";
        hotspotSettings().hotspot_key  = "password";

        for (boost::property_tree::ptree::const_iterator it = requestPt.begin(); it != requestPt.end(); ++it)
        {
            if ( it->first != "ssid" && it->first != "password" )
                hotspotSettings().arguments[it->first] = it->second.get_value<std::string>();
        }
    }
    else */if (requestPt.find("password") != requestPt.not_found() && requestPt.find("ssid") != requestPt.not_found() )
    {
        APP_DEBUGGER << "NetworkManagerHandler::setHotspotSettings found ssid and password" << std::endl;

        hotspotSettings().arguments.clear();
        hotspotSettings().interface = _interfaceName;
        hotspotSettings().hotspot_ssid = requestPt.get<std::string>("ssid");
        hotspotSettings().hotspot_key  = requestPt.get<std::string>("password");

        for (boost::property_tree::ptree::const_iterator it = requestPt.begin(); it != requestPt.end(); ++it)
        {
            if ( it->first != "ssid" && it->first != "password" )
                hotspotSettings().arguments[it->first] = it->second.get_value<std::string>();
        }
    }
    else
    {
        APP_DEBUGGER << "NetworkManagerHandler::setHotspotSettings Both ssid and password must be set" << std::endl;

        setStatus(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
        setErrorString("Both ssid and password must be set!");
    }
    APP_DEBUGGER << "NetworkManagerHandler::setHotspotSettings done" << std::endl;

}

void NetworkManagerHandler::setSettings(const boost::property_tree::ptree &requestPt)
{
    APP_DEBUGGER << "NetworkManagerHandler::setSettings" << std::endl;
    if (requestPt.find("type") != requestPt.not_found())
    {
        APP_DEBUGGER << "NetworkManagerHandler::setSettings found type" << std::endl;

        NetworkInterfaces::InterfaceSettings settings;
        settings.interface = _interfaceName;
        settings.type = requestPt.get<std::string>("type");
        settings.autoConnect = requestPt.get<bool>("auto", true);

        for (boost::property_tree::ptree::const_iterator it = requestPt.begin(); it != requestPt.end(); ++it)
        {
            if (it->first != "type")
                settings.arguments[it->first] = it->second.get_value<std::string>();
        }

        APP_DEBUGGER << "NetworkManagerHandler::setSettings adding settings" << std::endl;
        NetworkInterfaces::writeInterfaceSettings(kNetworkInterfacesFile, settings);

        APP_DEBUGGER << "NetworkManagerHandler::setSettings adding settings " << _interfaceName << std::endl;
        APP_DEBUGGER << "NetworkManagerHandler::setSettings adding settings " << qpcrApp.wirelessManager()->interfaceName()  << std::endl;
        if (_interfaceName != qpcrApp.wirelessManager()->interfaceName())
        {
            APP_DEBUGGER << "NetworkManagerHandler::setSettings about to ifdownup " << _interfaceName  << std::endl;
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
    APP_DEBUGGER << "NetworkManagerHandler::wifiScan " << std::endl;
    WirelessManager::ConnectionStatus status = qpcrApp.wirelessManager()->connectionStatus();
    if(status == WirelessManager::HotspotActive)
    {
        APP_DEBUGGER << "No wifiScan for hotspot" << std::endl;
        boost::property_tree::ptree array;
        responsePt.put_child("scan_result", array);
        return;
    }

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
    APP_DEBUGGER << "NetworkManagerHandler::wifiConnect " << std::endl;
    qpcrApp.wirelessManager()->connect();
}

void NetworkManagerHandler::hotspotSelect()
{
    // put back latest settings interfaces if hotspotted.. otherwise it will disconnect wifi only
    APP_DEBUGGER << "NetworkManagerHandler::hotspotSelect" << std::endl;
    qpcrApp.wirelessManager()->hotspotSelect();
}

void NetworkManagerHandler::wifiSelect()
{
    // returns back latest interfaces settings
    APP_DEBUGGER << "NetworkManagerHandler::wifiSelect " << std::endl;
    qpcrApp.wirelessManager()->wifiSelect();
}

bool NetworkManagerHandler::hotspotActivate()
{
    // set hotspot settings and turn it on
    APP_DEBUGGER << "NetworkManagerHandler::hotspotActivate create_hotspot" << std::endl;
    return qpcrApp.wirelessManager()->hotspotActivate();

}

void NetworkManagerHandler::hotspotDeactivate()
{
    // disconnects hotspot 
    APP_DEBUGGER << "NetworkManagerHandler::hotspotDeactivate " << std::endl;
    qpcrApp.wirelessManager()->hotspotDeactivate();

    hotspotSettings().hotspot_ssid.clear();
    hotspotSettings().hotspot_key.clear();
    hotspotSettings().interface.clear();
}

void NetworkManagerHandler::wifiDisconnect()
{
    std::string interface = qpcrApp.wirelessManager()->interfaceName();
    qpcrApp.wirelessManager()->shutdown();
    NetworkInterfaces::removeInterfaceSettings(kNetworkInterfacesFile, interface);
}
