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

#include "stage.h"
#include "protocol.h"

Protocol::Protocol()
{
    _lidTemperature = 0;
    _currentStage = _stages.end();
}

Protocol::Protocol(const Protocol &other)
    :Protocol()
{
    setLidTemperature(other.lidTemperature());

    _stages = other.stages();
    _currentStage = _stages.begin() + std::distance(other.stages().begin(), std::vector<Stage>::const_iterator(other._currentStage));
}

Protocol::Protocol(Protocol &&other)
    :Protocol()
{
    _lidTemperature = other._lidTemperature;
    _stages = std::move(other._stages);
    _currentStage = other._currentStage;

    other._lidTemperature = 0;
    other._currentStage = other._stages.end();
}

Protocol::~Protocol()
{

}

Protocol& Protocol::operator= (const Protocol &other)
{
    setLidTemperature(other.lidTemperature());

    _stages = other.stages();
    _currentStage = _stages.begin() + std::distance(other.stages().begin(), std::vector<Stage>::const_iterator(other._currentStage));

    return *this;
}

Protocol& Protocol::operator= (Protocol &&other)
{
    _lidTemperature = other._lidTemperature;
    _stages = std::move(other._stages);
    _currentStage = other._currentStage;

    other._lidTemperature = 0;
    other._currentStage = other._stages.end();

    return *this;
}

void Protocol::setStages(const std::vector<Stage> &stages)
{
    _stages = stages;

    resetCurrentStep();
}

void Protocol::setStages(std::vector<Stage> &&stages)
{
    _stages = std::move(stages);

    resetCurrentStep();
}

void Protocol::appendStage(const Stage &stage)
{
    _stages.push_back(stage);
}

void Protocol::appendStage(Stage &&stage)
{
    _stages.push_back(std::move(stage));
}

void Protocol::resetCurrentStep()
{
    for (Stage &stage: _stages)
        stage.resetCurrentStep();

    _currentStage = _stages.begin();
}

Step* Protocol::currentStep() const
{
    if (_currentStage != _stages.end())
        return _currentStage->currentStep();
    else
        return nullptr;
}

Ramp* Protocol::currentRamp() const
{
    if (_currentStage != _stages.end())
        return _currentStage->currentRamp();
    else
        return nullptr;
}

Step* Protocol::advanceNextStep()
{
    if (_currentStage == _stages.end())
        return nullptr;

    Step *step = _currentStage->advanceNextStep();

    if (!step)
    {
        ++_currentStage;
        step = currentStep();
    }

    return step;
}

bool Protocol::hasNextStep() const
{
    return _currentStage != _stages.end() && (_currentStage->hasNextStep() || (_currentStage + 1 ) != _stages.end());
}
