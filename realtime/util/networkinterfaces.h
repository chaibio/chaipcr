#ifndef NETWORKCONFIGURATOR_H
#define NETWORKCONFIGURATOR_H

#include <vector>
#include <string>
#include <map>

namespace NetworkInterfaces
{
    class InterfaceSettings
    {
    public:
        inline bool isEmpty() const noexcept { return interface.empty(); }

        std::string toString() const;

    public:
        std::string interface;
        std::string type;

        std::map<std::string, std::string> arguments;
    };

    class InterfaceState
    {
    public:
        InterfaceState(): flags(0) {}

        inline bool isEmpty() const noexcept { return interface.empty(); }

    public:
        std::string interface;

        unsigned int flags;

        std::string address;
        std::string maskAddress;
        std::string broadcastAddress;
    };

    typedef std::map<std::string, NetworkInterfaces::InterfaceSettings> InterfaceSettingsMap;

    std::vector<std::string> getAllInterfaces();

    InterfaceSettingsMap readInterfaceSettings(const std::string &filePath);
    InterfaceSettings readInterfaceSettings(const std::string &filePath, const std::string &interfaceName);

    void writeInterfaceSettings(const std::string &filePath, const InterfaceSettings &interface);

    void ifup(const std::string &interfaceName);
    void ifdown(const std::string &interfaceName);

    InterfaceState getInterfaceState(const std::string &interfaceName);
}

#endif // NETWORKCONFIGURATOR_H
