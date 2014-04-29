#include "pcrincludes.h"
#include "pocoincludes.h"

#include "stagecomponent.h"
#include "stage.h"

Stage::Stage()
{
    _numCycles = 1;
    _orderNumber = 0;
    _type = None;
    _currentComponent = _components.end();
}

Stage::Stage(const Stage &other)
    :Stage()
{
    setName(other.name());
    setNumCycles(other.numCycles());
    setOrderNumber(other.orderNumber());
    setType(other.type());
    setComponents(other.components());
}

Stage::Stage(Stage &&other)
    :Stage()
{
    _name = std::move(other._name);
    _numCycles = other._numCycles;
    _orderNumber = other._orderNumber;
    _type = other._type;
    _components = std::move(other._components);
    _currentComponent = other._currentComponent;

    other._numCycles = 0;
    other._orderNumber = 0;
    other._type = None;
    other._currentComponent = other._components.end();
}

Stage::~Stage()
{

}

Stage& Stage::operator= (const Stage &other)
{
    setName(other.name());
    setNumCycles(other.numCycles());
    setOrderNumber(other.orderNumber());
    setType(other.type());
    setComponents(other.components());

    return *this;
}

Stage& Stage::operator= (Stage &&other)
{
    _name = std::move(other._name);
    _numCycles = other._numCycles;
    _orderNumber = other._orderNumber;
    _type = other._type;
    _components = std::move(other._components);
    _currentComponent = other._currentComponent;

    other._numCycles = 0;
    other._orderNumber = 0;
    other._type = None;
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
}

Step* Stage::currentStep() const
{
    if (_currentComponent != _components.end())
        return _currentComponent->step();
    else
        return nullptr;
}

Step* Stage::nextStep()
{
    if (_currentComponent == _components.end())
        return nullptr;

    ++_currentComponent;

    return currentStep();
}
