#include "settings.h"
#include "experimentcontroller.h"

#include "settingshandler.h"

void SettingsHandler::processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &)
{
    Settings *settings = ExperimentController::getInstance()->settings();

    settings->setDebugMode(requestPt.get("debugMode", false));

    ExperimentController::getInstance()->settingsUpdated();
}
