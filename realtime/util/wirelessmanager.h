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

#ifndef WIRELESSMANAGER_H
#define WIRELESSMANAGER_H

#include <string>
#include <thread>
#include <mutex>
#include <atomic>
#include <vector>

#include <boost/noncopyable.hpp>

#include <Poco/RWLock.h>
#include "networkinterfaces.h"

struct iw_range;

class WirelessManager : boost::noncopyable
{
public:
    class ScanResult
    {
    public:
        enum Encryption
        {
            NoEncryption,
            WepEncryption,
            Wpa1PSKEcryption,
            Wpa18021xEcryption,
            Wpa2PSKEcryption,
            Wpa28021xEcryption
        };

        ScanResult(): encryption(NoEncryption), quality(0), siganlLevel(0) {}

    public:
        std::string ssid;
        Encryption encryption;

        unsigned quality;
        int siganlLevel;
    };

    enum ConnectionStatus
    {
        NotConnected,
        Connecting,
        ConnectionError,
        AuthenticationError,
        Connected,
        HotspotActive
    };

    WirelessManager();
    ~WirelessManager();

    std::string interfaceName() const;

    // wifi
    void connect();
    void shutdown();

    // hotspot
    void hotspotSelect();
    void wifiSelect();
    bool hotspotActivate();
    void hotspotDeactivate();

    NetworkInterfaces::InterfaceSettings& hotspotSettings() {return hotspot_settings;};

    std::string getCurrentSsid() const;
    std::vector<ScanResult> scanResult();

    inline ConnectionStatus connectionStatus() const noexcept { return _connectionStatus; }

private:
    void setInterfaceName(const std::string &name);
    void loadWifiDriver();

    void stopCommands();

    void _connect();
    void _hotspotSelect();
    void _wifiSelect();
    void _hotspotActivate();
    void _hotspotDeactivate();

    void ifup();
    void ifdown();

    void checkInterfaceStatus();
    void scan(const std::string &interface);
    void checkConnection(const std::string &interface);

public:
    static bool hotspotRetrieveInfo(std::string& interfacename, std::string& hotspot_ssid, std::string& hotspot_key );
    bool isHotspotActive();


private:
    enum OperationState
    {
        Idle,
        Working,
        Stopping
    };

    std::string _interfaceName;
    mutable Poco::RWLock _interfaceNameMutex;

    std::recursive_mutex _commandsMutex;

    std::thread _connectionThread, _selectionThread, _hotspotThread;
    std::atomic<OperationState> _connectionThreadState;
    int _connectionEventFd;
    
    NetworkInterfaces::InterfaceSettings hotspot_settings;

    std::thread _shutdownThread;

    std::thread _interfaceStatusThread;
    std::atomic<OperationState> _interfaceStatusThreadStatus;

    std::atomic<ConnectionStatus> _connectionStatus;
    std::atomic<std::time_t> _connectionTimeout;

    std::vector<ScanResult> _scanResult;
    std::time_t _scanTime;
    std::atomic<bool> _scanScheduleState;
    mutable Poco::RWLock _scanResultMutex;
};

#endif // WIRELESSMANAGER_H
