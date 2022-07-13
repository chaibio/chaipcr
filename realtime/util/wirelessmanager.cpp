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

void WirelessManager::connect()
{
    APP_LOGGER << "WirelessManager::connect " << interfaceName() << std::endl;

    if (!interfaceName().empty())
    {
        std::lock_guard<std::recursive_mutex> lock(_commandsMutex);

            APP_LOGGER << "WirelessManager::connect stopping " << interfaceName() << std::endl;
        stopCommands();

        _connectionStatus = Connecting;
        _connectionThreadState = Working;
        _connectionThread = std::thread(&WirelessManager::_connect, this);
    }
}

void WirelessManager::shutdown()
{
    APP_LOGGER << "WirelessManager::shutdown" << std::endl;
    if (!interfaceName().empty())
    {
        std::lock_guard<std::recursive_mutex> lock(_commandsMutex);

        stopCommands();

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
    APP_LOGGER << "WirelessManager::scanResult" << std::endl;

    Poco::RWLock::ScopedReadLock lock(_scanResultMutex);

    if (_scanTime + SCAN_CACHE_INTERVAL < std::time(nullptr))
        _scanResult.clear();

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
        APP_LOGGER << "WirelessManager::stopCommands" << std::endl;

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
}

void WirelessManager::_connect()
{
    APP_LOGGER << "WirelessManager::_connect " << std::endl;

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

        APP_LOGGER << "about to NetworkInterfaces::removeLeases " << std::endl;
        NetworkInterfaces::removeLeases(interface);

        _connectionStatus = Connecting;

        APP_LOGGER << "about to ifup " << std::endl;
        ifup();
        APP_LOGGER << "done ifup " << std::endl;
        APP_LOGGER << "done NetworkInterfaces::dhcpTimeout() " << NetworkInterfaces::dhcpTimeout() << std::endl;
        APP_LOGGER << "done CONNECTION_TIMEOUT_INTERVAL " << CONNECTION_TIMEOUT_INTERVAL << std::endl;

        _connectionTimeout = std::time(nullptr) + NetworkInterfaces::dhcpTimeout() + CONNECTION_TIMEOUT_INTERVAL;
        _connectionThreadState = Idle;
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "WirelessManager::_connect - exception occured:" << ex.what() << std::endl;

        _connectionStatus = ConnectionError;
    }
}

void WirelessManager::ifup()
{
    LoggerStreams logStreams;
    std::stringstream stream, lsusbstream, lsmodstream;
    int found_adapter=-1;
    bool bRmmodInsmod = true;

    stream << "/usr/bin/lsusb";
    if (Util::watchProcess(stream.str(), _connectionEventFd,
                            [&logStreams,&lsusbstream](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - lsusb (stdout)").write(buffer, size); lsusbstream.write(buffer, size); APP_LOGGER << "1" << std::endl; },
                            [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - lsusb (stderr)").write(buffer, size); APP_LOGGER << "2" << std::endl;}))
    {
        APP_LOGGER << "ifup: lsusb returns " << lsusbstream.str() << std::endl;
        APP_LOGGER << "3" << std::endl;
    }
    else
    {
        APP_LOGGER << "4" << std::endl;
        APP_LOGGER << "ifup: error calling lsusb" << std::endl;
    }
APP_LOGGER << "5" << std::endl;
    for(int adapter=0; found_adapter==-1 && wifiDrivers[adapter].pszNetworkDriverName!=nullptr; adapter++)
        for(int device=0; wifiDrivers[adapter].pszUSBID[device]!=nullptr; device++)
        {
            if( lsusbstream.str().find(wifiDrivers[adapter].pszUSBID[device]) != std::string::npos )
            {
                found_adapter = adapter;
                bRmmodInsmod = wifiDrivers[adapter].bRmmodInsmod;
                APP_LOGGER << "ifup: found the wifi adapter " << wifiDrivers[adapter].pszNetworkDriverName;
                APP_LOGGER << ", USBID " << wifiDrivers[adapter].pszUSBID[device] << std::endl;
                break;
            }
            //APP_LOGGER << "ifup: failed checking " << wifiDrivers[adapter].pszUSBID[device] << std::endl;
        }
APP_LOGGER << "6" << std::endl;
    if(found_adapter==-1)
    {
        APP_LOGGER << "ifup: failed detecting a wifi adapter" << std::endl;
        found_adapter = 0;
    }

    if(bRmmodInsmod)
    {
        stream.str("/sbin/lsmod");
        if (Util::watchProcess(stream.str(), _connectionEventFd,
                                [&logStreams,&lsmodstream](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - lsmod (stdout)").write(buffer, size); lsmodstream.write(buffer, size);APP_LOGGER << "7" << std::endl; },
                                [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - lsmod (stderr)").write(buffer, size); APP_LOGGER << "8" << std::endl;}))
        {
            APP_LOGGER << "ifup: lsmod returns " << lsmodstream.str() << std::endl;
            APP_LOGGER << "9" << std::endl;
        }
        else
        {
            APP_LOGGER << "10" << std::endl;
            APP_LOGGER << "ifup: error calling lsmod" << std::endl;
        }
    APP_LOGGER << "11" << std::endl;
        if( lsmodstream.str().find( wifiDrivers[found_adapter].pszNetworkDriverName ) != std::string::npos )
        {
            APP_LOGGER << "ifup: rmmod unloadding the wifi driver " << wifiDrivers[found_adapter].pszNetworkDriverName << std::endl;

            stream.str("");
            stream << "rmmod " << wifiDrivers[found_adapter].pszNetworkDriverName;

            if (!Util::watchProcess(stream.str(), _connectionEventFd,
                                    [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - rmmod (stdout)").write(buffer, size); APP_LOGGER << "12" << std::endl;},
                                    [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - rmmod (stderr)").write(buffer, size); APP_LOGGER << "13" << std::endl;}))
            {
                APP_LOGGER << "ifup: rmmod error removing " << wifiDrivers[found_adapter].pszNetworkDriverName << std::endl;
                _connectionStatus = NotConnected;
                return;
            }
            APP_LOGGER << "14" << std::endl;
            APP_LOGGER << "ifup: rmmod done " << wifiDrivers[found_adapter].pszNetworkDriverName << std::endl;
        }
        else
        {
            APP_LOGGER << "15" << std::endl;
            APP_LOGGER << "ifup: rmmod driver is not loaded " << wifiDrivers[found_adapter].pszNetworkDriverName << std::endl;
        }

        APP_LOGGER << "ifup: insmod about to re/add " << wifiDrivers[found_adapter].pszNetworkDriverName << std::endl;
        if(!Poco::File(wifiDrivers[found_adapter].pszNetworkDriverPath).exists())
        {
            APP_LOGGER << "16" << std::endl;
            APP_LOGGER << "ifup: insmod driver is not installed " << wifiDrivers[found_adapter].pszNetworkDriverPath << std::endl;
            return;
        }
        stream.str("");
        stream << "insmod " << wifiDrivers[found_adapter].pszNetworkDriverPath;
        APP_LOGGER << "ifup: insmod installing " << wifiDrivers[found_adapter].pszNetworkDriverName << std::endl;
    APP_LOGGER << "16-1" << std::endl;
        if (!Util::watchProcess(stream.str(), _connectionEventFd,
                                [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - insmod (stdout)").write(buffer, size); APP_LOGGER << "17" << std::endl;},
                                [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - insmod (stderr)").write(buffer, size); APP_LOGGER << "18" << std::endl;}))
        {
            APP_LOGGER << "ifup: insmod error " << std::endl;
            _connectionStatus = NotConnected;
            return;
        }
        APP_LOGGER << "19" << std::endl;
    }

    if(interfaceName().empty())
    {
        APP_LOGGER << "unknown interface.. expecting " << NetworkInterfaces::findWifiInterface() << std::endl;
    }

    if(!interfaceName().empty())
    {
        APP_LOGGER << "about to ifconfig up " << interfaceName() << std::endl;
        stream.str("");
        //stream << "/sbin/ifconfig " << interfaceName() << " up";
        stream << "/sbin/ifup " << interfaceName();
        APP_LOGGER << "ifup: about to call " << stream.str() << std::endl;

        if (!Util::watchProcess(stream.str(), _connectionEventFd,
                                [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - ifconfig up (stdout)").write(buffer, size); APP_LOGGER << "17" << std::endl;},
                                [&logStreams](const char *buffer, std::size_t size){ logStreams.stream("WirelessManager::ifup - ifconfig up (stderr)").write(buffer, size); APP_LOGGER << "18" << std::endl;}))
        {
            APP_LOGGER << "ifup: ifconfig up error " << std::endl;
            _connectionStatus = NotConnected;
            return;
        }
        else
        {
            APP_LOGGER << "ifup: ifconfig up ok " << std::endl;
        }
    }
    APP_LOGGER << "ifup: done " << std::endl;
}

void WirelessManager::ifdown()
{
    APP_LOGGER << "WirelessManager::ifdown " << interfaceName() << std::endl;

    NetworkInterfaces::ifdown(interfaceName());

    _connectionStatus = NotConnected;
    APP_LOGGER << "WirelessManager::ifdown done " << std::endl;
}

void WirelessManager::checkInterfaceStatus()
{
        APP_LOGGER << "WirelessManager::checkInterfaceStatus " << std::endl;

    while (_interfaceStatusThreadStatus == Working)
    {
        std::string interface = interfaceName();
        APP_LOGGER << "WirelessManager::checkInterfaceStatus interface " << interface << std::endl;

        if (interface.empty() || if_nametoindex(interface.c_str()) == 0)
        {
            setInterfaceName("");

            interface = NetworkInterfaces::findWifiInterface();
            APP_LOGGER << "WirelessManager::checkInterfaceStatus interface is now " << interface << std::endl;

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

    APP_LOGGER << "WirelessManager::checkInterfaceStatus exit" <<  std::endl;
    _interfaceStatusThreadStatus = Idle;
}

void WirelessManager::scan(const std::string &interface)
{
    APP_LOGGER << "WirelessManager::scan " << interface << std::endl;

    std::stringstream stream;

    Util::watchProcess("iwlist " + interface + " scan", [&stream](const char *buffer, std::size_t size){ stream.write(buffer, size); }, Util::WatchProcessCallback(), true);

    std::map<std::string, ScanResult> resultMap;
    ScanResult result;

    while (stream.good())
    {
        std::string line;
        std::getline(stream, line);

        APP_LOGGER << "WirelessManager::scan line " << line << std::endl;

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
            if (it->second.quality < result.quality)
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
    APP_LOGGER << "WirelessManager::checkConnection" << interface << std::endl;

    NetworkInterfaces::InterfaceState state = NetworkInterfaces::getInterfaceState(interface);

    if (!state.isEmpty())
    {
            APP_LOGGER << "WirelessManager::checkConnection not empty " << state.flags << std::endl;
            APP_LOGGER << "WirelessManager::checkConnection not empty IFF_UP " << (int)(state.flags & IFF_UP) << std::endl;
            APP_LOGGER << "WirelessManager::checkConnection not empty state.addressState " << state.addressState<< std::endl;
            

        if (state.flags & IFF_UP && state.addressState)
        {
            _connectionStatus = Connected;
            _connectionTimeout = 0;
                APP_LOGGER << "WirelessManager::checkConnection connected" << std::endl;

        }
        else if (_connectionThreadState != Working && std::time(nullptr) > _connectionTimeout)
        {
            APP_LOGGER << "WirelessManager::checkConnection timeout" << std::endl;

            if (state.flags & IFF_UP)
                _connectionStatus = AuthenticationError;
            else if (_connectionStatus == Connecting)
                _connectionStatus = ConnectionError;
            else if (_connectionStatus != ConnectionError)
                _connectionStatus = NotConnected;
        }
    }
}
