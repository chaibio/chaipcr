#include <boost/date_time.hpp>
#include <Poco/Timer.h>

#include "pcrincludes.h"
#include "dbincludes.h"
#include "csvcontrol.h"
#include "maincontrollers.h"
#include "experimentcontroller.h"
#include "qpcrapplication.h"

ExperimentController::ExperimentController()
{
    _machineState = Idle;
    _dbControl = new DBControl();
    _csvControl = new CSVControl();
    _holdStepTimer = new Poco::Timer();
    _logTimer = new Poco::Timer();
    _settings = _dbControl->getSettings();

    LidInstance::getInstance()->startThresholdReached.connect(boost::bind(&ExperimentController::run, this));

    HeatBlockInstance::getInstance()->rampFinished.connect(boost::bind(&ExperimentController::rampFinished, this));
    HeatBlockInstance::getInstance()->stepBegun.connect(boost::bind(&ExperimentController::stepBegun, this));
}

ExperimentController::~ExperimentController()
{
    stop();

    delete _logTimer;
    delete _holdStepTimer;
    delete _dbControl;
    delete _csvControl;
    delete _settings;
}

ExperimentController::MachineState ExperimentController::machineState() const
{
    std::unique_lock<std::mutex> lock(_machineMutex);
    return _machineState;
}

Experiment ExperimentController::experiment() const
{
    std::unique_lock<std::mutex> lock(_machineMutex);
    return _experiment;
}

ExperimentController::StartingResult ExperimentController::start(int experimentId)
{
    if (OpticsInstance::getInstance()->lidOpen())
        return LidIsOpen;

    Experiment experiment = _dbControl->getExperiment(experimentId);

    if (experiment.id() == -1 || !experiment.protocol())
        return ExperimentNotFound;
    else if (experiment.startedAt() != boost::posix_time::not_a_date_time)
        return ExperimentUsed;

    experiment.setStartedAt(boost::posix_time::microsec_clock::local_time());

    std::unique_lock<std::mutex> lock(_machineMutex);

    if (_machineState != Idle)
        return MachineRunning;

    lock.unlock();
    stopLogging();
    lock.lock();

    _settings->temperatureLogs.setTemperatureLogs(false);
    _settings->temperatureLogs.setDebugTemperatureLogs(false);

    LidInstance::getInstance()->setTargetTemperature(experiment.protocol()->lidTemperature());

    _dbControl->startExperiment(experiment);

    _machineState = LidHeating;
    _experiment = std::move(experiment);

    LidInstance::getInstance()->setEnableMode(true);

    lock.unlock();
    startLogging();

    return Started;
}

void ExperimentController::run()
{
    std::unique_lock<std::mutex> lock(_machineMutex);

    if (_machineState == LidHeating)
    {
        _machineState = Running;

        HeatBlockInstance::getInstance()->setTargetTemperature(_experiment.protocol()->currentStep()->temperature(), _experiment.protocol()->currentRamp()->rate());
        HeatBlockInstance::getInstance()->enableStepProcessing();
        HeatBlockInstance::getInstance()->setEnableMode(true);

        OpticsInstance::getInstance()->setCollectData(_experiment.protocol()->currentRamp()->collectData(), _experiment.protocol()->currentStage()->type() == Stage::Meltcurve);
    }
}

void ExperimentController::complete()
{
    std::unique_lock<std::mutex> lock(_machineMutex);

    if (_machineState == Running)
    {
        _machineState = Complete;

        LidInstance::getInstance()->setEnableMode(false);
        OpticsInstance::getInstance()->setCollectData(false);

        _experiment.setCompletionStatus(Experiment::Success);
        _experiment.setCompletedAt(boost::posix_time::microsec_clock::local_time());

        _dbControl->completeExperiment(_experiment);

        lock.unlock();
        stopLogging();
    }
}

void ExperimentController::stop()
{
    std::unique_lock<std::mutex> lock(_machineMutex);

    if (_machineState != Idle)
    {
        _machineState = Idle;

        LidInstance::getInstance()->setEnableMode(false);
        HeatBlockInstance::getInstance()->setEnableMode(false);
        OpticsInstance::getInstance()->setCollectData(false);

        bool stopTimers = false;

        if (_machineState != Complete)
        {
            stopTimers = true;

            _experiment.setCompletionStatus(Experiment::Aborted);
            _experiment.setCompletedAt(boost::posix_time::microsec_clock::local_time());

            _dbControl->completeExperiment(_experiment);
        }

        _experiment = Experiment();

        lock.unlock();

        if (stopTimers)
        {
            stopLogging();
            _holdStepTimer->stop();
        }
    }
}

void ExperimentController::stop(const std::string &errorMessage)
{
    std::unique_lock<std::mutex> lock(_machineMutex);

    _machineState = Idle;

    LidInstance::getInstance()->setEnableMode(false);
    HeatBlockInstance::getInstance()->setEnableMode(false);
    OpticsInstance::getInstance()->setCollectData(false);

    bool stopTimers = false;

    if (_experiment.id() != -1)
    {
        stopTimers = true;

        _experiment.setCompletionStatus(Experiment::Failed);
        _experiment.setCompletionMessage(errorMessage);
        _experiment.setCompletedAt(boost::posix_time::microsec_clock::local_time());

        _dbControl->completeExperiment(_experiment);
    }

    _experiment = Experiment();

    lock.unlock();

    if (stopTimers)
    {
        stopLogging();
        _holdStepTimer->stop();
    }
}

void ExperimentController::rampFinished()
{
    std::unique_lock<std::mutex> lock(_machineMutex);

    if (_machineState == Running)
    {
        if (_experiment.protocol()->currentStage()->type() == Stage::Meltcurve)
            _csvControl->writeMeltCurveData(_experiment, OpticsInstance::getInstance()->getMeltCurveData());
        else
        {
            _dbControl->addFluorescenceData(_experiment, OpticsInstance::getInstance()->getFluorescenceData(), true);

            OpticsInstance::getInstance()->setCollectData(_experiment.protocol()->currentStep()->collectData(), false);
        }
    }
}

void ExperimentController::stepBegun()
{
    std::unique_lock<std::mutex> lock(_machineMutex);

    if (_machineState != Running)
        return;

    std::time_t holdTime = _experiment.protocol()->currentStep()->holdTime();

    if (_experiment.protocol()->hasNextStep())
    {
        _holdStepTimer->stop();
        _holdStepTimer->setStartInterval(holdTime * 1000);
        _holdStepTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::holdStepCallback));
    }
    else
    {
        lock.unlock();

        complete();

        if (holdTime > 0)
            stop();
    }
}

void ExperimentController::holdStepCallback(Poco::Timer &)
{
    std::unique_lock<std::mutex> lock(_machineMutex);

    if (_machineState == Running)
    {
        if (_experiment.protocol()->currentStage()->type() != Stage::Meltcurve)
            _dbControl->addFluorescenceData(_experiment, OpticsInstance::getInstance()->getFluorescenceData());

        _experiment.protocol()->advanceNextStep();

        OpticsInstance::getInstance()->setCollectData(_experiment.protocol()->currentRamp()->collectData(), _experiment.protocol()->currentStage()->type() == Stage::Meltcurve);

        HeatBlockInstance::getInstance()->setTargetTemperature(_experiment.protocol()->currentStep()->temperature(), _experiment.protocol()->currentRamp()->rate());
        HeatBlockInstance::getInstance()->enableStepProcessing();
    }
}

void ExperimentController::startLogging()
{
    addLogCallback(*_logTimer);

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
    if (machineState() == Idle)
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

    _machineMutex.lock();

    if (_machineState != Idle)
    {
        log = TemperatureLog(_experiment.id(), true, _settings->debugMode());
        log.setElapsedTime((boost::posix_time::microsec_clock::local_time() - _experiment.startedAt()).total_milliseconds());

        _machineMutex.unlock();
    }
    else
    {
        _machineMutex.unlock();

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

void ExperimentController::settingsUpdated()
{
    _dbControl->updateSettings(*_settings);
}
