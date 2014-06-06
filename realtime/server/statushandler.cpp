#include "pcrincludes.h"
#include "boostincludes.h"
#include "pocoincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"
#include "dbincludes.h"
#include "experimentcontroller.h"

#include "statushandler.h"

void StatusHandler::processData(const boost::property_tree::ptree &, boost::property_tree::ptree &responsePt) {
    std::shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();
    std::shared_ptr<Optics> optics = OpticsInstance::getInstance();
    std::shared_ptr<Lid> lid = LidInstance::getInstance();
    std::shared_ptr<HeatSink> heatSink = HeatSinkInstance::getInstance();
    std::shared_ptr<ExperimentController> experimentController = ExperimentController::getInstance();

    if (heatBlock) {
        responsePt.put("heatblock.zone1.temperature", heatBlock->zone1Temperature());
        responsePt.put("heatblock.zone1.drive", (double)heatBlock->zone1DriveValue());

        responsePt.put("heatblock.zone2.temperature", heatBlock->zone2Temperature());
        responsePt.put("heatblock.zone2.drive", (double)heatBlock->zone2DriveValue());
    }

    if (lid) {
        responsePt.put("lid.temperature", lid->currentTemperature());
        responsePt.put("lid.drive", (double)lid->pwmDutyCycle() / lid->pwmPeriod());
    }

    if (optics) {
        responsePt.put("optics.intensity", optics->getLedController()->intensity());
        responsePt.put("optics.collectData", optics->collectData());
        responsePt.put("optics.lidOpen", optics->lidOpen());
        responsePt.put("optics.photodiodeValue", (optics->adcValue() >> 8));
    }

    if (heatSink) {
        responsePt.put("heatSink.temperature", heatSink->currentTemperature());
    }

    if (experimentController) {
        switch (experimentController->machineState()) {
        case ExperimentController::Idle:
            responsePt.put("experimentController.machine.state", "Idle");
            break;

        case ExperimentController::LidHeating:
            responsePt.put("experimentController.machine.state", "LidHeating");
            responsePt.put("experimentController.expriment.run_duration", (boost::posix_time::microsec_clock::local_time() - experimentController->experiment()->startedAt()).total_seconds());
            break;

        case ExperimentController::Running:
            responsePt.put("experimentController.machine.state", "Running");
            responsePt.put("experimentController.expriment.run_duration", (boost::posix_time::microsec_clock::local_time() - experimentController->experiment()->startedAt()).total_seconds());
            break;

        case ExperimentController::Complete:
            responsePt.put("experimentController.machine.state", "Complete");
            responsePt.put("experimentController.expriment.run_duration", (experimentController->experiment()->completedAt() - experimentController->experiment()->startedAt()).total_seconds());
            break;

        default:
            responsePt.put("experimentController.machine.state", "Unknown");
            break;
        }

        if (experimentController->machineState() != ExperimentController::Idle)
            responsePt.put("experimentController.expriment.started_at", experimentController->experiment()->startedAt());
    }
}
