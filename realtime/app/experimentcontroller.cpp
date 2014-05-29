#include "pcrincludes.h"
#include "boostincludes.h"
#include "pocoincludes.h"
#include "dbincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

#include "experimentcontroller.h"

ExperimentController::ExperimentController()
{
    _machineState = Idle;
    _dbControl = new DBControl();
    _experiment = nullptr;
    _holdStepTimer = new Poco::Timer();
    _logTimer = new Poco::Timer();

    LidInstance::getInstance()->startThresholdReached.connect(boost::bind(&ExperimentController::run, this));
    HeatBlockInstance::getInstance()->stepBegun.connect(boost::bind(&ExperimentController::stepBegun, this));
}

ExperimentController::~ExperimentController()
{
    stop();

    delete _logTimer;
    delete _holdStepTimer;
    delete _dbControl;
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
    else if (LidInstance::getInstance()->enableMode())
    {
        delete _experiment;
        _experiment = nullptr;

        return LidRunning;
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
}

void ExperimentController::complete()
{
    if (_machineState != Running)
        return;

    _machineState = Complete;

    stopLogging();

    _holdStepTimer->stop();

    LidInstance::getInstance()->setEnableMode(false);

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
    Step *currentStep = _experiment->protocol()->currentStep();
    Step *nextStep = _experiment->protocol()->nextStep();

    if (nextStep)
    {
        _holdStepTimer->stop();
        _holdStepTimer->setStartInterval(currentStep->holdTime() * 1000);
        _holdStepTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::holdStepCallback));
    }
    else
    {
        complete();

        if (currentStep->holdTime() > 0)
            stop();
    }
}

void ExperimentController::holdStepCallback(Poco::Timer &)
{
    HeatBlockInstance::getInstance()->setTargetTemperature(_experiment->protocol()->currentStep()->temperature(), _experiment->protocol()->currentRamp()->rate());
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
}
