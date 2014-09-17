#include <boost/date_time.hpp>
#include <Poco/Timer.h>

#include "pcrincludes.h"
#include "dbincludes.h"
#include "maincontrollers.h"
#include "experimentcontroller.h"

ExperimentController::ExperimentController()
{
    _machineState = Idle;
    _dbControl = new DBControl();
    _experiment = nullptr;
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

    _experiment = _dbControl->getExperiment(experimentId);

    if (!_experiment || !_experiment->protocol())
    {
        delete _experiment;
        _experiment = nullptr;

        return ExperimentNotFound;
    }
    else if (_experiment->startedAt() != boost::posix_time::not_a_date_time)
    {
        delete _experiment;
        _experiment = nullptr;

        return ExperimentUsed;
    }
    else if (OpticsInstance::getInstance()->lidOpen())
    {
        delete _experiment;
        _experiment = nullptr;

        return LidIsOpen;
    }

    _machineState = LidHeating;

    _experiment->setStartedAt(boost::posix_time::microsec_clock::local_time());
    _dbControl->startExperiment(_experiment);

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

    HeatBlockInstance::getInstance()->setTargetTemperature(_experiment->protocol()->currentStep()->temperature());
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

    _dbControl->completeExperiment(_experiment);
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

        _dbControl->completeExperiment(_experiment);
    }

    delete _experiment;
    _experiment = nullptr;
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
    _dbControl->addFluorescenceData(_experiment, OpticsInstance::getInstance()->restartCollection());

    HeatBlockInstance::getInstance()->setTargetTemperature(_experiment->protocol()->advanceNextStep()->temperature(), _experiment->protocol()->currentRamp()->rate());
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

    _dbControl->addTemperatureLog(_logs);
    _logs.clear();
}

void ExperimentController::addLogCallback(Poco::Timer &)
{
    TemperatureLog log(_experiment->id(), _settings->debugMode());
    log.setElapsedTime((boost::posix_time::microsec_clock::local_time() - _experiment->startedAt()).total_milliseconds());
    log.setLidTemperature(LidInstance::getInstance()->currentTemperature());
    log.setHeatBlockZone1Temperature(HeatBlockInstance::getInstance()->zone1Temperature());
    log.setHeatBlockZone2Temperature(HeatBlockInstance::getInstance()->zone2Temperature());

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
