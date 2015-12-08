#ifndef WIRELESSMANAGER_H
#define WIRELESSMANAGER_H

#include <string>
#include <thread>
#include <mutex>
#include <atomic>
#include <vector>

#include <boost/noncopyable.hpp>

struct iw_range;

class WirelessManager : boost::noncopyable
{
public:
    enum ConnectionStatus
    {
        NotConnected,
        Connecting,
        ConnectionError,
        AuthenticationError,
        Connected
    };

    WirelessManager(const std::string &interfaceName);
    ~WirelessManager();

    inline const std::string& interfaceName() const noexcept { return _interfaceName; }

    void connect(const std::string &ssid, const std::string &passkey);
    void shutdown();

    std::string getCurrentSsid() const;

    std::vector<std::string> scanResult() const;

    inline ConnectionStatus connectionStatus() const noexcept { return _connectionStatus; }

private:
    void stopCommands();

    void _connect(std::string ssid, std::string passkey);

    void setCredentials(const std::string &ssid, const std::string &passkey);
    void generateWpaFile(const std::string &ssid, const std::string &passkey);

    void ifup();
    void ifdown();

    void checkInterfaceStatus(); //perform scan and check if it is connected
    void checkConnection();
    void scan(int iwSocket, const iw_range &range);

private:
    enum OperationState
    {
        Idle,
        Working,
        Stopping
    };

    std::string _interfaceName;

    std::recursive_mutex _commandsMutex;

    std::thread _connectionThread;
    std::atomic<OperationState> _connectionThreadState;
    int _connectionEventFd;

    std::thread _shutdownThread;

    std::thread _interfaceStatusThread;
    std::atomic<OperationState> _interfaceStatusThreadStatus;

    std::atomic<ConnectionStatus> _connectionStatus;

    std::vector<std::string> _scanResult;
    mutable std::mutex _scanResultMutex;
};

#endif // WIRELESSMANAGER_H
