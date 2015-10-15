#ifndef EXPERIMENTCONTROLLER_H
#define EXPERIMENTCONTROLLER_H

#include "instance.h"
#include "experiment.h"

#include <atomic>
#include <vector>
#include <memory>

class DBControl;
class Settings;
class MachineSettings;
class TemperatureLog;

namespace Poco { class Timer; class RWLock; }

class ExperimentController : public Instance<ExperimentController>
{
public:
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

    ExperimentController();
    ~ExperimentController();

    MachineState machineState() const;
    ThermalState thermalState() const;
    Experiment experiment() const;
    inline MachineSettings* settings() const { return _settings; }

    StartingResult start(int experimentId);
    void resume();
    void stop();
    void stop(const std::string &errorMessage);

    void toggleTempLogs();

    void updateSettings(const Settings &settings);
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

    DBControl *_dbControl;
    Experiment _experiment;
    MachineSettings *_settings;

    Poco::Timer *_meltCurveTimer;
    Poco::Timer *_holdStepTimer;
    Poco::Timer *_logTimer;

    std::vector<TemperatureLog> _logs;
};

#endif // EXPERIMENTCONTROLLER_H
