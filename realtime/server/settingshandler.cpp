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

    if (settings.isDebugModeDirty())
        ExperimentController::getInstance()->setDebugMode(settings.debugMode());

    //ExperimentController::getInstance()->updateSettings(settings);
}
