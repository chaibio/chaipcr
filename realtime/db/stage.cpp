#include "pcrincludes.h"
#include "pocoincludes.h"

#include "stagecomponent.h"
#include "stage.h"

Stage::Stage()
{
    _numCycles = 1;
    _orderNumber = 0;
    _type = None;
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

    other._numCycles = 0;
    other._orderNumber = 0;
    other._type = None;
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

    other._numCycles = 0;
    other._orderNumber = 0;
    other._type = None;

    return *this;
}

void Stage::setComponents(const std::vector<StageComponent> &components)
{
    _components = components;
}

void Stage::setComponents(std::vector<StageComponent> &&components)
{
    _components = components;
}

void Stage::appendComponent(const StageComponent &component)
{
    _components.push_back(component);
}

void Stage::appendComponent(StageComponent &&component)
{
    _components.push_back(component);
}
