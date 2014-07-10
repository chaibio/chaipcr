#include "pcrincludes.h"
#include "pocoincludes.h"
#include "boostincludes.h"

#include "settings.h"
#include "experimentcontroller.h"

#include "settingshandler.h"

void SettingsHandler::processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &)
{
    Settings *settings = ExperimentController::getInstance()->settings();

    settings->setDebuMode(requestPt.get("debugMode", false));

    ExperimentController::getInstance()->settingsUpdated();
}
