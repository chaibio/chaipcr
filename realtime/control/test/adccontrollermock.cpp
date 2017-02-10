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

#include "adccontrollermock.h"
#include "maincontrollers.h"

const double kLidTempIncrement = 2.0;

ADCControllerMock::ADCControllerMock(ConsumersList &&consumers, unsigned int csPinNumber, SPIPort &&spiPort, unsigned int busyPinNumber):
    ADCController(std::move(consumers), csPinNumber, std::move(spiPort), busyPinNumber) {
}

void ADCControllerMock::process() {
    for (std::shared_ptr<ADCConsumer> &consumer: _consumers)
        consumer->setADCValueMock(30);

    _workState = true;
    while (_workState) {
        sleep(1);

        loopStarted();

        processHeatBlock();
        processLid();
        processOptics();

        _currentConversionState = calcNextState(_currentChannel);
    }
}

void ADCControllerMock::processHeatBlock() {
    std::shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();

    if (heatBlock) {
        _consumers[EReadZone1Singular]->setADCValueMock(heatBlock->zone1TargetTemperature());
        _consumers[EReadZone2Singular]->setADCValueMock(heatBlock->zone1TargetTemperature());
    }
}

void ADCControllerMock::processLid() {
    std::shared_ptr<Lid> lid = LidInstance::getInstance();

    if (lid) {
        double targetTemp = lid->targetTemperature();
        double temp = lid->currentTemperature();

        if (targetTemp > temp) {
            if ((temp + kLidTempIncrement) > targetTemp)
                _consumers[EReadLid]->setADCValueMock(targetTemp);
            else
                _consumers[EReadLid]->setADCValueMock(temp + kLidTempIncrement);
        }
        else if (targetTemp < temp) {
            if ((temp - kLidTempIncrement) < targetTemp)
                _consumers[EReadLid]->setADCValueMock(targetTemp);
            else
                _consumers[EReadLid]->setADCValueMock(temp - kLidTempIncrement);
        }
    }
}

void ADCControllerMock::processOptics() {

}
