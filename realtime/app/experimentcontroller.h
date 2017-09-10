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
    class LockedExperiment : public boost::noncopyable
    {
    public:
        friend class ExperimentController;

        LockedExperiment();
        LockedExperiment(LockedExperiment &&other);
        ~LockedExperiment();

        LockedExperiment& operator= (LockedExperiment &&other);
        Experiment& operator* () { return *_experiment; }
        Experiment* operator-> () { return _experiment; }
        operator bool() const { return isNull(); }

        inline bool isNull() const { return _experiment && _mutex; }

    private:
        LockedExperiment(Experiment *experiment, Poco::RWLock *mutex);

    private:
        Experiment *_experiment;
        Poco::RWLock *_mutex;
    };

    class LogsSettings
    {
    public:
        LogsSettings()
        {
            debugMode = false;
        }

    public:
        std::atomic<bool> debugMode;
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
        MachineRunning,
        OutOfStorageSpace
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

    inline MachineState machineState() const { return _machineState; }
    inline ThermalState thermalState() const { return _thermalState; }
    Experiment experiment() const;
    LockedExperiment lockedExperiment();

    inline bool debugMode() const { return _settings.debugMode; }
    inline void setDebugMode(bool state) { _settings.debugMode = state; }

    StartingResult start(int experimentId);
    void resume();
    void stop();
    void stop(const std::string &errorMessage);

    bool shutdown(MachineState checkState);

private:
    void shutdown();

    void run();
    void complete();

    void fluorescenceDataCollected();
    void meltCurveCallback(Poco::Timer &timer);

    void rampFinished();

    void stepBegun();
    void holdStepCallback(Poco::Timer &timer);

    void startLogging();
    void stopLogging();
    void addLogCallback(Poco::Timer &timer);

    void startDataSpaceCheck();
    void stopDataSpaceCheck();
    void checkDataSpace(Poco::Timer &timer);

    void calculateEstimatedDuration();

private:
    mutable Poco::RWLock *_machineMutex;
    std::atomic<MachineState> _machineState;
    std::atomic<ThermalState> _thermalState;

    std::shared_ptr<DBControl> _dbControl;
    Experiment _experiment;
    LogsSettings _settings;

    Poco::Timer *_fluorescenceTimer;
    Poco::Timer *_meltCurveTimer;
    Poco::Timer *_holdStepTimer;
    Poco::Timer *_logTimer;
    Poco::Timer *_dataSpaceTimer;

    std::vector<TemperatureLog> _logs;
};

#endif // EXPERIMENTCONTROLLER_H
