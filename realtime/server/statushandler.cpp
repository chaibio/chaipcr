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

#include <cmath>
#include <utility>
#include <map>
#include <boost/date_time.hpp>

#include "controlincludes.h"
#include "dbincludes.h"
#include "experimentcontroller.h"
#include "qpcrapplication.h"
#include "updatemanager.h"

#include "statushandler.h"

#define ROUND(x) ((float)(std::round(x * 1000.0) / 1000.0))

void StatusHandler::processData(const boost::property_tree::ptree &, boost::property_tree::ptree &responsePt) {
    std::shared_ptr<ExperimentController> experimentController = ExperimentController::getInstance();

    if (experimentController) {
        Experiment experiment = experimentController->experiment();
        ExperimentController::MachineState state = experimentController->machineState();

        switch (state) {
        case ExperimentController::IdleMachineState:
            responsePt.put("experiment_controller.machine.state", "idle");
            break;

        case ExperimentController::LidHeatingMachineState:
            responsePt.put("experiment_controller.machine.state", "lid_heating");
            responsePt.put("experiment_controller.experiment.run_duration",
                           boost::chrono::duration_cast<boost::chrono::seconds>(boost::chrono::steady_clock::now() - experiment.startedAtPoint()).count());
            break;

        case ExperimentController::RunningMachineState:
            responsePt.put("experiment_controller.machine.state", "running");
            responsePt.put("experiment_controller.experiment.run_duration",
                           boost::chrono::duration_cast<boost::chrono::seconds>(boost::chrono::steady_clock::now() - experiment.startedAtPoint()).count());
            responsePt.put("experiment_controller.experiment.estimated_duration",
                           boost::chrono::duration_cast<boost::chrono::seconds>(experiment.estimatedDuration()).count());
            responsePt.put("experiment_controller.experiment.paused_duration",
                           boost::chrono::duration_cast<boost::chrono::seconds>(experiment.pausedDuration()).count());
            break;

        case ExperimentController::PausedMachineState:
            responsePt.put("experiment_controller.machine.state", "paused");
            responsePt.put("experiment_controller.experiment.run_duration",
                           boost::chrono::duration_cast<boost::chrono::seconds>(boost::chrono::steady_clock::now() - experiment.startedAtPoint()).count());
            responsePt.put("experiment_controller.experiment.estimated_duration",
                           boost::chrono::duration_cast<boost::chrono::seconds>(experiment.estimatedDuration()).count());
            responsePt.put("experiment_controller.experiment.paused_duration",
                           boost::chrono::duration_cast<boost::chrono::seconds>(experiment.pausedDuration() + (boost::chrono::steady_clock::now() - experiment.lastPauseTime())).count());
            break;

        case ExperimentController::CompleteMachineState:
            responsePt.put("experiment_controller.machine.state", "complete");
            responsePt.put("experiment_controller.experiment.run_duration",
                           boost::chrono::duration_cast<boost::chrono::seconds>(experiment.completedAtPoint() - experiment.startedAtPoint()).count());
            break;

        default:
            responsePt.put("experiment_controller.machine.state", "unknown");
            break;
        }

        switch (experimentController->thermalState())
        {
        case ExperimentController::IdleThermalState:
            responsePt.put("experiment_controller.machine.thermal_state", "idle");
            break;

        case ExperimentController::HoldingThermalState:
            responsePt.put("experiment_controller.machine.thermal_state", "holding");
            break;

        case ExperimentController::HeatingThermalState:
            responsePt.put("experiment_controller.machine.thermal_state", "heating");
            break;

        case ExperimentController::CoolingThermalState:
            responsePt.put("experiment_controller.machine.thermal_state", "cooling");
            break;

        default:
            responsePt.put("experiment_controller.machine.thermal_state", "unknown");
            break;
        }

        if (experimentController->machineState() != ExperimentController::IdleMachineState) {
            responsePt.put("experiment_controller.experiment.id", experiment.id());
            responsePt.put("experiment_controller.experiment.name", experiment.name());
            responsePt.put("experiment_controller.experiment.started_at", experiment.startedAt());

            responsePt.put("experiment_controller.experiment.stage.id", experiment.protocol()->currentStage()->id());
            responsePt.put("experiment_controller.experiment.stage.name", experiment.protocol()->currentStage()->name());
            responsePt.put("experiment_controller.experiment.stage.number", experiment.protocol()->currentStage()->orderNumber() + 1);
            responsePt.put("experiment_controller.experiment.stage.cycle", experiment.protocol()->currentStage()->currentCycle());

            responsePt.put("experiment_controller.experiment.step.id", experiment.protocol()->currentStep()->id());
            responsePt.put("experiment_controller.experiment.step.name", experiment.protocol()->currentStep()->name());
            responsePt.put("experiment_controller.experiment.step.number", experiment.protocol()->currentStep()->orderNumber() + 1);
        }

        std::shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();
        std::shared_ptr<Optics> optics = OpticsInstance::getInstance();
        std::shared_ptr<Lid> lid = LidInstance::getInstance();
        std::shared_ptr<HeatSink> heatSink = HeatSinkInstance::getInstance();

        if (heatBlock) {
            responsePt.put("heat_block.zone1.temperature", ROUND(heatBlock->zone1Temperature()));
            responsePt.put("heat_block.zone1.target_temperature", state == ExperimentController::RunningMachineState ? ROUND(heatBlock->zone1TargetTemperature()) : 0);
            responsePt.put("heat_block.zone1.drive", ROUND(heatBlock->zone1DriveValue()));

            responsePt.put("heat_block.zone2.temperature", ROUND(heatBlock->zone2Temperature()));
            responsePt.put("heat_block.zone2.target_temperature", state == ExperimentController::RunningMachineState ? ROUND(heatBlock->zone2TargetTemperature()) : 0);
            responsePt.put("heat_block.zone2.drive", ROUND(heatBlock->zone2DriveValue()));

            responsePt.put("heat_block.temperature", ROUND(heatBlock->temperature()));
        }

        if (lid) {
            responsePt.put("lid.temperature", ROUND(lid->currentTemperature()));
            responsePt.put("lid.target_temperature", state == ExperimentController::LidHeatingMachineState || state == ExperimentController::RunningMachineState ? ROUND(lid->targetTemperature()) : 0);
            responsePt.put("lid.drive", ROUND(lid->drive()));
        }

        if (optics) {
            responsePt.put("optics.intensity", optics->getLedController()->intensity());
            responsePt.put("optics.collect_data", optics->collectDataType() != Optics::NoCollectionDataType);
            responsePt.put("optics.lid_open", optics->lidOpen());
            responsePt.put("optics.well_number", state == ExperimentController::RunningMachineState ? optics->wellNumber() : 0);

            boost::property_tree::ptree adcArray;
            const std::map<std::size_t, std::atomic<int32_t>> &adcValues = optics->lastAdcValues();

            for (std::map<std::size_t, std::atomic<int32_t>>::const_iterator it = adcValues.begin(); it != adcValues.end(); ++it)
            {
                boost::property_tree::ptree item;
                item.put("", it->second);

                adcArray.push_back(std::make_pair("", item));
            }

            responsePt.put_child("optics.photodiode_value", adcArray);
        }

        if (heatSink) {
            responsePt.put("heat_sink.temperature", ROUND(heatSink->currentTemperature()));
            responsePt.put("heat_sink.fan_drive", ROUND(heatSink->fanDrive()));
        }
    }

    switch (qpcrApp.updateManager()->updateState())
    {
    case UpdateManager::Unavailable:
        responsePt.put("device.update_available", "unavailable");
        break;

    case UpdateManager::Available:
        responsePt.put("device.update_available", "available");
        break;

    case UpdateManager::Downloading:
    case UpdateManager::ManualDownloading:
        responsePt.put("device.update_available", "downloading");
        break;

    case UpdateManager::Updating:
        responsePt.put("device.update_available", "updating");
        break;

    default:
        responsePt.put("device.update_available", "unknown");

        UpdateManager::ErrorInfo error = qpcrApp.updateManager()->lastError();

        if (error.code != UpdateManager::ErrorInfo::NoError)
        {
            switch (error.code)
            {
            case UpdateManager::ErrorInfo::InvalidImage:
                responsePt.put("device.update_error.code", "invalid_image");
                break;

            case UpdateManager::ErrorInfo::UplodFaild:
                responsePt.put("device.update_error.code", "upload_failed");
                break;

            case UpdateManager::ErrorInfo::NetworkError:
                responsePt.put("device.update_error.code", "network_error");
                break;

            default:
                responsePt.put("device.update_error.code", "unknown_error");
                break;
            }

            responsePt.put("device.update_error.message", error.message);
        }

        break;
    }
}
