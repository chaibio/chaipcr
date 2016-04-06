#ifndef WIRELESSMANAGER_H
#define WIRELESSMANAGER_H

#include <string>
#include <thread>
#include <mutex>
#include <atomic>
#include <vector>

#include <boost/noncopyable.hpp>

#include <Poco/RWLock.h>

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
            Wpa1Ecryption,
            Wpa2Ecryption
        };

        ScanResult(): encryption(NoEncryption) {}

    public:
        std::string ssid;
        Encryption encryption;
    };

    enum ConnectionStatus
    {
        NotConnected,
        Connecting,
        ConnectionError,
        AuthenticationError,
        Connected
    };

    WirelessManager();
    ~WirelessManager();

    std::string interfaceName() const;

    void connect();
    void shutdown();

    std::string getCurrentSsid() const;

    std::vector<ScanResult> scanResult() const;

    inline ConnectionStatus connectionStatus() const noexcept { return _connectionStatus; }

private:
    void setInterfaceName(const std::string &name);

    void stopCommands();

    void _connect();

    void ifup();
    void ifdown();

    void checkInterfaceStatus(); //perform scan and check if it is connected
    void checkConnection();
    bool scan(const std::string &interface);

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

    std::thread _connectionThread;
    std::atomic<OperationState> _connectionThreadState;
    int _connectionEventFd;

    std::thread _shutdownThread;

    std::thread _interfaceStatusThread;
    std::atomic<OperationState> _interfaceStatusThreadStatus;

    std::atomic<ConnectionStatus> _connectionStatus;

    std::vector<ScanResult> _scanResult;
    mutable Poco::RWLock _scanResultMutex;
};

#endif // WIRELESSMANAGER_H
