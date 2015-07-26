#include "wirelessmanager.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <iostream>
#include <sstream>
#include <stdexcept>
#include <system_error>

#include <iwlib.h>
#include <poll.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/eventfd.h>

WirelessManager::WirelessManager(const std::string &interfaceName)
{
    if (if_nametoindex(interfaceName.c_str()) == 0)
        throw std::system_error(errno, std::generic_category(), "WirelessManager::WirelessManager - unable to get interface index (" + interfaceName + "):");

    _connectionEventFd = eventfd(0, EFD_NONBLOCK);

    if (_connectionEventFd == -1)
        throw std::system_error(errno, std::generic_category(), "WirelessManager::WirelessManager - unable to create event fd:");

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

void WirelessManager::connect(const std::string &ssid, const std::string &passkey)
{
    std::lock_guard<std::recursive_mutex> lock(_commandsMutex);

    stopCommands();

    _connectionThreadState = Working;
    _connectionThread = std::thread(&WirelessManager::_connect, this, std::string(ssid), std::string(passkey));
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
        std::cout << "WirelessManager::getCurrentSsid - unable to open socket: " << std::strerror(errno) << '\n';

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

void WirelessManager::_connect(std::string ssid, std::string passkey)
{
    try
    {
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

        generateWpaFile(ssid, passkey);

        if (_connectionThreadState != Working)
        {
            _connectionThreadState = Idle;
            return;
        }

        ifup();
    }
    catch (const std::exception &ex)
    {
        std::cout << "WirelessManager::_connect - exception occured:" << ex.what() << '\n';

        _connectionStatus = ConnectionError;
    }

    _connectionThreadState = Idle;
}

void WirelessManager::generateWpaFile(const std::string &ssid, const std::string &passkey)
{
    std::stringstream stream;
    stream << "wpa_passphrase \"" << ssid << "\" \"" << passkey << "\" > ./qpcr_wpa_config.conf";

    system(stream.str().c_str());
}

void WirelessManager::ifup()
{
    _connectionStatus = Connecting;

    int processPipes[2] = {-1};

    if (pipe(processPipes) == -1)
        throw std::system_error(errno, std::generic_category(), "WirelessManager::ifup - unable to create pipes:");

    pid_t pid = vfork();

    if (pid == -1)
    {
        close(processPipes[0]);
        close(processPipes[1]);

        throw std::system_error(errno, std::generic_category(), "WirelessManager::ifup - unable to fork:");
    }

    if (pid == 0) //Child process
    {
        if (processPipes[1] != fileno(stdout))
        {
            dup2(processPipes[1], fileno(stdout));
            close(processPipes[1]);
        }

        close(processPipes[0]);

        std::stringstream stream;
        stream << "ifup " << _interfaceName;

        execl("/bin/sh", "sh", "-c", stream.str().c_str(), NULL);
        _exit(127);

        //It will never reach this line
    }

    close(processPipes[1]);

    bool processFinished = false;

    pollfd fdArray[2];
    fdArray[0].fd = processPipes[0];
    fdArray[0].events = POLLIN | POLLPRI;
    fdArray[0].revents = 0;

    fdArray[1].fd = _connectionEventFd;
    fdArray[1].events = POLLIN | POLLPRI;
    fdArray[1].revents = 0;

    while (poll(fdArray, 2, -1) > 0)
    {
        if (fdArray[0].revents > 0)
        {
            if (fdArray[0].revents & POLLIN || fdArray[0].revents & POLLPRI)
            {
                //There won't be any output since ifup doens't wirte to stdout. Instead it will write just to current session and to /var/log/syslog
            }
            else if (fdArray[0].revents & POLLHUP)
            {
                processFinished = true;
                break;
            }
            else if (fdArray[0].revents & POLLNVAL || fdArray[0].revents & POLLERR)
                break;
        }
        else
        {
            uint64_t i = 0;
            read(_connectionEventFd, &i, sizeof(i));

            break;
        }

        fdArray[0].revents = 0;
        fdArray[1].revents = 0;
    }

    close(processPipes[0]);

    if (processFinished)
    {
        int status = -1;
        pid = waitpid(pid, &status, 0);

        if (pid != -1 && status == 0)
        {
            ifaddrs *interfaces = nullptr;

            if (getifaddrs(&interfaces) == 0)
            {
                for (ifaddrs *interface = interfaces; interface; interface = interface->ifa_next)
                {
                    if (interface->ifa_name == _interfaceName)
                    {
                        if (!(interface->ifa_flags & IFF_UP))
                            _connectionStatus = ConnectionError;

                        break;
                    }
                }

                freeifaddrs(interfaces);
            }
            else
                throw std::system_error(errno, std::generic_category(), "WirelessManager::ifup - unable to get interfaces:");
        }
        else
            throw std::runtime_error("WirelessManager::ifup - unknown error occured upon watching the ifup process.");
    }
    else
    {
        kill(pid, SIGTERM);

        if (fdArray[1].revents == 0)
            throw std::runtime_error("WirelessManager::ifup - unknown error occured upon watching the ifup process.");
        else
            _connectionStatus = NotConnected;
    }
}

void WirelessManager::ifdown()
{
    std::stringstream stream;
    stream << "ifdown " << _interfaceName;

    system(stream.str().c_str());

    std::remove("./qpcr_wpa_config.conf");

    _connectionStatus = NotConnected;
}

void WirelessManager::checkInterfaceStatus()
{
    int iwSocket = iw_sockets_open();

    if (iwSocket != -1)
    {
        iwrange range;

        if (iw_get_range_info(iwSocket, _interfaceName.c_str(), &range) == 0)
        {

            while (_interfaceStatusThreadStatus == Working)
            {
                checkConnection();

                if (_interfaceStatusThreadStatus != Working)
                    break;

                scan(iwSocket, range);

                if (_interfaceStatusThreadStatus != Working)
                    break;

                sleep(1); //Replace it with std::this_thread::sleep_for when BBB will have newer gcc
            }
        }
        else
            std::cout << "WirelessManager::checkInterfaceStatus - unable to get interface range info: " << std::strerror(errno) << '\n';

        iw_sockets_close(iwSocket);
    }
    else
        std::cout << "WirelessManager::checkInterfaceStatus - unable to open iw socket: " << std::strerror(errno) << '\n';

    _interfaceStatusThreadStatus = Idle;
}

void WirelessManager::checkConnection()
{
    ifaddrs *interfaces = nullptr;

    if (getifaddrs(&interfaces) == 0)
    {
        for (ifaddrs *interface = interfaces; interface; interface = interface->ifa_next)
        {
            if (interface->ifa_name == _interfaceName)
            {
                if (interface->ifa_flags & IFF_UP)
                {
                    if (interface->ifa_flags & IFF_RUNNING)
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

                break;
            }
        }

        freeifaddrs(interfaces);
    }
    else
        std::cout << "WirelessManager::checkConnection - unable to get interfaces: " << std::strerror(errno) << '\n';
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
        std::cout << "WirelessManager::scan - unable to scan interface: " << std::strerror(errno) << '\n';
}
