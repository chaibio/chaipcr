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
#include "ramp.h"
#include "stagecomponent.h"

StageComponent::StageComponent()
{
    _step = nullptr;
    _ramp = nullptr;
}

StageComponent::StageComponent(const StageComponent &other)
    :StageComponent()
{
    if (other.step())
        setStep(*other.step());

    if (other.ramp())
        setRamp(*other.ramp());
}

StageComponent::StageComponent(StageComponent &&other)
    :StageComponent()
{
    _step = other._step;
    _ramp = other._ramp;

    other._step = nullptr;
    other._ramp = nullptr;
}

StageComponent::~StageComponent()
{
    delete _step;
    delete _ramp;
}

StageComponent& StageComponent::operator= (const StageComponent &other)
{
    if (other.step())
        setStep(*other.step());
    else
        setStep(nullptr);

    if (other.ramp())
        setRamp(*other.ramp());
    else
        setStep(nullptr);

    return *this;
}

StageComponent& StageComponent::operator= (StageComponent &&other)
{
    if (_step)
        delete _step;
    if (_ramp)
        delete _ramp;

    _step = other._step;
    _ramp = other._ramp;

    other._step = nullptr;
    other._ramp = nullptr;

    return *this;
}

void StageComponent::setStep(const Step &step)
{
    if (_step)
        *_step = step;
    else
        _step = new Step(step);
}

void StageComponent::setStep(Step &&step)
{
    if (_step)
        *_step = std::move(step);
    else
        _step = new Step(std::move(step));
}

void StageComponent::setStep(Step *step)
{
    if (_step)
        delete _step;

    _step = step;
}

void StageComponent::setRamp(const Ramp &ramp)
{
    if (_ramp)
        *_ramp = ramp;
    else
        _ramp = new Ramp(ramp);
}

void StageComponent::setRamp(Ramp &&ramp)
{
    if (_ramp)
        *_ramp = std::move(ramp);
    else
        _ramp = new Ramp(std::move(ramp));
}

void StageComponent::setRamp(Ramp *ramp)
{
    if (_ramp)
        delete _ramp;

    _ramp = ramp;
}
