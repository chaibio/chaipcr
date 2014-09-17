#ifndef EXPERIMENTCONTROLLER_H
#define EXPERIMENTCONTROLLER_H

#include "instance.h"

#include <atomic>
#include <vector>

class DBControl;
class Experiment;
class Settings;
class TemperatureLog;

namespace Poco { class Timer; }

class ExperimentController : public Instance<ExperimentController>
{
public:
    enum MachineState
    {
        Idle,
        LidHeating,
        Running,
        Complete
    };

    enum StartingResult
    {
        Started,
        ExperimentNotFound,
        ExperimentUsed,
        LidIsOpen,
        MachineRunning
    };

    ExperimentController();
    ~ExperimentController();

    inline MachineState machineState() const { return _machineState; }
    inline const Experiment* experiment() const { return _experiment; }
    inline Settings* settings() const { return _settings; }

    StartingResult start(int experimentId);
    void stop();

    void settingsUpdated();

    void toggleTempLogs();

private:
    void run();
    void complete();

    void stepBegun();
    void holdStepCallback(Poco::Timer &timer);

    void startLogging();
    void stopLogging();
    void addLogCallback(Poco::Timer &timer);

    void addTempLogCallback(Poco::Timer &timer);

private:
    std::atomic<MachineState> _machineState;

    DBControl *_dbControl;
    Experiment *_experiment;
    Settings *_settings;

    Poco::Timer *_holdStepTimer;
    Poco::Timer *_logTimer;

    std::vector<TemperatureLog> _logs;
};

#endif // EXPERIMENTCONTROLLER_H
