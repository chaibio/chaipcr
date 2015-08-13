#include <cmath>
#include <boost/date_time.hpp>

#include "controlincludes.h"
#include "dbincludes.h"
#include "experimentcontroller.h"

#include "statushandler.h"

#define ROUND(x) ((float)(std::round(x * 1000.0) / 1000.0))

void StatusHandler::processData(const boost::property_tree::ptree &, boost::property_tree::ptree &responsePt) {
    std::shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();
    std::shared_ptr<Optics> optics = OpticsInstance::getInstance();
    std::shared_ptr<Lid> lid = LidInstance::getInstance();
    std::shared_ptr<HeatSink> heatSink = HeatSinkInstance::getInstance();
    std::shared_ptr<ExperimentController> experimentController = ExperimentController::getInstance();

    if (heatBlock) {
        responsePt.put("heatblock.zone1.temperature", ROUND(heatBlock->zone1Temperature()));
        responsePt.put("heatblock.zone1.drive", ROUND(heatBlock->zone1DriveValue()));

        responsePt.put("heatblock.zone2.temperature", ROUND(heatBlock->zone2Temperature()));
        responsePt.put("heatblock.zone2.drive", ROUND(heatBlock->zone2DriveValue()));

        responsePt.put("heatblock.temperature", ROUND(heatBlock->temperature()));
    }

    if (lid) {
        responsePt.put("lid.temperature", ROUND(lid->currentTemperature()));
        responsePt.put("lid.drive", ROUND(lid->drive()));
    }

    if (optics) {
        responsePt.put("optics.intensity", optics->getLedController()->intensity());
        responsePt.put("optics.collectData", optics->collectData());
        responsePt.put("optics.lidOpen", optics->lidOpen());
        responsePt.put("optics.photodiodeValue", optics->adcValue());
    }

    if (heatSink) {
        responsePt.put("heatSink.temperature", ROUND(heatSink->currentTemperature()));
        responsePt.put("heatSink.fanDrive", ROUND(heatSink->fanDrive()));
    }

    if (experimentController) {
        Experiment experiment = experimentController->experiment();

        switch (experimentController->machineState()) {
        case ExperimentController::IdleMachineState:
            responsePt.put("experimentController.machine.state", "Idle");
            break;

        case ExperimentController::LidHeatingMachineState:
            responsePt.put("experimentController.machine.state", "LidHeating");
            responsePt.put("experimentController.expriment.run_duration", (boost::posix_time::microsec_clock::local_time() - experiment.startedAt()).total_seconds());
            break;

        case ExperimentController::RunningMachineState:
            responsePt.put("experimentController.machine.state", "Running");
            responsePt.put("experimentController.expriment.run_duration", (boost::posix_time::microsec_clock::local_time() - experiment.startedAt()).total_seconds());
            responsePt.put("experimentController.expriment.estimated_duration", experiment.estimatedDuration());
            responsePt.put("experimentController.expriment.paused_duration", experiment.pausedDuration());
            break;

        case ExperimentController::PausedMachineState:
            responsePt.put("experimentController.machine.state", "Paused");
            responsePt.put("experimentController.expriment.run_duration", (boost::posix_time::microsec_clock::local_time() - experiment.startedAt()).total_seconds());
            responsePt.put("experimentController.expriment.estimated_duration", experiment.estimatedDuration());
            responsePt.put("experimentController.expriment.paused_duration", experiment.pausedDuration() +
                           (boost::posix_time::microsec_clock::local_time() - experiment.lastPauseTime()).total_seconds());
            break;

        case ExperimentController::CompleteMachineState:
            responsePt.put("experimentController.machine.state", "Complete");
            responsePt.put("experimentController.expriment.run_duration", (experiment.completedAt() - experiment.startedAt()).total_seconds());
            break;

        default:
            responsePt.put("experimentController.machine.state", "Unknown");
            break;
        }

        switch (experimentController->thermalState())
        {
        case ExperimentController::IdleThermalState:
            responsePt.put("experimentController.machine.thermal_state", "Idle");
            break;

        case ExperimentController::HoldingThermalState:
            responsePt.put("experimentController.machine.thermal_state", "Holding");
            break;

        case ExperimentController::HeatingThermalState:
            responsePt.put("experimentController.machine.thermal_state", "Heating");
            break;

        case ExperimentController::CoolingThermalState:
            responsePt.put("experimentController.machine.thermal_state", "Cooling");
            break;

        default:
            responsePt.put("experimentController.machine.thermal_state", "Unknown");
            break;
        }

        if (experimentController->machineState() != ExperimentController::IdleMachineState) {
            responsePt.put("experimentController.expriment.id", experiment.id());
            responsePt.put("experimentController.expriment.name", experiment.name());
            responsePt.put("experimentController.expriment.started_at", experiment.startedAt());

            responsePt.put("experimentController.expriment.stage.id", experiment.protocol()->currentStage()->id());
            responsePt.put("experimentController.expriment.stage.name", experiment.protocol()->currentStage()->name());
            responsePt.put("experimentController.expriment.stage.number", experiment.protocol()->currentStage()->orderNumber() + 1);
            responsePt.put("experimentController.expriment.stage.cycle", experiment.protocol()->currentStage()->currentCycle());

            responsePt.put("experimentController.expriment.step.id", experiment.protocol()->currentStep()->id());
            responsePt.put("experimentController.expriment.step.name", experiment.protocol()->currentStep()->name());
            responsePt.put("experimentController.expriment.step.number", experiment.protocol()->currentStep()->orderNumber() + 1);
        }
    }
}
