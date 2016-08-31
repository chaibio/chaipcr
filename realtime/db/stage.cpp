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

#include "stagecomponent.h"
#include "stage.h"
#include "step.h"

Stage::Stage(int id)
{
    _id = id;
    _numCycles = 1;
    _cycleIteration = 1;
    _orderNumber = 0;
    _type = None;
    _autoDelta = false;
    _autoDeltaStartCycle = 0;
    _currentComponent = _components.end();
}

Stage::Stage(const Stage &other)
    :Stage(other.id())
{
    setName(other.name());
    setNumCycles(other.numCycles());
    setOrderNumber(other.orderNumber());
    setType(other.type());
    setAutoDelta(other.autoDelta());
    setAutoDeltaStartCycle(other.autoDeltaStartCycle());
    setComponents(other.components());

    _cycleIteration = other.currentCycle();
    _currentComponent = _components.begin() + std::distance(other.components().begin(), std::vector<StageComponent>::const_iterator(other._currentComponent));
}

Stage::Stage(Stage &&other)
    :Stage(other.id())
{
    _name = std::move(other._name);
    _numCycles = other._numCycles;
    _cycleIteration = other._cycleIteration.load();
    _orderNumber = other._orderNumber;
    _type = other._type;
    _autoDelta = other._autoDelta;
    _autoDeltaStartCycle = other._autoDeltaStartCycle;
    _components = std::move(other._components);
    _currentComponent = other._currentComponent;

    other._id = -1;
    other._numCycles = 1;
    other._cycleIteration = 1;
    other._orderNumber = 0;
    other._type = None;
    other._autoDelta = false;
    other._autoDeltaStartCycle = 0;
    other._currentComponent = other._components.end();
}

Stage::~Stage()
{

}

Stage& Stage::operator= (const Stage &other)
{
    _id = other.id();
    setName(other.name());
    setNumCycles(other.numCycles());
    setOrderNumber(other.orderNumber());
    setType(other.type());
    setAutoDelta(other.autoDelta());
    setAutoDeltaStartCycle(other.autoDeltaStartCycle());
    setComponents(other.components());

    _cycleIteration = other.currentCycle();
    _currentComponent = _components.begin() + std::distance(other.components().begin(), std::vector<StageComponent>::const_iterator(other._currentComponent));

    return *this;
}

Stage& Stage::operator= (Stage &&other)
{
    _id = other._id;
    _name = std::move(other._name);
    _numCycles = other._numCycles;
    _cycleIteration = other._cycleIteration.load();
    _orderNumber = other._orderNumber;
    _type = other._type;
    _autoDelta = other._autoDelta;
    _autoDeltaStartCycle = other._autoDeltaStartCycle;
    _components = std::move(other._components);
    _currentComponent = other._currentComponent;

    other._id = -1;
    other._numCycles = 1;
    other._cycleIteration = 1;
    other._orderNumber = 0;
    other._type = None;
    other._autoDelta = false;
    other._autoDeltaStartCycle = 0;
    other._currentComponent = other._components.end();

    return *this;
}

void Stage::setComponents(const std::vector<StageComponent> &components)
{
    _components = components;

    resetCurrentStep();
}

void Stage::setComponents(std::vector<StageComponent> &&components)
{
    _components = std::move(components);

    resetCurrentStep();
}

void Stage::appendComponent(const StageComponent &component)
{
    _components.push_back(component);
}

void Stage::appendComponent(StageComponent &&component)
{
    _components.push_back(std::move(component));
}

void Stage::resetCurrentStep()
{
    _currentComponent = _components.begin();

    _cycleIteration = 1;
}

Step* Stage::currentStep() const
{
    if (_currentComponent != _components.end())
        return _currentComponent->step();
    else
        return nullptr;
}

Ramp* Stage::currentRamp() const
{
    if (_currentComponent != _components.end())
        return _currentComponent->ramp();
    else
        return nullptr;
}

Step* Stage::advanceNextStep()
{
    if (_currentComponent == _components.end())
        return nullptr;

    ++_currentComponent;

    Step *step = currentStep();

    if (!step)
    {
        ++_cycleIteration;

        if (_cycleIteration <= _numCycles)
        {
            _currentComponent = _components.begin();

            step = _currentComponent->step();
        }
    }

    return step;
}

bool Stage::hasNextStep() const
{
    return (_currentComponent != _components.end() && (_currentComponent + 1) != _components.end()) || (_cycleIteration + 1) <= _numCycles;
}

double Stage::currentStepTemperature(double min, double max) const
{
    Step *step = currentStep();

    if (!step)
        return 0;

    double temperature = step->temperature();

    if (autoDelta() && currentCycle() > autoDeltaStartCycle())
    {
        temperature += step->deltaTemperature() * (currentCycle() - autoDeltaStartCycle());

        if (temperature < min)
            temperature = min;
        else if (temperature > max)
            temperature = max;
    }

    return temperature;
}

std::time_t Stage::currentStepHoldTime() const
{
    Step *step = currentStep();

    if (!step)
        return 0;

    std::time_t holdTime = step->holdTime();

    if (autoDelta() && currentCycle() > autoDeltaStartCycle())
    {
        holdTime += step->deltaDuration() * (currentCycle() - autoDeltaStartCycle());

        if (holdTime < 0)
            holdTime = 0;
    }

    return holdTime;
}
