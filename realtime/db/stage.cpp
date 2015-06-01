#include "stagecomponent.h"
#include "stage.h"

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
    setNumCycles(other.numCycles(), other.currentCycle());
    setOrderNumber(other.orderNumber());
    setType(other.type());
    setAutoDelta(other.autoDelta());
    setAutoDeltaStartCycle(other.autoDeltaStartCycle());
    setComponents(other.components());
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
    setNumCycles(other.numCycles(), other.currentCycle());
    setOrderNumber(other.orderNumber());
    setType(other.type());
    setAutoDelta(other.autoDelta());
    setAutoDeltaStartCycle(other.autoDeltaStartCycle());
    setComponents(other.components());

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

void Stage::setNumCycles(unsigned numCycles, unsigned currentCycle)
{
     _numCycles = numCycles;
     _cycleIteration = currentCycle;
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
