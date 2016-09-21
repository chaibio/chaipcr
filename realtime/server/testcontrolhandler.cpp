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

#include "pcrincludes.h"
#include "controlincludes.h"
#include "experimentcontroller.h"
#include "testcontrolhandler.h"

using namespace std;
using namespace boost::property_tree;
using namespace Poco::Net;

void TestControlHandler::processData(const ptree &requestPt, ptree &)
{
    processOptics(requestPt);
    processLid(requestPt);
    processHeatSink(requestPt);
    processHeatBlock(requestPt);
}

void TestControlHandler::processOptics(const ptree &requestPt)
{
    shared_ptr<Optics> optics = OpticsInstance::getInstance();

    if (optics)
    {
        ptree::const_assoc_iterator ledIntensity = requestPt.find("led_intensity");
        ptree::const_assoc_iterator activateLED = requestPt.find("activate_led");
        ptree::const_assoc_iterator disableLEDs = requestPt.find("disable_leds");
        ptree::const_assoc_iterator photodiodeMuxChannel = requestPt.find("photodiode_mux_channel");

        if (ledIntensity != requestPt.not_found())
            optics->getLedController()->setIntensity(ledIntensity->second.get_value<double>());

        if (activateLED != requestPt.not_found())
            optics->getLedController()->activateLED(kWellToLedMappingList.at(activateLED->second.get_value<int>()));

        if (disableLEDs != requestPt.not_found())
            optics->getLedController()->disableLEDs();

        if (photodiodeMuxChannel != requestPt.not_found())
            optics->getPhotodiodeMux().setChannel(photodiodeMuxChannel->second.get_value<int>());
    }
}

void TestControlHandler::processLid(const ptree &requestPt)
{
    shared_ptr<Lid> lid = LidInstance::getInstance();

    if (lid)
    {
        ptree::const_assoc_iterator lidTargetTemp = requestPt.find("lid_target_temp");
        ptree::const_assoc_iterator lidDrive = requestPt.find("lid_drive");

        if (lidTargetTemp != requestPt.not_found())
        {
            lid->setTargetTemperature(lidTargetTemp->second.get_value<double>());
            lid->setEnableMode(true);
        }

        if (lidDrive != requestPt.not_found())
            lid->setOutput(lidDrive->second.get_value<double>());
    }
}

void TestControlHandler::processHeatSink(const ptree &requestPt)
{
    shared_ptr<HeatSink> heatSink = HeatSinkInstance::getInstance();

    if (heatSink)
    {
        ptree::const_assoc_iterator heatSinkTargetTemp = requestPt.find("heat_sink_target_temp");
        ptree::const_assoc_iterator heatSinkDrive = requestPt.find("heat_sink_fan_drive");

        if (heatSinkTargetTemp != requestPt.not_found())
            heatSink->setTargetTemperature(heatSinkTargetTemp->second.get_value<double>());

        if (heatSinkDrive != requestPt.not_found())
        {
            if (ExperimentController::getInstance()->machineState() == ExperimentController::IdleMachineState)
                heatSink->setEnableMode(false);

            heatSink->setOutput(heatSinkDrive->second.get_value<double>());
        }
    }
}

void TestControlHandler::processHeatBlock(const ptree &requestPt)
{
    shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();

    if (heatBlock)
    {
        ptree::const_assoc_iterator heatBlockTargetTemp = requestPt.find("heat_block_target_temp");
        ptree::const_assoc_iterator heatBlockDrive = requestPt.find("heat_block_drive");

        if (heatBlockTargetTemp != requestPt.not_found())
        {
            heatBlock->setTargetTemperature(heatBlockTargetTemp->second.get_value<double>());
            heatBlock->setEnableMode(true);
        }

        if (heatBlockDrive != requestPt.not_found())
            heatBlock->setDrive(heatBlockDrive->second.get_value<double>());
    }
}
