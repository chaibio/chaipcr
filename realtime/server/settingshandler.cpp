#include "settings.h"
#include "experimentcontroller.h"

#include "settingshandler.h"

void SettingsHandler::processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &)
{
    Settings settings;

    boost::property_tree::ptree::const_assoc_iterator it = requestPt.find("debug_mode");
    if (it != requestPt.not_found())
        settings.setDebugMode(it->second.get_value<bool>());

    it = requestPt.find("time_zone");
    if (it != requestPt.not_found())
        settings.setTimeZone(it->second.get_value<std::string>());

    it = requestPt.find("wifi_ssid");
    if (it != requestPt.not_found())
        settings.setWifiSsid(it->second.get_value<std::string>());

    it = requestPt.find("wifi_password");
    if (it != requestPt.not_found())
        settings.setWifiPassword(it->second.get_value<std::string>());

    it = requestPt.find("wifi_enabled");
    if (it != requestPt.not_found())
        settings.setWifiEnabled(it->second.get_value<bool>());

    it = requestPt.find("calibration_id");
    if (it != requestPt.not_found())
        settings.setCallibrationId(it->second.get_value<int>());

    it = requestPt.find("time_valid");
    if (it != requestPt.not_found())
        settings.setTimeValid(it->second.get_value<bool>());

    ExperimentController::getInstance()->updateSettings(settings);
}
