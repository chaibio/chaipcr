#include "logdatahandler.h"
#include "maincontrollers.h"
#include "experimentcontroller.h"
#include "settings.h"

using namespace boost::property_tree;

void LogDataHandler::processData(const ptree &requestPt, ptree &)
{
    std::shared_ptr<Optics> optics = OpticsInstance::getInstance();
    std::shared_ptr<ExperimentController> experimentController = ExperimentController::getInstance();

    if (optics)
    {
        ptree::const_assoc_iterator opticalData = requestPt.find("opticalData");

        if (opticalData != requestPt.not_found())
            optics->setCollectData(opticalData->second.get_value<bool>());
    }

    if (experimentController)
    {
        ptree::const_assoc_iterator temperatureData = requestPt.find("temperatureData");
        ptree::const_assoc_iterator temperatureDebugData = requestPt.find("temperatureDebugData");

        if (temperatureData != requestPt.not_found())
            experimentController->settings()->temperatureLogs.setTemperatureLogs(temperatureData->second.get_value<bool>());

        if (temperatureDebugData != requestPt.not_found())
            experimentController->settings()->temperatureLogs.setDebugTemperatureLogs(temperatureDebugData->second.get_value<bool>());

        experimentController->toggleTempLogs();
    }
}
