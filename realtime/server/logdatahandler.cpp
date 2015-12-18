#include "logdatahandler.h"
#include "maincontrollers.h"
#include "experimentcontroller.h"

using namespace boost::property_tree;

void LogDataHandler::processData(const ptree &requestPt, ptree &)
{
    std::shared_ptr<Optics> optics = OpticsInstance::getInstance();
    std::shared_ptr<ExperimentController> experimentController = ExperimentController::getInstance();

    if (optics)
    {
        ptree::const_assoc_iterator opticalData = requestPt.find("optical_data");

        if (opticalData != requestPt.not_found())
            optics->setCollectData(opticalData->second.get_value<bool>());
    }

    if (experimentController)
    {
        ptree::const_assoc_iterator temperatureData = requestPt.find("temperature_data");
        ptree::const_assoc_iterator temperatureDebugData = requestPt.find("temperature_debug_data");

        bool tempLogsState = experimentController->settings().temperatureLogsState;
        bool debugTempLogsState = experimentController->settings().debugTemperatureLogsState;

        if (temperatureData != requestPt.not_found())
            tempLogsState = temperatureData->second.get_value<bool>();

        if (temperatureDebugData != requestPt.not_found())
            debugTempLogsState = temperatureDebugData->second.get_value<bool>();

        experimentController->toggleTempLogs(tempLogsState, debugTempLogsState);
    }
}
