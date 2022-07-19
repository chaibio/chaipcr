/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef NETWORKCONFIGURATOR_H
#define NETWORKCONFIGURATOR_H

#include <vector>
#include <string>
#include <map>
#include <ctime>

namespace NetworkInterfaces
{
    class InterfaceSettings
    {
    public:
        InterfaceSettings(): autoConnect(true) {}

        inline bool isEmpty() const noexcept { return interface.empty(); }

        std::string toString() const;

    public:
        std::string interface;
        std::string type;
        std::string hotspot_ssid;
        std::string hotspot_key;
        bool autoConnect;

        std::map<std::string, std::string> arguments;
    };

    class InterfaceState
    {
    public:
        InterfaceState(): flags(0), addressState(false) {}

        inline bool isEmpty() const noexcept { return interface.empty(); }
        inline bool hasAddress() const noexcept { return addressState; }

    public:
        std::string interface;

        unsigned int flags;

        std::string address;
        std::string maskAddress;
        std::string broadcastAddress;
        std::string macAddress;

        bool addressState;
    };

    std::vector<std::string> getAllInterfaces();

    InterfaceSettings readInterfaceSettings(const std::string &filePath, const std::string &interfaceName);
    void writeInterfaceSettings(const std::string &filePath, const InterfaceSettings &interface);
    void removeInterfaceSettings(const std::string &filePath, const std::string &interface);

    void ifup(const std::string &interfaceName);
    void ifdown(const std::string &interfaceName);

    InterfaceState getInterfaceState(const std::string &interfaceName);

    void removeLeases(const std::string &interfaceName);

    std::time_t dhcpTimeout();

    std::string findWifiInterface();
}

#endif // NETWORKCONFIGURATOR_H
