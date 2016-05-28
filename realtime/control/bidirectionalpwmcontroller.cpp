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

#include "bidirectionalpwmcontroller.h"

BidirectionalPWMController::BidirectionalPWMController(Settings settings, const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin)
    :TemperatureController(settings), PWMControl(pwmPath, pwmPeriod), _heatIO(heatIOPin, GPIO::kOutput), _coolIO(coolIOPin, GPIO::kOutput)
{
    resetOutput();
}

BidirectionalPWMController::~BidirectionalPWMController()
{
    resetOutput();
}

BidirectionalPWMController::Direction BidirectionalPWMController::outputDirection() const
{
    return _heatIO.value() == GPIO::kHigh ? EHeat : ECool;
}

void BidirectionalPWMController::setOutput(double value)
{
    setPWMDutyCycle(value >= 0 ? value : (value * -1));

    if (value >= 0)
    {
        _coolIO.setValue(GPIO::kLow, true);
        _heatIO.setValue(GPIO::kHigh, true);
    }
    else
    {
        _heatIO.setValue(GPIO::kLow, true);
        _coolIO.setValue(GPIO::kHigh, true);
    }
}

void BidirectionalPWMController::resetOutput()
{
    setPWMDutyCycle(0.0);

    _heatIO.setValue(GPIO::kLow, true);
    _coolIO.setValue(GPIO::kLow, true);
}

void BidirectionalPWMController::processOutput()
{

}
