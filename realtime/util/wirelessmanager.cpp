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

#include "wirelessmanager.h"
#include "networkinterfaces.h"
#include "constants.h"
#include "util.h"
#include "logger.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <iostream>
#include <sstream>
#include <stdexcept>
#include <system_error>
#include <map>

#include <unistd.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <sys/eventfd.h>
#include <Poco/File.h>

#define CONNECTION_TIMEOUT_INTERVAL 10
#define SCAN_CACHE_INTERVAL 60

bool command_run(std::string tag, std::string cmd);

WirelessManager::WirelessManager()
{
    _connectionEventFd = eventfd(0, EFD_NONBLOCK);

    if (_connectionEventFd == -1)
        throw std::system_error(errno, std::generic_category(), "Wireless manager: unable to create event fd -");

    _connectionThreadState = Idle;
    _connectionStatus = NotConnected;
    _connectionTimeout = 0;
    _scanTime = 0;
    _scanScheduleState = false;

    loadWifiDriver();
    _interfaceStatusThreadStatus = Working;
    _interfaceStatusThread = std::thread(&WirelessManager::checkInterfaceStatus, this);
}

WirelessManager::~WirelessManager()
{
    stopCommands();
    close(_connectionEventFd);

    if (_interfaceStatusThread.joinable())
    {
        _interfaceStatusThreadStatus = Stopping;
        _interfaceStatusThread.join();
    }
}

std::string WirelessManager::interfaceName() const
{
    Poco::RWLock::ScopedReadLock lock(_interfaceNameMutex);

    return _interfaceName;
}

void WirelessManager::hotspotSelect()
{
    APP_DEBUGGER << "WirelessManager::hotspotSelect " << std::endl;
    _selectionThread = std::thread(&WirelessManager::_hotspotSelect, this);
}

void WirelessManager::wifiSelect()
{
    APP_DEBUGGER << "WirelessManager::wifiSelect " << std::endl;
    _selectionThread = std::thread(&WirelessManager::_wifiSelect, this);
}

void WirelessManager::hotspotActivate()
{
    APP_DEBUGGER << "WirelessManager::hotspotActivate " << std::endl;
    _hotspotThread = std::thread(&WirelessManager::_hotspotActivate, this);
}

void WirelessManager::hotspotDeactivate()
{
    APP_DEBUGGER << "WirelessManager::hotspotDeactivate " << std::endl;
    _hotspotThread = std::thread(&WirelessManager::_hotspotDeactivate, this);
}

void WirelessManager::_hotspotDeactivate()
{
    APP_DEBUGGER << "WirelessManager::_hotspotDeactivate " << std::endl;
    if (interfaceName().empty())
    {
        APP_LOGGER << "WirelessManager::_hotspotDeactivate Error no interface name" << std::endl;
        return;
    }
    
    std::stringstream stream;
    stream << "/root/chaipcr/deploy/wifi/hotspot_controller.sh " << interfaceName() << " hotspotdeactivate";
    if(command_run( "WirelessManager::_hotspotDeactivate", stream.str() ))
    {
        if ( _connectionStatus == HotspotActive )
            _connectionStatus = NotConnected;
    }
}

void WirelessManager::_hotspotSelect()
{
    APP_DEBUGGER << "WirelessManager::_hotspotSelect " << std::endl;
    if (interfaceName().empty())
    {
        APP_LOGGER << "WirelessManager::_hotspotSelect Error no interface name" << std::endl;
        return;
    }
    
    std::stringstream stream;
    stream << "/root/chaipcr/deploy/wifi/hotspot_controller.sh " << interfaceName() << " hotspotselect";
    command_run( "WirelessManager::_hotspotSelect", stream.str() );
}

bool command_run(std::string tag, std::string cmd)
{ 
    LoggerStreams logStreams;
    int _cmdEventFd = eventfd(0, EFD_NONBLOCK);

    if (_cmdEventFd == -1)
        throw std::system_error(errno, std::generic_category(), "Wireless manager: unable to create event command fd -");

    std::stringstream output;

    if (!Util::watchProcess(cmd, _cmdEventFd,
                            [&logStreams,tag,&output](const char *buffer, std::size_t size){ logStreams.stream( tag + " (stdout)").write(buffer, size); output.write(buffer, size);},
                            [&logStreams,tag](const char *buffer, std::size_t size){ logStreams.stream( tag + " (stderr)").write(buffer, size); }))
    {
        APP_DEBUGGER << tag << ": error calling " << cmd << std::endl;
        return false;
    }

    return output.str().find("OK") != std::string::npos;
}

void WirelessManager::_wifiSelect()
{
    APP_DEBUGGER << "WirelessManager::_wifiSelect " << std::endl;

    if (interfaceName().empty())
    {
        APP_LOGGER << "WirelessManager::_wifiSelect Error no interface name" << std::endl;
        return;
    }
    
    std::stringstream stream;
    stream << "/root/chaipcr/deploy/wifi/hotspot_controller.sh " << interfaceName() << " wifiselect";
    command_run( "WirelessManager::_wifiSelect", stream.str() );
}

void WirelessManager::_hotspotActivate()
{
    APP_DEBUGGER << "WirelessManager::_hotspotActivate " << std::endl;
    _connectionStatus = ConnectionError;

    if (interfaceName().empty())
    {
        APP_LOGGER << "WirelessManager::_hotspotActivate Error no interface name" << std::endl;
        return;
    }

    if (hotspot_settings.hotspot_ssid.empty())
    {
        APP_LOGGER << "WirelessManager::_hotspotActivate Error no hotspot ssid" << std::endl;
        return;
    }

    if (hotspot_settings.hotspot_key.length()<8)
    {
        APP_LOGGER << "WirelessManager::_hotspotActivate Error no or invalid hotspot key" << std::endl;
        return;
    }

    std::string hotspot_ssid = hotspot_settings.hotspot_ssid;
    std::string hotspot_key  = hotspot_settings.hotspot_key;
    std::stringstream stream;
    stream << "/root/chaipcr/deploy/wifi/hotspot_controller.sh " << interfaceName() << " \"" << hotspot_ssid << "\" \"" << hotspot_key << "\"";
    if(command_run( "WirelessManager::_wifiSelect", stream.str() ))
    {
        _connectionStatus = HotspotActive;
        APP_LOGGER << "WirelessManager::_hotspotActivate hotspot activated OK" << std::endl;
    }
}

void WirelessManager::connect()
{
    APP_DEBUGGER << "WirelessManager::connect " << interfaceName() << std::endl;

    if (!interfaceName().empty())
    {
        std::lock_guard<std::recursive_mutex> lock(_commandsMutex);

        APP_DEBUGGER << "WirelessManager::connect stopping " << interfaceName() << std::endl;
        stopCommands();

        _connectionStatus = Connecting;
        _connectionThreadState = Working;
        _connectionThread = std::thread(&WirelessManager::_connect, this);
    }
}

void WirelessManager::shutdown()
{
    APP_DEBUGGER << "WirelessManager::shutdown, _connectionStatus =" << _connectionStatus << std::endl;
    if (!interfaceName().empty())
    {
        std::lock_guard<std::recursive_mutex> lock(_commandsMutex);
        bool bDectivateHotspot = ( _connectionStatus != HotspotActive );

        stopCommands();

        if(bDectivateHotspot)
            hotspotDeactivate();
        else
        /*_shutdownThread = std::thread(&*/WirelessManager::ifdown()/*, this)*/;
    }
}

std::string WirelessManager::getCurrentSsid() const
{
    std::string ssid;
    std::string interface = interfaceName();

    if (!interface.empty())
        Util::watchProcess("iwgetid -r " + interface, [&ssid](const char *buffer, std::size_t size){ ssid.assign(buffer, size); });

    return ssid;
}

std::vector<WirelessManager::ScanResult> WirelessManager::scanResult()
{
    APP_DEBUGGER << "WirelessManager::scanResult" << std::endl;

    Poco::RWLock::ScopedReadLock lock(_scanResultMutex);

    if (_scanTime + SCAN_CACHE_INTERVAL < std::time(nullptr))
    {
        APP_DEBUGGER << "clearning scan resutls" << std::endl;
        _scanResult.clear();
    }

    _scanScheduleState = true;

    return _scanResult;
}

void WirelessManager::setInterfaceName(const std::string &name)
{
    Poco::RWLock::ScopedWriteLock lock(_interfaceNameMutex);
    _interfaceName = name;
}

void WirelessManager::stopCommands()
{
        APP_DEBUGGER << "WirelessManager::stopCommands" << std::endl;

    std::lock_guard<std::recursive_mutex> lock(_commandsMutex);

    if (_connectionThread.joinable())
    {
        _connectionThreadState = Stopping;

        uint64_t i = 1;
        write(_connectionEventFd, &i, sizeof(i));

        _connectionThread.join();

        //Clear event fd
        read(_connectionEventFd, &i, sizeof(i));
    }

    if (_shutdownThread.joinable())
        _shutdownThread.join();
    
    if (_selectionThread.joinable())
    {
        _selectionThread.join();
    }
    
    if (_hotspotThread.joinable())
    {
        _hotspotThread.join();
    }
}

void WirelessManager::_connect()
{
    APP_DEBUGGER << "WirelessManager::_connect " << std::endl;

    try
    {
        std::string interface = interfaceName();

        if (if_nametoindex(interface.c_str()) == 0)
            throw std::system_error(errno, std::generic_category(), "WirelessManager::_connect - unable to get interface index (" + interface + "):");

        if (_connectionThreadState != Working)
        {
            _connectionThreadState = Idle;
            return;
        }

        ifdown();

        if (_connectionThreadState != Working)
        {
            _connectionThreadState = Idle;
            return;
        }

        APP_DEBUGGER << "about to NetworkInterfaces::removeLeases " << std::endl;
        NetworkInterfaces::removeLeases(interface);

        _connectionStatus = Connecting;

        APP_DEBUGGER << "about to ifup " << std::endl;
        ifup();
        APP_DEBUGGER << "done ifup " << std::endl;
        APP_DEBUGGER << "done NetworkInterfaces::dhcpTimeout() " << NetworkInterfaces::dhcpTimeout() << std::endl;
        APP_DEBUGGER << "done CONNECTION_TIMEOUT_INTERVAL " << CONNECTION_TIMEOUT_INTERVAL << std::endl;

        _connectionTimeout = std::time(nullptr) + NetworkInterfaces::dhcpTimeout() + CONNECTION_TIMEOUT_INTERVAL;
        _connectionThreadState = Idle;
    }
    catch (const std::exception &ex)
    {
        APP_DEBUGGER << "WirelessManager::_connect - exception occured:" << ex.what() << std::endl;

        _connectionStatus = ConnectionError;
    }
}

void WirelessManager::loadWifiDriver()
{
    LoggerStreams logStreams;
    std::stringstream stream, lsusbstream, lsmodstream;
    int found_adapter=-1;
    bool bRmmodInsmod = false;
    bool bInsmodNeeded = false;

    stream << "/usr/bin/lsusb";
    if (!Util::watchProcess(stream.str(), _connectionEventFd,
                            [&logStreams,&lsusbstream](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - lsusb (stdout)").write(buffer, size); lsusbstream.write(buffer, size); },
                            [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - lsusb (stderr)").write(buffer, size); }))
    {
        APP_DEBUGGER << "loadWifiDriver: error calling lsusb" << std::endl;
    }

    for(int adapter=0; found_adapter==-1 && wifiDrivers[adapter].pszNetworkDriverName!=nullptr; adapter++)
        for(int device=0; wifiDrivers[adapter].pszUSBID[device]!=nullptr; device++)
        {
            if( lsusbstream.str().find(wifiDrivers[adapter].pszUSBID[device]) != std::string::npos )
            {
                found_adapter = adapter;
                bRmmodInsmod = wifiDrivers[adapter].bRmmodInsmod;
                APP_DEBUGGER << "loadWifiDriver: found the wifi adapter " << wifiDrivers[adapter].pszNetworkDriverName;
                APP_DEBUGGER << ", USBID " << wifiDrivers[adapter].pszUSBID[device] << std::endl;
                break;
            }
        }

    if(found_adapter==-1)
    {
        APP_DEBUGGER << "loadWifiDriver: failed detecting a wifi adapter" << std::endl;
        found_adapter = 0;
    }

    stream.str("/sbin/lsmod");
    if (!Util::watchProcess(stream.str(), _connectionEventFd,
                            [&logStreams,&lsmodstream](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - lsmod (stdout)").write(buffer, size); lsmodstream.write(buffer, size); },
                            [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - lsmod (stderr)").write(buffer, size); }))
    {
        APP_LOGGER << "loadWifiDriver: error calling lsmod" << std::endl;
    }

    if( lsmodstream.str().find( wifiDrivers[found_adapter].pszNetworkDriverName ) == std::string::npos )
    {
        bInsmodNeeded = true;
    }

    if(bRmmodInsmod && !bInsmodNeeded)
    {
        if( lsmodstream.str().find( wifiDrivers[found_adapter].pszNetworkDriverName ) != std::string::npos )
        {
            stream.str("");
            stream << "rmmod " << wifiDrivers[found_adapter].pszNetworkDriverName;

            if (!Util::watchProcess(stream.str(), _connectionEventFd,
                                    [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::loadWifiDriver - rmmod (stdout)").write(buffer, size); },
                                    [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::loadWifiDriver - rmmod (stderr)").write(buffer, size); }))
            {
                APP_DEBUGGER << "loadWifiDriver: rmmod driver failed " << wifiDrivers[found_adapter].pszNetworkDriverPath << std::endl;
            }
        }

        bInsmodNeeded = true;
    }

    if(bInsmodNeeded)
    {
        if(!Poco::File(wifiDrivers[found_adapter].pszNetworkDriverPath).exists())
        {
            APP_DEBUGGER << "loadWifiDriver: insmod driver is not installed " << wifiDrivers[found_adapter].pszNetworkDriverPath << std::endl;
            return;
        }

        stream.str("");
        stream << "insmod " << wifiDrivers[found_adapter].pszNetworkDriverPath;
        if (!Util::watchProcess(stream.str(), _connectionEventFd,
                                [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::loadWifiDriver - insmod (stdout)").write(buffer, size); },
                                [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::loadWifiDriver - insmod (stderr)").write(buffer, size); }))
        {
            APP_LOGGER << "loadWifiDriver: insmod error " << stream.str() << std::endl;
        }
    }
}

void WirelessManager::ifup()
{
    loadWifiDriver();
    
    LoggerStreams logStreams;
    std::stringstream stream;

    if(interfaceName().empty())
    {
        APP_DEBUGGER << "ifup: unknown interface.. expecting " << NetworkInterfaces::findWifiInterface() << std::endl;
    }

    if(!interfaceName().empty())
    {
        stream.str("");
        stream << "/root/chaipcr/deploy/wifi/ifup.sh " << interfaceName();

        if (!Util::watchProcess(stream.str(), _connectionEventFd,
                                [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - ifup (stdout)").write(buffer, size); },
                                [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - ifup (stderr)").write(buffer, size); }))
        {
            APP_LOGGER << "ifup: ifup error " << std::endl;
            _connectionStatus = NotConnected;
            return;
        }
    }
}

void WirelessManager::ifdown()
{
    APP_DEBUGGER << "WirelessManager::ifdown " << interfaceName() << std::endl;

    NetworkInterfaces::ifdown(interfaceName());

    _connectionStatus = NotConnected;
    APP_DEBUGGER << "WirelessManager::ifdown done " << std::endl;
}

void WirelessManager::checkInterfaceStatus()
{
    APP_DEBUGGER << "WirelessManager::checkInterfaceStatus " << std::endl;

    while (_interfaceStatusThreadStatus == Working)
    {
        std::string interface = interfaceName();
        APP_DEBUGGER << "WirelessManager::checkInterfaceStatus interface " << interface << std::endl;

        if (interface.empty() || if_nametoindex(interface.c_str()) == 0)
        {
            setInterfaceName("");

            interface = NetworkInterfaces::findWifiInterface();
            APP_DEBUGGER << "WirelessManager::checkInterfaceStatus interface is now " << interface << std::endl;

            if (!interface.empty())
                setInterfaceName(interface);
        }

        if (!interface.empty())
        {
            if (_scanScheduleState)
                scan(interface);

            checkConnection(interface);
        }

        sleep(!interface.empty() ? 3 : 10);
    }

    APP_DEBUGGER << "WirelessManager::checkInterfaceStatus exit" <<  std::endl;
    _interfaceStatusThreadStatus = Idle;
}

void WirelessManager::scan(const std::string &interface)
{
    APP_DEBUGGER << "WirelessManager::scan " << interface << std::endl;

    std::stringstream stream;

    Util::watchProcess("iwlist " + interface + " scan", [&stream](const char *buffer, std::size_t size){ stream.write(buffer, size); }, Util::WatchProcessCallback(), true);

    std::map<std::string, ScanResult> resultMap;
    ScanResult result;

    while (stream.good())
    {
        std::string line;
        std::getline(stream, line);

        //APP_DEBUGGER << "WirelessManager::scan line " << line << std::endl;

        if (line.find("Cell ") != std::string::npos)
        {
            if (!result.ssid.empty())
            {
                auto it = resultMap.find(result.ssid);

                if (it != resultMap.end())
                {
                    if (it->second.quality < result.quality)
                        it->second = result;
                }
                else
                    resultMap.emplace(std::make_pair(result.ssid, result));
            }

            result = ScanResult();
        }
        else if (line.find("ESSID:") != std::string::npos)
        {
            result.ssid = line.substr(line.find("ESSID:") + 7); //Skip ESSID:"
            result.ssid.resize(result.ssid.size() - 1); //Skil " at the end
        }
        else if (line.find("Encryption key:") != std::string::npos)
        {
            if (line.find(":on") != std::string::npos)
                result.encryption = ScanResult::WepEncryption; //Assume that encryption is wep for now
        }
        else if (line.find("IE: ") != std::string::npos)
        {
            if (line.find("WPA Version 1") != std::string::npos)
                result.encryption = ScanResult::Wpa1PSKEcryption;
            else if (line.find("WPA2") != std::string::npos)
                result.encryption = ScanResult::Wpa2PSKEcryption;
        }
        else if (line.find("Authentication Suites ") != std::string::npos)
        {
            if (line.find("802.1x") != std::string::npos)
            {
                if (result.encryption == ScanResult::Wpa1PSKEcryption)
                    result.encryption = ScanResult::Wpa18021xEcryption;
                else
                    result.encryption = ScanResult::Wpa28021xEcryption;
            }
        }
        else if (line.find("Quality=") != std::string::npos)
        {
            std::string str = line.substr(line.find("Quality=") + 8);
            std::stringstream stream(str);

            stream >> result.quality;

            std::getline(stream, str, '='); //Skip "/100  Signal level="

            stream >> result.siganlLevel;
        }
    }

    if (!result.ssid.empty())
    {
        auto it = resultMap.find(result.ssid);

        if (it != resultMap.end())
        {
            if (it->second.quality < result.quality)// why only increasing 
                it->second = result;
        }
        else
            resultMap.emplace(std::make_pair(result.ssid, result));
    }

    {
        Poco::RWLock::ScopedWriteLock lock(_scanResultMutex);
        _scanResult.clear();

        for (auto it = resultMap.begin(); it != resultMap.end(); ++it)
            _scanResult.emplace_back(it->second);

        _scanTime = std::time(nullptr);
        _scanScheduleState = false;
    }
}

void WirelessManager::checkConnection(const std::string &interface)
{
    APP_DEBUGGER << "WirelessManager::checkConnection " << interface << std::endl;
    if (_connectionThreadState == HotspotActive )
    {
        APP_DEBUGGER << "Hotspot active" << std::endl;
        return;
    }

    NetworkInterfaces::InterfaceState state = NetworkInterfaces::getInterfaceState(interface);

    if (!state.isEmpty())
    {
        APP_DEBUGGER << "WirelessManager::checkConnection not empty " << state.flags << std::endl;
        APP_DEBUGGER << "WirelessManager::checkConnection not empty IFF_UP " << (int)(state.flags & IFF_UP) << std::endl;
        APP_DEBUGGER << "WirelessManager::checkConnection not empty state.addressState " << state.addressState<< std::endl;

        if (state.flags & IFF_UP && state.addressState)
        {
            _connectionStatus = Connected;
            _connectionTimeout = 0;
            APP_DEBUGGER << "WirelessManager::checkConnection connected" << std::endl;
        }
        else if (_connectionThreadState != Working && _connectionStatus != NotConnected && _connectionStatus != HotspotActive && std::time(nullptr) > _connectionTimeout) // should check for hotspot as well//
        {
            APP_DEBUGGER << "WirelessManager::checkConnection timeout" << std::endl;

            if (state.flags & IFF_UP)
                _connectionStatus = AuthenticationError;
            else if (_connectionStatus == Connecting)
                _connectionStatus = ConnectionError;
            else if (_connectionStatus != ConnectionError)
                _connectionStatus = NotConnected;
        }
    }
}
