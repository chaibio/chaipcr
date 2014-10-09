#include <boost/date_time.hpp>
#include <Poco/Timer.h>

#include "pcrincludes.h"
#include "dbincludes.h"
#include "maincontrollers.h"
#include "experimentcontroller.h"
#include "qpcrapplication.h"

ExperimentController::ExperimentController()
{
    _machineState = Idle;
    _dbControl = new DBControl();
    _holdStepTimer = new Poco::Timer();
    _logTimer = new Poco::Timer();
    _settings = _dbControl->getSettings();

    LidInstance::getInstance()->startThresholdReached.connect(boost::bind(&ExperimentController::run, this));
    HeatBlockInstance::getInstance()->stepBegun.connect(boost::bind(&ExperimentController::stepBegun, this));
}

ExperimentController::~ExperimentController()
{
    stop();

    delete _logTimer;
    delete _holdStepTimer;
    delete _dbControl;
    delete _settings;
}

ExperimentController::StartingResult ExperimentController::start(int experimentId)
{
    if (_machineState != Idle)
        return MachineRunning;

    _experiment.reset(_dbControl->getExperiment(experimentId));

    if (!_experiment || !_experiment->protocol())
    {
        _experiment.reset();

        return ExperimentNotFound;
    }
    else if (_experiment->startedAt() != boost::posix_time::not_a_date_time)
    {
        _experiment.reset();

        return ExperimentUsed;
    }
    else if (OpticsInstance::getInstance()->lidOpen())
    {
        _experiment.reset();

        return LidIsOpen;
    }

    stopLogging();

    _machineState = LidHeating;

    _experiment->setStartedAt(boost::posix_time::microsec_clock::local_time());
    _dbControl->startExperiment(_experiment.get());

    _settings->temperatureLogs.setTemperatureLogs(false);
    _settings->temperatureLogs.setDebugTemperatureLogs(false);

    startLogging();

    LidInstance::getInstance()->setTargetTemperature(_experiment->protocol()->lidTemperature());
    LidInstance::getInstance()->setEnableMode(true);

    return Started;
}

void ExperimentController::run()
{
    MachineState state = LidHeating;
    if (!_machineState.compare_exchange_strong(state, Running))
        return;

    HeatBlockInstance::getInstance()->setTargetTemperature(_experiment->protocol()->currentStep()->temperature(), _experiment->protocol()->currentRamp() ? _experiment->protocol()->currentRamp()->rate() : 0);
    HeatBlockInstance::getInstance()->enableStepProcessing();

    HeatBlockInstance::getInstance()->setEnableMode(true);
    OpticsInstance::getInstance()->setCollectData(true);
}

void ExperimentController::complete()
{
    MachineState state = Running;
    if (!_machineState.compare_exchange_strong(state, Complete))
        return;

    stopLogging();

    LidInstance::getInstance()->setEnableMode(false);
    OpticsInstance::getInstance()->setCollectData(false);

    _experiment->setCompletionStatus(Experiment::Success);
    _experiment->setCompletedAt(boost::posix_time::microsec_clock::local_time());

    _dbControl->completeExperiment(_experiment.get());
}

void ExperimentController::stop()
{
    MachineState state = _machineState.exchange(Idle);

    if (state == Idle)
        return;

    LidInstance::getInstance()->setEnableMode(false);
    HeatBlockInstance::getInstance()->setEnableMode(false);
    OpticsInstance::getInstance()->setCollectData(false);

    if (state != Complete)
    {
        stopLogging();

        _holdStepTimer->stop();

        _experiment->setCompletionStatus(Experiment::Aborted);
        _experiment->setCompletedAt(boost::posix_time::microsec_clock::local_time());

        _dbControl->completeExperiment(_experiment.get());
    }

    _experiment.reset();
}

void ExperimentController::stop(const std::string &errorMessage)
{
    if (_machineState.exchange(Idle) == Idle)
        return;

    LidInstance::getInstance()->setEnableMode(false);
    HeatBlockInstance::getInstance()->setEnableMode(false);
    OpticsInstance::getInstance()->setCollectData(false);

    stopLogging();

    _holdStepTimer->stop();

    _experiment->setCompletionStatus(Experiment::Failed);
    _experiment->setCompletionMessage(errorMessage);
    _experiment->setCompletedAt(boost::posix_time::microsec_clock::local_time());

    _dbControl->completeExperiment(_experiment.get());

    _experiment.reset();
}

void ExperimentController::stepBegun()
{
    if (_experiment->protocol()->hasNextStep())
    {
        _holdStepTimer->stop();
        _holdStepTimer->setStartInterval(_experiment->protocol()->currentStep()->holdTime() * 1000);
        _holdStepTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::holdStepCallback));
    }
    else
    {
        complete();

        if (_experiment->protocol()->currentStep()->holdTime() > 0)
            stop();
    }
}

void ExperimentController::holdStepCallback(Poco::Timer &)
{
    _dbControl->addFluorescenceData(_experiment.get(), OpticsInstance::getInstance()->restartCollection());

    HeatBlockInstance::getInstance()->setTargetTemperature(_experiment->protocol()->advanceNextStep()->temperature(), _experiment->protocol()->currentRamp() ? _experiment->protocol()->currentRamp()->rate() : 0);
    HeatBlockInstance::getInstance()->enableStepProcessing();
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

    if (machineState() != Idle)
    {
        log = TemperatureLog(_experiment->id(), true, _settings->debugMode());
        log.setElapsedTime((boost::posix_time::microsec_clock::local_time() - _experiment->startedAt()).total_milliseconds());
    }
    else
    {
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
