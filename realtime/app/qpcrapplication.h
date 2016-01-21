#ifndef _QPCRSERVER_H_
#define _QPCRSERVER_H_

#include <Poco/Util/ServerApplication.h>

#include <signal.h>
#include <atomic>
#include <memory>
#include <exception>

class IControl;
class IThreadControl;
class DBControl;
class ExperimentController;
class WirelessManager;
class TimeChecker;
class UpdateManager;

// Class QPCRApplication
class QPCRApplication: public Poco::Util::ServerApplication
{
public:
    class MachineSettings
    {
    public:
        class Device
        {
        public:
            Device() { opticsChannels = 1; }

        public:
            std::size_t opticsChannels;
        }device;

        class Configuration
        {
        public:
            std::string version;
        }configuration;
    };

    inline static QPCRApplication& getInstance() { return static_cast<QPCRApplication&>(instance()); }

    inline bool isWorking() const { return _workState.load(); }
    inline void close() { _workState = false; }

    inline const MachineSettings& settings() const { return _settings; }

    inline std::shared_ptr<WirelessManager> wirelessManager() const { return _wirelessManager; }
    inline std::shared_ptr<UpdateManager> updateManager() const { return _updateManager; }

    inline void setException(std::exception_ptr exception) { _exception = exception; }

    void stopExperiment(const std::string &message);

    bool isMachinePaused() const;
    int getUserId(const std::string &token) const;

protected:
	//from ServerApplication
    void initialize(Poco::Util::Application &self);
    int main(const std::vector<std::string> &args);

private:
    void readDeviceFile();
    void readConfigurationFile();

    void initSignals();
    bool waitSignal() const;

private:
    sigset_t _signalsSet;

    std::atomic<bool> _workState;

    MachineSettings _settings;

    std::vector<std::shared_ptr<IControl>> _controlUnits;
    std::vector<std::shared_ptr<IThreadControl>> _threadControlUnits;
    std::shared_ptr<DBControl> _dbControl;
    std::shared_ptr<ExperimentController> _experimentController;
    std::shared_ptr<WirelessManager> _wirelessManager;
    std::shared_ptr<TimeChecker> _timeChecker;
    std::shared_ptr<UpdateManager> _updateManager;

    std::exception_ptr _exception;
};

#define qpcrApp QPCRApplication::getInstance()

#endif
