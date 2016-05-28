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
