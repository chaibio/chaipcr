#include <boost/date_time.hpp>
#include <Poco/Timer.h>
#include <Poco/RWLock.h>

#include "pcrincludes.h"
#include "dbincludes.h"
#include "maincontrollers.h"
#include "experimentcontroller.h"
#include "qpcrapplication.h"
#include "machinesettings.h"

#define STORE_MELT_CURVE_DATA_INTERVAL 10 * 1000

ExperimentController::ExperimentController()
{
    _machineMutex = new Poco::RWLock;
    _machineState = IdleMachineState;
    _thermalState = IdleThermalState;
    _dbControl = new DBControl();
    _meltCurveTimer = new Poco::Timer();
    _holdStepTimer = new Poco::Timer();
    _logTimer = new Poco::Timer();
    _settings = new MachineSettings();
    
    _settings->setDebugMode(_dbControl->getSettings().debugMode());

    LidInstance::getInstance()->startThresholdReached.connect(boost::bind(&ExperimentController::run, this));

    HeatBlockInstance::getInstance()->rampFinished.connect(boost::bind(&ExperimentController::rampFinished, this));
    HeatBlockInstance::getInstance()->stepBegun.connect(boost::bind(&ExperimentController::stepBegun, this));
}

ExperimentController::~ExperimentController()
{
    stop();

    delete _logTimer;
    delete _meltCurveTimer;
    delete _holdStepTimer;
    delete _dbControl;
    delete _settings;
    delete _machineMutex;
}

ExperimentController::MachineState ExperimentController::machineState() const
{
    Poco::RWLock::ScopedReadLock lock(*_machineMutex);
    return _machineState;
}

ExperimentController::ThermalState ExperimentController::thermalState() const
{
    Poco::RWLock::ScopedReadLock lock(*_machineMutex);
    return _thermalState;
}

Experiment ExperimentController::experiment() const
{
    Poco::RWLock::ScopedReadLock lock(*_machineMutex);
    return _experiment;
}

ExperimentController::StartingResult ExperimentController::start(int experimentId)
{
    if (OpticsInstance::getInstance()->lidOpen())
        return LidIsOpen;

    Experiment experiment = _dbControl->getExperiment(experimentId);

    if (experiment.empty() || !experiment.protocol())
        return ExperimentNotFound;
    else if (experiment.startedAt() != boost::posix_time::not_a_date_time)
        return ExperimentUsed;

    experiment.setStartedAt(boost::posix_time::microsec_clock::local_time());

    if (machineState() != IdleMachineState)
        return MachineRunning;

    stopLogging();

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        _settings->temperatureLogs.setTemperatureLogs(false);
        _settings->temperatureLogs.setDebugTemperatureLogs(false);

        LidInstance::getInstance()->setTargetTemperature(experiment.protocol()->lidTemperature());

        _dbControl->startExperiment(experiment);

        _machineState = LidHeatingMachineState;
        _experiment = std::move(experiment);

        LidInstance::getInstance()->setEnableMode(true);
    }

    startLogging();

    return Started;
}

void ExperimentController::run()
{
    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        if (_machineState != LidHeatingMachineState)
            return;

        _machineState = RunningMachineState;
        _thermalState = HeatBlockInstance::getInstance()->temperature() < _experiment.protocol()->currentStep()->temperature() ? HeatingThermalState : CoolingThermalState;

        HeatBlockInstance::getInstance()->setTargetTemperature(_experiment.protocol()->currentStep()->temperature(), _experiment.protocol()->currentRamp()->rate());
        HeatBlockInstance::getInstance()->enableStepProcessing();
        HeatBlockInstance::getInstance()->setEnableMode(true);

        if (_experiment.protocol()->currentRamp()->collectData())
        {
            OpticsInstance::getInstance()->setCollectData(true, _experiment.protocol()->currentStage()->type() == Stage::Meltcurve);

            if (_experiment.protocol()->currentStage()->type() == Stage::Meltcurve)
            {
                _meltCurveTimer->setPeriodicInterval(STORE_MELT_CURVE_DATA_INTERVAL);
                _meltCurveTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::meltCurveCallback));
            }
        }
    }

    calculateEstimatedDuration();
}

void ExperimentController::resume()
{
    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        if (_machineState != PausedMachineState)
            return;

        _machineState = RunningMachineState;

        _experiment.setPausedDuration(_experiment.pausedDuration() + (boost::posix_time::microsec_clock::local_time() - _experiment.lastPauseTime()).total_seconds());

        _holdStepTimer->stop();
        _holdStepTimer->setStartInterval(0);
        _holdStepTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::holdStepCallback));
    }
}

void ExperimentController::complete()
{
    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        if (_machineState != RunningMachineState)
            return;

        _machineState = CompleteMachineState;
        _thermalState = IdleThermalState;

        LidInstance::getInstance()->setEnableMode(false);
        OpticsInstance::getInstance()->setCollectData(false);

        _experiment.setCompletionStatus(Experiment::Success);
        _experiment.setCompletedAt(boost::posix_time::microsec_clock::local_time());

        _dbControl->completeExperiment(_experiment);
    }

    stopLogging();
}

void ExperimentController::stop()
{
    MachineState state = IdleMachineState;

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        if (_machineState == IdleMachineState)
            return;
        else if (_machineState == CompleteMachineState && _experiment.protocol()->currentStage()->type() != Stage::Meltcurve)
        {
            //Check if it was infinite hold step
            Stage *stage = _experiment.protocol()->currentStage();
            std::time_t holdTime = stage->currentStep()->holdTime();

            if (stage->autoDelta() && stage->currentCycle() > stage->autoDeltaStartCycle())
            {
                holdTime += stage->currentStep()->deltaDuration() * (stage->currentCycle() - stage->autoDeltaStartCycle());

                if (holdTime < 0)
                    holdTime = 0;
            }

            if (holdTime == 0)
                _dbControl->addFluorescenceData(_experiment, OpticsInstance::getInstance()->getFluorescenceData());
        }

        LidInstance::getInstance()->setEnableMode(false);
        HeatBlockInstance::getInstance()->setEnableMode(false);
        OpticsInstance::getInstance()->setCollectData(false);

        if (_machineState != CompleteMachineState)
        {
            _experiment.setCompletionStatus(Experiment::Aborted);
            _experiment.setCompletedAt(boost::posix_time::microsec_clock::local_time());

            _dbControl->completeExperiment(_experiment);
        }

        state = _machineState;

        _machineState = IdleMachineState;
        _thermalState = IdleThermalState;
        _experiment = Experiment();
    }

    if (state != CompleteMachineState)
    {
        stopLogging();
        _holdStepTimer->stop();
        _meltCurveTimer->stop();
    }
}

void ExperimentController::stop(const std::string &errorMessage)
{
    bool stopTimers = false;

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        LidInstance::getInstance()->setEnableMode(false);
        HeatBlockInstance::getInstance()->setEnableMode(false);
        OpticsInstance::getInstance()->setCollectData(false);

        if (_experiment.id() != -1)
        {
            stopTimers = true;

            _experiment.setCompletionStatus(Experiment::Failed);
            _experiment.setCompletionMessage(errorMessage);
            _experiment.setCompletedAt(boost::posix_time::microsec_clock::local_time());

            _dbControl->completeExperiment(_experiment);
        }

        _machineState = IdleMachineState;
        _thermalState = IdleThermalState;
        _experiment = Experiment();
    }

    if (stopTimers)
    {
        stopLogging();
        _holdStepTimer->stop();
        _meltCurveTimer->stop();
    }
}

void ExperimentController::meltCurveCallback(Poco::Timer &)
{
    Poco::RWLock::ScopedReadLock lock(*_machineMutex);

    if (_machineState == RunningMachineState)
        _dbControl->addMeltCurveData(_experiment, OpticsInstance::getInstance()->getMeltCurveData(false));
}

void ExperimentController::rampFinished()
{
    _meltCurveTimer->stop();

    Poco::RWLock::ScopedReadLock lock(*_machineMutex);

    if (_machineState == RunningMachineState)
    {
        _thermalState = HoldingThermalState;

        if (_experiment.protocol()->currentStage()->type() == Stage::Meltcurve)
            _dbControl->addMeltCurveData(_experiment, OpticsInstance::getInstance()->getMeltCurveData());
        else
        {
            _dbControl->addFluorescenceData(_experiment, OpticsInstance::getInstance()->getFluorescenceData(), true);

            OpticsInstance::getInstance()->setCollectData(_experiment.protocol()->currentStep()->collectData(), false);
        }
    }
}

void ExperimentController::stepBegun()
{
    bool onPause = false;

    _holdStepTimer->stop();

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        if (_machineState != RunningMachineState)
            return;

        Stage *stage = _experiment.protocol()->currentStage();

        if (!stage->currentStep()->pauseState())
        {
            std::time_t holdTime = stage->currentStep()->holdTime();

            if (stage->autoDelta() && stage->currentCycle() > stage->autoDeltaStartCycle())
            {
                holdTime += stage->currentStep()->deltaDuration() * (stage->currentCycle() - stage->autoDeltaStartCycle());

                if (holdTime < 0)
                    holdTime = 0;
            }

            if (holdTime > 0 || _experiment.protocol()->hasNextStep())
            {
                _holdStepTimer->setStartInterval(holdTime * 1000);
                _holdStepTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::holdStepCallback));

                return;
            }
        }
        else
        {
            _experiment.setPauseTime(boost::posix_time::microsec_clock::local_time());
            _machineState = PausedMachineState;

            onPause = true;
        }
    }

    if (!onPause)
        complete();
    else
        calculateEstimatedDuration();
}

void ExperimentController::holdStepCallback(Poco::Timer &)
{
    bool isLast = false;

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        if (_machineState != RunningMachineState)
            return;

        if (_experiment.protocol()->currentStage()->type() != Stage::Meltcurve)
            _dbControl->addFluorescenceData(_experiment, OpticsInstance::getInstance()->getFluorescenceData());

        if (_experiment.protocol()->hasNextStep())
        {
            _experiment.protocol()->advanceNextStep();

            Stage *stage = _experiment.protocol()->currentStage();
            double temperature = stage->currentStep()->temperature();

            if (stage->autoDelta() && stage->currentCycle() > stage->autoDeltaStartCycle())
            {
                temperature += stage->currentStep()->deltaTemperature() * (stage->currentCycle() - stage->autoDeltaStartCycle());

                if (temperature < HeatBlockInstance::getInstance()->minTargetTemperature())
                    temperature = HeatBlockInstance::getInstance()->minTargetTemperature();
                else if (temperature > HeatBlockInstance::getInstance()->maxTargetTemperature())
                    temperature = HeatBlockInstance::getInstance()->maxTargetTemperature();
            }

            if (stage->currentRamp()->collectData())
            {
                OpticsInstance::getInstance()->setCollectData(true, stage->type() == Stage::Meltcurve);

                if (stage->type() == Stage::Meltcurve)
                {
                    _meltCurveTimer->setPeriodicInterval(STORE_MELT_CURVE_DATA_INTERVAL);
                    _meltCurveTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::meltCurveCallback));
                }
            }

            _thermalState = HeatBlockInstance::getInstance()->temperature() < temperature ? HeatingThermalState : CoolingThermalState;

            HeatBlockInstance::getInstance()->setTargetTemperature(temperature, stage->currentRamp()->rate());
            HeatBlockInstance::getInstance()->enableStepProcessing();
        }
        else
            isLast = true;
    }

    if (!isLast)
        calculateEstimatedDuration();
    else
    {
        complete();
        stop();
    }
}

void ExperimentController::startLogging()
{
    _logTimer->setPeriodicInterval(kTemperatureLoggerInterval);
    _logTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::addLogCallback));
}

void ExperimentController::stopLogging()
{
    _logTimer->stop();

    _settings->temperatureLogs.setStartTime(boost::posix_time::not_a_date_time);

    _dbControl->addTemperatureLog(_logs);
    _logs.clear();
}

void ExperimentController::toggleTempLogs()
{
    if (machineState() == IdleMachineState)
    {
        if (_settings->temperatureLogs.hasTemperatureLogs() || _settings->temperatureLogs.hasDebugTemperatureLogs())
        {
            if (_settings->temperatureLogs.startTime() == boost::posix_time::not_a_date_time)
            {
                _settings->temperatureLogs.setStartTime(boost::posix_time::microsec_clock::universal_time());

                startLogging();
            }
        }
        else
            stopLogging();
    }
}

void ExperimentController::addLogCallback(Poco::Timer &)
{
    TemperatureLog log;

    _machineMutex->readLock();

    if (_machineState != IdleMachineState)
    {
        log = TemperatureLog(_experiment.id(), true, _experiment.type() == Experiment::DiagnosticType || _settings->debugMode());
        log.setElapsedTime((boost::posix_time::microsec_clock::local_time() - _experiment.startedAt()).total_milliseconds());

        _machineMutex->unlock();
    }
    else
    {
        _machineMutex->unlock();

        log = TemperatureLog(0, _settings->temperatureLogs.hasTemperatureLogs(), _settings->temperatureLogs.hasDebugTemperatureLogs());
        log.setElapsedTime((boost::posix_time::microsec_clock::universal_time() - _settings->temperatureLogs.startTime()).total_milliseconds());
    }

    if (log.hasTemperatureInfo())
    {
        log.setLidTemperature(LidInstance::getInstance()->currentTemperature());
        log.setHeatBlockZone1Temperature(HeatBlockInstance::getInstance()->zone1Temperature());
        log.setHeatBlockZone2Temperature(HeatBlockInstance::getInstance()->zone2Temperature());
    }

    if (log.hasDebugInfo())
    {
        log.setLidDrive(LidInstance::getInstance()->drive());
        log.setHeatBlockZone1Drive(HeatBlockInstance::getInstance()->zone1DriveValue());
        log.setHeatBlockZone2Drive(HeatBlockInstance::getInstance()->zone2DriveValue());
    }

    _logs.push_back(std::move(log));

    if ((_logs.back().elapsedTime() - _logs.front().elapsedTime()) >= kTemperatureLoggerFlushInterval)
    {
        _dbControl->addTemperatureLog(_logs);
        _logs.clear();
    }
}

void ExperimentController::calculateEstimatedDuration()
{
    Experiment experiment = this->experiment();
    double duration = (boost::posix_time::microsec_clock::local_time() - experiment.startedAt()).total_milliseconds() - (experiment.pausedDuration() * 1000);
    double previousTargetTemp = HeatBlockInstance::getInstance()->temperature();

    do
    {
        Stage *stage = experiment.protocol()->currentStage();

        if (!stage->currentStep()->pauseState())
            duration += stage->currentStep()->holdTime() * 1000;

        double temperature = stage->currentStep()->temperature();

        if (stage->autoDelta() && stage->currentCycle() > stage->autoDeltaStartCycle())
        {
            temperature += stage->currentStep()->deltaTemperature() * (stage->currentCycle() - stage->autoDeltaStartCycle());

            if (temperature < HeatBlockInstance::getInstance()->minTargetTemperature())
                temperature = HeatBlockInstance::getInstance()->minTargetTemperature();
            else if (temperature > HeatBlockInstance::getInstance()->maxTargetTemperature())
                temperature = HeatBlockInstance::getInstance()->maxTargetTemperature();
        }

        double rate = stage->currentRamp()->rate();
        rate = rate > 0 && rate <= kDurationCalcHeatBlockRampSpeed ? rate : kDurationCalcHeatBlockRampSpeed;

        if (previousTargetTemp < temperature)
            duration += ((temperature - previousTargetTemp) / rate) * 1000;
        else
            duration += ((previousTargetTemp - temperature) / rate) * 1000;

        previousTargetTemp = temperature;
    }
    while (experiment.protocol()->advanceNextStep());

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);
        _experiment.setEstimatedDuration(std::round(duration / 1000));
    }
}

void ExperimentController::updateSettings(const Settings &settings)
{
    if (settings.isDebugModeDirty())
        _settings->setDebugMode(settings.debugMode());

    _dbControl->updateSettings(settings);
}

int ExperimentController::getUserId(const std::string &token) const
{
    return _dbControl->getUserId(token);
}
