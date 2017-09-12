//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include <fstream>
#include <boost/date_time.hpp>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <Poco/Timer.h>
#include <Poco/RWLock.h>

#include "pcrincludes.h"
#include "dbincludes.h"
#include "maincontrollers.h"
#include "ledcontroller.h"
#include "experimentcontroller.h"
#include "qpcrapplication.h"
#include "timercallback.h"
#include "logger.h"
#include "util.h"

#define STORE_MELT_CURVE_DATA_INTERVAL 10 * 1000

ExperimentController::LockedExperiment::LockedExperiment()
    :LockedExperiment(nullptr, nullptr)
{

}

ExperimentController::LockedExperiment::LockedExperiment(Experiment *experiment, Poco::RWLock *mutex)
{
    _experiment = experiment;
    _mutex = mutex;

    if (_experiment && _mutex)
        _mutex->writeLock();
}

ExperimentController::LockedExperiment::LockedExperiment(LockedExperiment &&other)
{
    if (other._experiment && other._mutex)
    {
        _experiment = other._experiment;
        _mutex = other._mutex;

        other._experiment = nullptr;
        other._mutex = nullptr;
    }
}

ExperimentController::LockedExperiment::~LockedExperiment()
{
    if (_mutex)
        _mutex->unlock();
}

ExperimentController::LockedExperiment& ExperimentController::LockedExperiment::operator =(LockedExperiment &&other)
{
    if (_mutex)
        _mutex->unlock();

    _experiment = other._experiment;
    _mutex = other._mutex;

    other._experiment = nullptr;
    other._mutex = nullptr;

    return *this;
}

ExperimentController::ExperimentController(std::shared_ptr<DBControl> dbControl)
{
    _machineMutex = new Poco::RWLock;
    _machineState = IdleMachineState;
    _thermalState = IdleThermalState;
    _dbControl = dbControl;
    _fluorescenceTimer = new Poco::Timer();
    _meltCurveTimer = new Poco::Timer();
    _holdStepTimer = new Poco::Timer();
    _logTimer = new Poco::Timer();
    _dataSpaceTimer = new Poco::Timer();
    
    _settings.debugMode = _dbControl->getSettings().debugMode();

    LidInstance::getInstance()->startThresholdReached.connect(boost::bind(&ExperimentController::run, this));

    HeatBlockInstance::getInstance()->rampFinished.connect(boost::bind(&ExperimentController::rampFinished, this));
    HeatBlockInstance::getInstance()->stepBegun.connect(boost::bind(&ExperimentController::stepBegun, this));

    OpticsInstance::getInstance()->fluorescenceDataCollected.connect(boost::bind(&ExperimentController::fluorescenceDataCollected, this));
}

ExperimentController::~ExperimentController()
{
    stop();

    delete _logTimer;
    delete _fluorescenceTimer;
    delete _meltCurveTimer;
    delete _holdStepTimer;
    delete _machineMutex;
    delete _dataSpaceTimer;
}

Experiment ExperimentController::experiment() const
{
    Poco::RWLock::ScopedReadLock lock(*_machineMutex);
    return _experiment;
}

ExperimentController::LockedExperiment ExperimentController::lockedExperiment()
{
    return LockedExperiment(&_experiment, _machineMutex);
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

    unsigned long dataSpace = 0;

    if (Util::getPartitionAvailableSpace(kDataPartitionpath, dataSpace))
    {
        if (qpcrApp.settings().configuration.dataSpaceSoftLimit >= dataSapce)
            return OutOfStorageSpace;
    }
    else
    {
        APP_LOGGER << "ExperimentController::start - unable to get the available space of the data partition" << std::endl;

        return OutOfStorageSpace;
    }

    experiment.setStartedAt(boost::posix_time::microsec_clock::local_time());

    if (machineState() != IdleMachineState)
        return MachineRunning;

    stopLogging();

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        LidInstance::getInstance()->setTargetTemperature(experiment.protocol()->lidTemperature());

        _dbControl->startExperiment(experiment);

        _machineState = LidHeatingMachineState;
        _experiment = std::move(experiment);

        LidInstance::getInstance()->setEnableMode(true);
    }

    startLogging();
    startDataSpaceCheck();

    APP_LOGGER << "ExperimentController::start - experiment started " << experimentId << std::endl;

    return Started;
}


void ExperimentController::shutdown()
{
    LidInstance::getInstance()->setEnableMode(false);
    HeatSinkInstance::getInstance()->setEnableMode(false);
    HeatBlockInstance::getInstance()->setEnableMode(false);
    OpticsInstance::getInstance()->stopCollectData();
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

        HeatSinkInstance::getInstance()->setEnableMode(true, false);

        if (_experiment.protocol()->currentRamp()->collectData())
        {
            if (_experiment.protocol()->currentStage()->type() == Stage::Meltcurve)
            {
                OpticsInstance::getInstance()->startCollectData(Optics::MeltCurveDataType);

                _meltCurveTimer->setPeriodicInterval(STORE_MELT_CURVE_DATA_INTERVAL);
                _meltCurveTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::meltCurveCallback));
            }
            else
            {
                double interval = 0;
                double rate = _experiment.protocol()->currentRamp()->rate();

                rate = rate > 0 && rate <= kDurationCalcHeatBlockRampSpeed ? rate : kDurationCalcHeatBlockRampSpeed;

                if (HeatBlockInstance::getInstance()->temperature() < _experiment.protocol()->currentStep()->temperature())
                    interval = (_experiment.protocol()->currentStep()->temperature() - HeatBlockInstance::getInstance()->temperature()) / rate;
                else
                    interval = (HeatBlockInstance::getInstance()->temperature() - _experiment.protocol()->currentStep()->temperature()) / rate;

                interval = std::round(interval * 1000 - kOpticalFluorescenceMeasurmentPeriodMs);

                if (interval > 0)
                {
                    Optics::CollectionDataType collectionType = _experiment.type() != Experiment::CalibrationType ? Optics::FluorescenceDataType : Optics::FluorescenceCalibrationDataType;

                    _fluorescenceTimer->stop();
                    _fluorescenceTimer->setStartInterval(interval);
                    _fluorescenceTimer->setPeriodicInterval(0);
                    _fluorescenceTimer->start(TimerCallback([collectionType](){ OpticsInstance::getInstance()->startCollectData(collectionType); }));
                }
                else
                    OpticsInstance::getInstance()->startCollectData(_experiment.type() != Experiment::CalibrationType ? Optics::FluorescenceDataType : Optics::FluorescenceCalibrationDataType);
            }
        }

        OpticsInstance::getInstance()->getLedController()->setIntensity(_experiment.protocol()->currentRamp()->excitationIntensity());
    }

    calculateEstimatedDuration();
}

void ExperimentController::resume()
{
    if (OpticsInstance::getInstance()->lidOpen())
        throw std::runtime_error("Lid is open");
    
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
        OpticsInstance::getInstance()->stopCollectData();

        _experiment.setCompletionStatus(Experiment::Success);
        _experiment.setCompletedAt(boost::posix_time::microsec_clock::local_time());

        _dbControl->completeExperiment(_experiment);
    }

    _meltCurveTimer->stop();
}

void ExperimentController::stop()
{
    MachineState state = IdleMachineState;

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        shutdown();

        if (_machineState == IdleMachineState)
            return;

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

    stopLogging();
    stopDataSpaceCheck();

    if (state != CompleteMachineState)
    {
        _holdStepTimer->stop();
        _meltCurveTimer->stop();
        _fluorescenceTimer->stop();
    }

    APP_LOGGER << "ExperimentController::stop - experiment stopped" << std::endl;
}

void ExperimentController::stop(const std::string &errorMessage)
{
    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        shutdown();

        if (_machineState == IdleMachineState)
            return;

        _experiment.setCompletionStatus(Experiment::Failed);
        _experiment.setCompletionMessage(errorMessage);
        _experiment.setCompletedAt(boost::posix_time::microsec_clock::local_time());

        _dbControl->completeExperiment(_experiment);

        _machineState = IdleMachineState;
        _thermalState = IdleThermalState;
        _experiment = Experiment();
    }

    stopLogging();
    stopDataSpaceCheck();

    _holdStepTimer->stop();
    _meltCurveTimer->stop();
    _fluorescenceTimer->stop();

    APP_LOGGER << "ExperimentController::stop - experiment stopped with an error \'" << errorMessage << "\'" << std::endl;
}

bool ExperimentController::shutdown(MachineState checkState)
{
    Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

    if (_machineState != checkState)
        return false;

    shutdown();

    return true;
}

void ExperimentController::fluorescenceDataCollected()
{
    bool beginStep = false;

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

        if (_machineState != RunningMachineState || !_experiment.isExtended())
            return;

        beginStep = _experiment.hasBeganStep();

        _experiment.setExtended(false);
        _experiment.setStepBegan(false);
    }

    if (_thermalState == HeatingThermalState || _thermalState == CoolingThermalState)
    {
        rampFinished();

        if (beginStep)
            stepBegun();
    }
    else if (_thermalState == HoldingThermalState)
        holdStepCallback(*_holdStepTimer);
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

    Poco::RWLock::ScopedWriteLock lock(*_machineMutex);

    if (_machineState == RunningMachineState)
    {
        if (_experiment.protocol()->currentStage()->type() != Stage::Meltcurve && OpticsInstance::getInstance()->collectDataType() != Optics::NoCollectionDataType)
        {
            APP_LOGGER << "ExperimentController::rampFinished - a ramp has finished before fluorescence data is collected. Extending the ramp" << std::endl;

            _experiment.setExtended(true);

            return;
        }

        _thermalState = HoldingThermalState;

        if (_experiment.protocol()->currentStage()->type() == Stage::Meltcurve)
            _dbControl->addMeltCurveData(_experiment, OpticsInstance::getInstance()->getMeltCurveData());
        else
            _dbControl->addFluorescenceData(_experiment, OpticsInstance::getInstance()->getFluorescenceData(), true);

        OpticsInstance::getInstance()->getLedController()->setIntensity(_experiment.protocol()->currentStep()->excitationIntensity());
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

        if (stage->type() != Stage::Meltcurve && OpticsInstance::getInstance()->collectDataType() != Optics::NoCollectionDataType)
        {
            APP_LOGGER << "ExperimentController::stepBegun - a step has begin before fluorescence data is collected. Waiting for an extended ramp to finish" << std::endl;

            _experiment.setStepBegan(true);

            return;
        }

        if (!stage->currentStep()->pauseState())
        {
            std::time_t holdTime = stage->currentStepHoldTime();

            if (holdTime > 0 || _experiment.protocol()->hasNextStep())
            {
                if (stage->currentStep()->collectData() && holdTime > 0)
                {
                    std::time_t interval = holdTime * 1000 - kOpticalFluorescenceMeasurmentPeriodMs;

                    if (interval > 0)
                    {
                        Optics::CollectionDataType collectionType = _experiment.type() != Experiment::CalibrationType ? Optics::FluorescenceDataType : Optics::FluorescenceCalibrationDataType;

                        _fluorescenceTimer->stop();
                        _fluorescenceTimer->setStartInterval(interval);
                        _fluorescenceTimer->setPeriodicInterval(0);
                        _fluorescenceTimer->start(TimerCallback([collectionType](){ OpticsInstance::getInstance()->startCollectData(collectionType); }));
                    }
                    else
                        OpticsInstance::getInstance()->startCollectData(_experiment.type() != Experiment::CalibrationType ? Optics::FluorescenceDataType : Optics::FluorescenceCalibrationDataType);
                }

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
        {
            if (OpticsInstance::getInstance()->collectDataType() == Optics::NoCollectionDataType)
                _dbControl->addFluorescenceData(_experiment, OpticsInstance::getInstance()->getFluorescenceData());
            else
            {
                APP_LOGGER << "ExperimentController::holdStepCallback - a step has finished before fluorescence data is collected. Extending the step" << std::endl;

                _experiment.setExtended(true);

                return;
            }
        }

        if (_experiment.protocol()->hasNextStep())
        {
            _experiment.protocol()->advanceNextStep();

            Stage *stage = _experiment.protocol()->currentStage();
            double temperature = stage->currentStepTemperature(HeatBlockInstance::getInstance()->minTargetTemperature(), HeatBlockInstance::getInstance()->maxTargetTemperature());

            if (stage->currentRamp()->collectData())
            {
                if (stage->type() == Stage::Meltcurve)
                {
                    OpticsInstance::getInstance()->startCollectData(Optics::MeltCurveDataType);

                    _meltCurveTimer->setPeriodicInterval(STORE_MELT_CURVE_DATA_INTERVAL);
                    _meltCurveTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::meltCurveCallback));
                }
                else
                {
                    double interval = 0;
                    double rate = _experiment.protocol()->currentRamp()->rate();

                    rate = rate > 0 && rate <= kDurationCalcHeatBlockRampSpeed ? rate : kDurationCalcHeatBlockRampSpeed;

                    if (HeatBlockInstance::getInstance()->temperature() < temperature)
                        interval = (temperature - HeatBlockInstance::getInstance()->temperature()) / rate;
                    else
                        interval = (HeatBlockInstance::getInstance()->temperature() - temperature) / rate;

                    interval = std::round(interval * 1000 - kOpticalFluorescenceMeasurmentPeriodMs);

                    if (interval > 0)
                    {
                        Optics::CollectionDataType collectionType = _experiment.type() != Experiment::CalibrationType ? Optics::FluorescenceDataType : Optics::FluorescenceCalibrationDataType;

                        _fluorescenceTimer->stop();
                        _fluorescenceTimer->setStartInterval(interval);
                        _fluorescenceTimer->setPeriodicInterval(0);
                        _fluorescenceTimer->start(TimerCallback([collectionType](){ OpticsInstance::getInstance()->startCollectData(collectionType); }));
                    }
                    else
                        OpticsInstance::getInstance()->startCollectData(_experiment.type() != Experiment::CalibrationType ? Optics::FluorescenceDataType : Optics::FluorescenceCalibrationDataType);
                }
            }

            _thermalState = HeatBlockInstance::getInstance()->temperature() < temperature ? HeatingThermalState : CoolingThermalState;

            OpticsInstance::getInstance()->getLedController()->setIntensity(stage->currentRamp()->excitationIntensity());

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

    _dbControl->addTemperatureLog(_logs);
    _logs.clear();
}

void ExperimentController::addLogCallback(Poco::Timer &)
{
    TemperatureLog log;

    {
        Poco::RWLock::ScopedReadLock lock(*_machineMutex);

        if (_machineState == IdleMachineState)
            return;

        log = TemperatureLog(_experiment.id(), _experiment.protocol()->currentStage()->id(), true, _settings.debugMode);

        if (_thermalState == HoldingThermalState)
            log.setStepId(_experiment.protocol()->currentStep()->id());
        else
            log.setRampId(_experiment.protocol()->currentRamp()->id());

        log.setCycleNum(_experiment.protocol()->currentStage()->currentCycle());
        log.setElapsedTime((boost::posix_time::microsec_clock::local_time() - _experiment.startedAt()).total_milliseconds());
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
        log.setHeatSinkTemperature(HeatSinkInstance::getInstance()->currentTemperature());
        log.setHeatSinkDrive(HeatSinkInstance::getInstance()->fanDrive());
    }

    _logs.push_back(std::move(log));

    if ((_logs.back().elapsedTime() - _logs.front().elapsedTime()) >= kTemperatureLoggerFlushInterval)
    {
        _dbControl->addTemperatureLog(_logs);
        _logs.clear();
    }
}

void ExperimentController::startDataSpaceCheck()
{
    _dataSpaceTimer->setPeriodicInterval(kDataSpaceCheckInterval);
    _dataSpaceTimer->start(Poco::TimerCallback<ExperimentController>(*this, &ExperimentController::checkDataSpace));
}

void ExperimentController::stopDataSpaceCheck()
{
    _dataSpaceTimer->restart(0); //Restart is used here because the timer can be stopped within its callback
}

void ExperimentController::checkDataSpace(Poco::Timer &/*timer*/)
{
    unsigned long dataSpace = 0;

    if (Util::getPartitionAvailableSpace(kDataPartitionpath, dataSpace))
    {
        if (qpcrApp.settings().configuration.dataSpaceSoftLimit >= dataSapce)
            stop("Out of storage space");
    }
    else
    {
        APP_LOGGER << "ExperimentController::checkDataSpace - unable to get the available space of the data partition" << std::endl;

        stop("Out of storage space");
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
        std::time_t holdTime = stage->currentStepHoldTime();
        double temperature = stage->currentStepTemperature(HeatBlockInstance::getInstance()->minTargetTemperature(), HeatBlockInstance::getInstance()->maxTargetTemperature());
        double rate = stage->currentRamp()->rate();
        double rampDuration = 0;

        rate = rate > 0 && rate <= kDurationCalcHeatBlockRampSpeed ? rate : kDurationCalcHeatBlockRampSpeed;

        if (previousTargetTemp < temperature)
            rampDuration = (temperature - previousTargetTemp) / rate * 1000;
        else
            rampDuration = (previousTargetTemp - temperature) / rate * 1000;

        if (stage->type() != Stage::Meltcurve)
        {
            if (stage->currentRamp()->collectData())
            {
                double interval = std::round(rampDuration - kOpticalFluorescenceMeasurmentPeriodMs);

                if (interval < 0)
                    rampDuration += interval * -1;
            }

            if (stage->currentStep()->collectData() && holdTime > 0)
            {
                double interval = holdTime * 1000 - kOpticalFluorescenceMeasurmentPeriodMs;

                if (interval < 0)
                    duration += interval * -1;
            }
        }

        duration += rampDuration + holdTime * 1000;
        previousTargetTemp = temperature;
    }
    while (experiment.protocol()->advanceNextStep());

    {
        Poco::RWLock::ScopedWriteLock lock(*_machineMutex);
        _experiment.setEstimatedDuration(std::round(duration / 1000));
    }
}
