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

    HeatSinkInstance::getInstance()->setEnableMode(true);

    return Started;
}

void ExperimentController::run()
{
    if (_machineState != LidHeating)
        return;

    _machineState = Running;

    HeatBlockInstance::getInstance()->setTargetTemperature(_experiment->protocol()->currentStep()->temperature());
    HeatBlockInstance::getInstance()->enableStepProcessing();

    HeatBlockInstance::getInstance()->setEnableMode(true);
    OpticsInstance::getInstance()->setCollectData(true);
}

void ExperimentController::complete()
{
    if (_machineState != Running)
        return;

    _machineState = Complete;

    stopLogging();

    LidInstance::getInstance()->setEnableMode(false);
    OpticsInstance::getInstance()->setCollectData(false);

    _experiment->setCompletionStatus(Experiment::Success);
    _experiment->setCompletedAt(boost::posix_time::microsec_clock::local_time());

    _dbControl->completeExperiment(_experiment);
}

void ExperimentController::stop()
{
    if (_machineState == Idle)
        return;

    LidInstance::getInstance()->setEnableMode(false);
    HeatBlockInstance::getInstance()->setEnableMode(false);
    HeatSinkInstance::getInstance()->setEnableMode(false);
    OpticsInstance::getInstance()->setCollectData(false);

    if (_machineState != Complete)
    {
        stopLogging();

        _holdStepTimer->stop();

        _experiment->setCompletionStatus(Experiment::Aborted);
        _experiment->setCompletedAt(boost::posix_time::microsec_clock::local_time());

        _dbControl->completeExperiment(_experiment);
    }

    _machineState = Idle;

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
    _dbControl->addFluorescenceData(_experiment->protocol()->currentStep(), _experiment->protocol()->currentStageCycle(), OpticsInstance::getInstance()->restartCollection());

    HeatBlockInstance::getInstance()->setTargetTemperature(_experiment->protocol()->nextStep()->temperature(), _experiment->protocol()->currentRamp()->rate());
    HeatBlockInstance::getInstance()->enableStepProcessing();
}

void ExperimentController::startLogging()
{
    addLogCallback(*_logTimer);

    _logTimer->setPeriodicInterval(kTemperatureLogerInterval);
    _logTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::addLogCallback));
}

void ExperimentController::stopLogging()
{
    _logTimer->stop();
}

void ExperimentController::addLogCallback(Poco::Timer &)
{
    TemperatureLog log(_experiment->id());
    log.setElapsedTime((boost::posix_time::microsec_clock::local_time() - _experiment->startedAt()).total_milliseconds());
    log.setLidTemperature(LidInstance::getInstance()->currentTemperature());
    log.setHeatBlockZone1Temperature(HeatBlockInstance::getInstance()->zone1Temperature());
    log.setHeatBlockZone2Temperature(HeatBlockInstance::getInstance()->zone2Temperature());

    _dbControl->addTemperatureLog(log);

    if (_settings->debugMode())
    {
        DebugTemperatureLog debugLog(_experiment->id());
        debugLog.setElapsedTime(log.elapsedTime());
        debugLog.setLidTemperature(log.lidTemperature());
        debugLog.setHeatBlockZone1Drive(HeatBlockInstance::getInstance()->zone1DriveValue());
        debugLog.setHeatBlockZone2Drive(HeatBlockInstance::getInstance()->zone2DriveValue());

        _dbControl->addDebugTemperatureLog(debugLog);
    }
}

void ExperimentController::settingsUpdated()
{
    _dbControl->updateSettings(*_settings);
}
