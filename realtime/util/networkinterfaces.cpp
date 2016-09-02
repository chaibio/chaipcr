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

#include "networkinterfaces.h"
#include "util.h"
#include "logger.h"

#include <fstream>
#include <sstream>
#include <iomanip>
#include <system_error>

#include <cstring>

#include <unistd.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>

std::string getMacAddress(const std::string &interface);

namespace NetworkInterfaces
{

std::string InterfaceSettings::toString() const
{
    std::stringstream stream;

    if (autoConnect)
        stream << "auto " << interface << '\n';

    stream << "iface " << interface << " inet " << type << '\n';

    for (std::map<std::string, std::string>::const_iterator it = arguments.begin(); it != arguments.end(); ++it)
        stream << "     " << it->first << ' ' << it->second << '\n';

    return stream.str();
}

std::vector<std::string> getAllInterfaces()
{
    std::vector<std::string> interfaces;
    ifaddrs *addresses = nullptr;

    if (getifaddrs(&addresses) == 0)
    {
        for (ifaddrs *address = addresses; address; address = address->ifa_next)
        {
            if (address->ifa_addr && address->ifa_addr->sa_family == AF_PACKET)
                interfaces.emplace_back(address->ifa_name);
        }

        freeifaddrs(addresses);
    }
    else
        throw std::system_error(errno, std::generic_category(), "Network error: unable to read interfaces -");

    return interfaces;
}

InterfaceSettingsMap readInterfaceSettings(const std::string &filePath)
{
    std::fstream file(filePath);

    if (!file.is_open())
        throw std::system_error(errno, std::generic_category(), "Network error: unable to read file " + filePath + " -");

    std::map<std::string, InterfaceSettings> interfaces;
    InterfaceSettings currentInterface;

    while (file.good())
    {
        std::string line;
        std::getline(file, line);

        if (line.empty())
            continue;

        if (line.find("iface") == 0)
        {
            if (!currentInterface.interface.empty())
            {
                interfaces[currentInterface.interface] = currentInterface;
                currentInterface = InterfaceSettings();
            }

            std::size_t pos = line.find(' ', 6);
            currentInterface.interface = line.substr(6, pos - 6);

            pos = line.find(' ', pos + 1) + 1;
            currentInterface.type = line.substr(pos);
        }
        else if (!currentInterface.interface.empty() && (line.substr(0, 4) == std::string("    ") || line.at(0) == '\t'))
        {
            if (line.substr(0, 4) == std::string("    "))
                line = line.substr(4);
            else
                line = line.substr(1);

            currentInterface.arguments[line.substr(0, line.find(' '))] = line.substr(line.find(' ') + 1);
        }
    }

    if (!currentInterface.interface.empty())
        interfaces[currentInterface.interface] = currentInterface;

    return interfaces;
}

InterfaceSettings readInterfaceSettings(const std::string &filePath, const std::string &interfaceName)
{
    std::fstream file(filePath);

    if (!file.is_open())
        throw std::system_error(errno, std::generic_category(), "Network error: unable to read file " + filePath + " -");

    InterfaceSettings interface;

    while (file.good())
    {
        std::string line;
        std::getline(file, line);

        if (line.empty() || line.at(0) == '#')
            continue;

        if (line.find("iface") == 0)
        {
            if (!interface.interface.empty())
                break;

            std::size_t pos = line.find(' ', 6);
            interface.interface = line.substr(6, pos - 6);

            if (interface.interface != interfaceName)
            {
                interface.interface.clear();
                continue;
            }

            pos = line.find(' ', pos + 1) + 1;
            interface.type = line.substr(pos);
        }
        else if (line == "auto " + interfaceName)
            interface.autoConnect = true;
        else if (!interface.interface.empty() && (line.substr(0, 4) == std::string("    ") || line.at(0) == '\t'))
        {
            while (line.front() == ' ')
                line = line.substr(1);

            interface.arguments[line.substr(0, line.find(' '))] = line.substr(line.find(' ') + 1);
        }
    }

    return interface;
}

void writeInterfaceSettings(const std::string &filePath, const InterfaceSettings &interface)
{
    std::fstream file(filePath);

    if (!file.is_open())
        throw std::system_error(errno, std::generic_category(), "Network error: unable to write file " + filePath + " -");

    std::string content;
    std::string line;
    bool skip = false;

    while (file.good())
    {
        std::getline(file, line);

        if (line.find("iface") == 0)
        {
            if (interface.interface == line.substr(6, line.find(' ', 6) - 6))
            {
                skip = true;
                continue;
            }
            else
                skip = false;
        }
        else if (line == "auto " + interface.interface)
            continue;
        else if (skip && !line.empty() && (line.substr(0, 4) == std::string("    ") || line.at(0) == '\t'))
            continue;

        content += line + '\n';
    }

    content += '\n' + interface.toString();

    while (content.find("\n\n\n") != std::string::npos)
        content.replace(content.find("\n\n\n"), 3, "\n\n");

    file.close();
    file.open(filePath, std::fstream::out | std::fstream::trunc);
    file << content;
}

void ifup(const std::string &interfaceName)
{
    std::stringstream stream;
    stream << "ifup " << interfaceName;

    LoggerStreams streams;

    Util::watchProcess(stream.str(), [&interfaceName, &streams](const char *buffer, std::size_t size){ streams.stream("NetworkInterfaces::ifup - " + interfaceName + " (stdout)").write(buffer, size); },
                                     [&interfaceName, &streams](const char *buffer, std::size_t size){ streams.stream("NetworkInterfaces::ifup - " + interfaceName + " (stderr)").write(buffer, size); });
}

void ifdown(const std::string &interfaceName)
{
    std::stringstream stream;
    stream << "ifdown " << interfaceName;

    LoggerStreams streams;

    Util::watchProcess(stream.str(), [&interfaceName, &streams](const char *buffer, std::size_t size){ streams.stream("NetworkInterfaces::ifdown - " + interfaceName + " (stdout)").write(buffer, size); },
                                     [&interfaceName, &streams](const char *buffer, std::size_t size){ streams.stream("NetworkInterfaces::ifdown - " + interfaceName + " (stderr)").write(buffer, size); });
}

InterfaceState getInterfaceState(const std::string &interfaceName)
{
    InterfaceState state;

    if (!interfaceName.empty())
    {
        ifaddrs *interfaces = nullptr;

        if (getifaddrs(&interfaces) == 0)
        {
            try
            {
                for (ifaddrs *interface = interfaces; interface; interface = interface->ifa_next)
                {
                    if (interface->ifa_name == interfaceName)
                    {
                        state.interface = interfaceName;
                        state.macAddress = getMacAddress(interfaceName);
                        state.flags = interface->ifa_flags;

                        if (reinterpret_cast<sockaddr_in*>(interface->ifa_addr)->sin_family == AF_INET)
                        {
                            state.address = inet_ntoa(reinterpret_cast<sockaddr_in*>(interface->ifa_addr)->sin_addr);
                            state.maskAddress = inet_ntoa(reinterpret_cast<sockaddr_in*>(interface->ifa_netmask)->sin_addr);
                            state.broadcastAddress = inet_ntoa(reinterpret_cast<sockaddr_in*>(interface->ifa_broadaddr)->sin_addr);
                            state.addressState = true;

                            break;
                        }
                        else
                            state.addressState = false;
                    }
                }
            }
            catch (...)
            {
                freeifaddrs(interfaces);

                throw;
            }

            freeifaddrs(interfaces);
        }
        else
            throw std::system_error(errno, std::generic_category(), "Network error: unable to read interfaces -");
    }

    return state;
}

void removeLease(const std::string &interfaceName)
{
    std::remove(("/var/lib/dhcp/dhclient." + interfaceName + ".leases").c_str());
}

}

std::string getMacAddress(const std::string &interface)
{
    int socket = ::socket(PF_INET, SOCK_DGRAM, 0);

    if (socket == -1)
        throw std::system_error(errno, std::generic_category(), "Network error: unable to open a device socket -");

    ifreq request;
    memset(&request, 0, sizeof(request));
    strcpy(request.ifr_name, interface.c_str());

    if (ioctl(socket, SIOCGIFHWADDR, &request) == -1)
    {
        close(socket);

        throw std::system_error(errno, std::generic_category(), "Network error: unable to get a hardware address of an interface \"" + interface + "\" -");
    }

    close(socket);

    std::stringstream stream;
    stream << std::hex << std::setfill('0');

    for (int i = 0; i < 6; ++i)
    {
        stream << std::setw(2) << static_cast<unsigned int>(static_cast<unsigned char>(request.ifr_hwaddr.sa_data[i]));

        if (i < 5)
            stream << ':';
    }

    return stream.str();
}
