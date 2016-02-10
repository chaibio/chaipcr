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

#include <iwlib.h>
#include <unistd.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <sys/eventfd.h>

WirelessManager::WirelessManager(const std::string &interfaceName)
{
    _connectionEventFd = eventfd(0, EFD_NONBLOCK);

    if (_connectionEventFd == -1)
        throw std::system_error(errno, std::generic_category(), "Wireless manager: unable to create event fd -");

    _interfaceName = interfaceName;
    _connectionThreadState = Idle;
    _connectionStatus = NotConnected;

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

void WirelessManager::connect()
{
    std::lock_guard<std::recursive_mutex> lock(_commandsMutex);

    stopCommands();

    _connectionThreadState = Working;
    _connectionThread = std::thread(&WirelessManager::_connect, this);
}

void WirelessManager::shutdown()
{
    std::lock_guard<std::recursive_mutex> lock(_commandsMutex);

    stopCommands();

    _shutdownThread = std::thread(&WirelessManager::ifdown, this);
}

std::string WirelessManager::getCurrentSsid() const
{
    std::string ssid;
    int iwSocket = iw_sockets_open();

    if (iwSocket != -1)
    {
        char buffer[IW_ESSID_MAX_SIZE + 2];
        memset(buffer, 0, sizeof(buffer));

        iwreq req;
        req.u.essid.pointer = buffer;
        req.u.essid.length = IW_ESSID_MAX_SIZE + 2;
        req.u.essid.flags = 0;

        if (iw_get_ext(iwSocket, _interfaceName.c_str(), SIOCGIWESSID, &req) == 0)
            ssid = buffer;

        iw_sockets_close(iwSocket);
    }
    else
        APP_LOGGER << "WirelessManager::getCurrentSsid - unable to open socket: " << std::strerror(errno) << std::endl;

    return ssid;
}

std::vector<std::string> WirelessManager::scanResult() const
{
    std::lock_guard<std::mutex> lock(_scanResultMutex);

    return _scanResult;
}

void WirelessManager::stopCommands()
{
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
    try
    {
        if (if_nametoindex(_interfaceName.c_str()) == 0)
            throw std::system_error(errno, std::generic_category(), "WirelessManager::_connect - unable to get interface index (" + _interfaceName + "):");

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

        ifup();

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
    Poco::LogStream logStream(Logger::get());

    std::stringstream stream;
    stream << "ifup " << _interfaceName;

    if (Util::watchProcess(stream.str(), _connectionEventFd, [&logStream](const char buffer[]){ logStream << "WirelessManager::ifup - ifup:" << buffer << std::endl; }))
    {
        NetworkInterfaces::InterfaceState state = NetworkInterfaces::getInterfaceState(_interfaceName);

        if (state.isEmpty() || !(state.flags & IFF_UP))
            _connectionStatus = ConnectionError;
    }
    else
        _connectionStatus = NotConnected;
}

void WirelessManager::ifdown()
{
    NetworkInterfaces::ifdown(_interfaceName);

    _connectionStatus = NotConnected;
}

void WirelessManager::checkInterfaceStatus()
{
    int iwSocket = iw_sockets_open();
    bool showRangeError = true;

    if (iwSocket != -1)
    {
        iwrange range;

        while (_interfaceStatusThreadStatus == Working)
        {
            if (iw_get_range_info(iwSocket, _interfaceName.c_str(), &range) == 0)
            {
                showRangeError = true;

                if (_interfaceStatusThreadStatus != Working)
                    break;

                checkConnection();

                if (_interfaceStatusThreadStatus != Working)
                    break;

                scan(iwSocket, range);

                if (_interfaceStatusThreadStatus != Working)
                    break;
            }
            else if (showRangeError)
            {
                showRangeError = false;
                APP_LOGGER << "WirelessManager::checkInterfaceStatus - unable to get interface range info: " << std::strerror(errno) << std::endl;
            }

            sleep(1);
        }

        iw_sockets_close(iwSocket);
    }
    else
        APP_LOGGER << "WirelessManager::checkInterfaceStatus - unable to open iw socket: " << std::strerror(errno) << std::endl;

    _interfaceStatusThreadStatus = Idle;
}

void WirelessManager::checkConnection()
{
    NetworkInterfaces::InterfaceState state = NetworkInterfaces::getInterfaceState(_interfaceName);

    if (!state.isEmpty())
    {
        if (state.flags & IFF_UP)
        {
            if (state.flags & IFF_RUNNING)
                _connectionStatus = Connected;
            else if (_connectionThreadState != Working && _connectionStatus == Connecting)
                _connectionStatus = AuthenticationError;
        }
        else if (_connectionThreadState != Working)
        {
            if (_connectionStatus == Connecting)
                _connectionStatus = ConnectionError;
            else if (_connectionStatus != ConnectionError)
                _connectionStatus = NotConnected;
        }
    }
}

void WirelessManager::scan(int iwSocket, const iw_range &range)
{
    wireless_scan_head scanHead;

    if (iw_scan(iwSocket, const_cast<char*>(_interfaceName.c_str()), range.we_version_compiled, &scanHead) == 0) //For some reason in iw_scan they forgot to put const
    {
        std::vector<std::string> result;

        for (wireless_scan *scanResult = scanHead.result; scanResult; scanResult = scanResult->next)
        {
            std::string ssid(scanResult->b.essid);

            if (!ssid.empty())
                result.emplace_back(std::move(ssid));
        }

        {
            std::lock_guard<std::mutex> lock(_scanResultMutex);
            _scanResult = std::move(result);
        }
    }
    else
        APP_LOGGER << "WirelessManager::scan - unable to scan interface: " << std::strerror(errno) << std::endl;
}
