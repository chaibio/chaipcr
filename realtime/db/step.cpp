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

#include "step.h"
#include "constants.h"

Step::Step(int id)
{
    _id = id;
    _temperature = 0;
    _holdTime = 0;
    _orderNumber = 0;
    _collectData = true;
    _deltaTemperature = 0;
    _deltaDuration = 0;
    _pauseState = false;
    _excitationIntensity = kDefaultLEDCurrent;
}

Step::Step(const Step &other)
    :Step(other.id())
{
    setName(other.name());
    setTemperature(other.temperature());
    setHoldTime(other.holdTime());
    setOrderNumber(other.orderNumber());
    setCollectData(other.collectData());
    setDeltaTemperature(other.deltaTemperature());
    setDeltaDuration(other.deltaDuration());
    setPauseState(other.pauseState());
    setExcitationIntensity(other.excitationIntensity());
}

Step::Step(Step &&other)
    :Step(other._id)
{
    _name = std::move(other._name);
    _temperature = other._temperature;
    _holdTime = other._holdTime;
    _orderNumber = other._orderNumber;
    _collectData = other._collectData;
    _deltaTemperature = other._deltaTemperature;
    _deltaDuration = other._deltaDuration;
    _pauseState = other._pauseState;
    _excitationIntensity = other._excitationIntensity;

    other._id = -1;
    other._temperature = 0;
    other._holdTime = 0;
    other._orderNumber = 0;
    other._collectData = true;
    other._deltaTemperature = 0;
    other._deltaDuration = 0;
    other._pauseState = false;
    other._excitationIntensity = kDefaultLEDCurrent;
}

Step::~Step()
{

}

Step& Step::operator= (const Step &other)
{
    _id = other.id();
    setName(other.name());
    setTemperature(other.temperature());
    setHoldTime(other.holdTime());
    setOrderNumber(other.orderNumber());
    setCollectData(other.collectData());
    setDeltaTemperature(other.deltaTemperature());
    setDeltaDuration(other.deltaDuration());
    setPauseState(other.pauseState());
    setExcitationIntensity(other.excitationIntensity());

    return *this;
}

Step& Step::operator= (Step &&other)
{
    _id = other._id;
    _name = std::move(other._name);
    _temperature = other._temperature;
    _holdTime = other._holdTime;
    _orderNumber = other._orderNumber;
    _collectData = other._collectData;
    _deltaTemperature = other._deltaTemperature;
    _deltaDuration = other._deltaDuration;
    _pauseState = other._pauseState;
    _excitationIntensity = other._excitationIntensity;

    other._id = -1;
    other._temperature = 0;
    other._holdTime = 0;
    other._orderNumber = 0;
    other._collectData = true;
    other._deltaTemperature = 0;
    other._deltaDuration = 0;
    other._pauseState = false;
    other._excitationIntensity = kDefaultLEDCurrent;

    return *this;
}
