#ifndef EXPERIMENTCONTROLLER_H
#define EXPERIMENTCONTROLLER_H

#include "instance.h"
#include "experiment.h"

#include <atomic>
#include <vector>
#include <memory>
#include <mutex>

class DBControl;
class CSVControl;
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

    MachineState machineState() const;
    Experiment experiment() const;
    inline Settings* settings() const { return _settings; }

    StartingResult start(int experimentId);
    void stop();
    void stop(const std::string &errorMessage);

    void settingsUpdated();

    void toggleTempLogs();

private:
    void run();
    void complete();

    void rampFinished();

    void stepBegun();
    void holdStepCallback(Poco::Timer &timer);

    void startLogging();
    void stopLogging();
    void addLogCallback(Poco::Timer &timer);

private:
    mutable std::mutex _machineMutex;
    MachineState _machineState;

    DBControl *_dbControl;
    CSVControl *_csvControl;
    Experiment _experiment;
    Settings *_settings;

    Poco::Timer *_holdStepTimer;
    Poco::Timer *_logTimer;

    std::vector<TemperatureLog> _logs;
};

#endif // EXPERIMENTCONTROLLER_H
