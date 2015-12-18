#ifndef EXPERIMENTCONTROLLER_H
#define EXPERIMENTCONTROLLER_H

#include "instance.h"
#include "experiment.h"

#include <atomic>
#include <vector>
#include <memory>
#include <boost/date_time/posix_time/ptime.hpp>

class DBControl;
class Settings;
class MachineSettings;
class TemperatureLog;

namespace Poco { class Timer; class RWLock; }

class ExperimentController : public Instance<ExperimentController>
{
public:
    class LogsSettings
    {
    public:
        LogsSettings()
        {
            debugMode = false;

            temperatureLogsState = false;
            debugTemperatureLogsState = false;

            startTime = boost::posix_time::not_a_date_time;
        }

    public:
        std::atomic<bool> debugMode;

        std::atomic<bool> temperatureLogsState;
        std::atomic<bool> debugTemperatureLogsState;

        boost::posix_time::ptime startTime;
    };

    enum MachineState
    {
        IdleMachineState,
        LidHeatingMachineState,
        RunningMachineState,
        PausedMachineState,
        CompleteMachineState
    };

    enum StartingResult
    {
        Started,
        ExperimentNotFound,
        ExperimentUsed,
        LidIsOpen,
        MachineRunning
    };

    enum ThermalState
    {
        IdleThermalState,
        HoldingThermalState,
        HeatingThermalState,
        CoolingThermalState
    };

    ExperimentController(std::shared_ptr<DBControl> dbControl);
    ~ExperimentController();

    MachineState machineState() const;
    ThermalState thermalState() const;
    Experiment experiment() const;

    inline const LogsSettings& settings() const { return _settings; }
    inline void setDebugMode(bool state) { _settings.debugMode = state; }

    StartingResult start(int experimentId);
    void resume();
    void stop();
    void stop(const std::string &errorMessage);

    void toggleTempLogs(bool temperatureLogsState, bool debugTemperatureLogsState);

    //void updateSettings(const Settings &settings);
    int getUserId(const std::string &token) const;

private:
    void run();
    void complete();

    void meltCurveCallback(Poco::Timer &timer);

    void rampFinished();

    void stepBegun();
    void holdStepCallback(Poco::Timer &timer);

    void startLogging();
    void stopLogging();
    void addLogCallback(Poco::Timer &timer);

    void calculateEstimatedDuration();

private:
    mutable Poco::RWLock *_machineMutex;
    MachineState _machineState;
    ThermalState _thermalState;

    std::shared_ptr<DBControl> _dbControl;
    Experiment _experiment;
    LogsSettings _settings;

    Poco::Timer *_meltCurveTimer;
    Poco::Timer *_holdStepTimer;
    Poco::Timer *_logTimer;

    std::vector<TemperatureLog> _logs;
};

#endif // EXPERIMENTCONTROLLER_H
