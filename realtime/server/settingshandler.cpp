#include "settings.h"
#include "experimentcontroller.h"

#include "settingshandler.h"

void SettingsHandler::processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &)
{
    Settings settings;

    boost::property_tree::ptree::const_assoc_iterator it = requestPt.find("debugMode");
    if (it != requestPt.not_found())
        settings.setDebugMode(it->second.get_value<bool>());

    it = requestPt.find("timeZone");
    if (it != requestPt.not_found())
        settings.setTimeZone(it->second.get_value<std::string>());

    it = requestPt.find("wifiSsid");
    if (it != requestPt.not_found())
        settings.setWifiSsid(it->second.get_value<std::string>());

    it = requestPt.find("wifiPassword");
    if (it != requestPt.not_found())
        settings.setWifiPassword(it->second.get_value<std::string>());

    it = requestPt.find("wifiEnabled");
    if (it != requestPt.not_found())
        settings.setWifiEnabled(it->second.get_value<bool>());

    it = requestPt.find("calibrationId");
    if (it != requestPt.not_found())
        settings.setCallibrationId(it->second.get_value<int>());

    it = requestPt.find("timeValid");
    if (it != requestPt.not_found())
        settings.setTimeValid(it->second.get_value<bool>());

    ExperimentController::getInstance()->updateSettings(settings);
}
