#include "pcrincludes.h"
#include "boostincludes.h"

#include "step.h"
#include "ramp.h"
#include "stagecomponent.h"

StageComponent::StageComponent()
{
    _step = nullptr;
    _ramp = nullptr;
}

StageComponent::StageComponent(const StageComponent &other)
{
    setStep(*other.step());
    setRamp(*other.ramp());
}

StageComponent::StageComponent(StageComponent &&other)
{
    if (_step)
        delete _step;
    if (_ramp)
        delete _ramp;

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
    setStep(*other.step());
    setRamp(*other.ramp());

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
        *_step = step;
    else
        _step = new Step(step);
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
        *_ramp = ramp;
    else
        _ramp = new Ramp(ramp);
}

void StageComponent::setRamp(Ramp *ramp)
{
    if (_ramp)
        delete _ramp;

    _ramp = ramp;
}
