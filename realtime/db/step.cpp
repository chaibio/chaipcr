#include "step.h"

Step::Step(int id)
{
    _id = id;
    _temperature = 0;
    _holdTime = 0;
    _orderNumber = 0;
    _collectData = true;
}

Step::Step(const Step &other)
    :Step(other.id())
{
    setName(other.name());
    setTemperature(other.temperature());
    setHoldTime(other.holdTime());
    setOrderNumber(other.orderNumber());
    setCollectData(other.collectData());
}

Step::Step(Step &&other)
    :Step(other._id)
{
    _name = std::move(other._name);
    _temperature = other._temperature;
    _holdTime = other._holdTime;
    _orderNumber = other._orderNumber;
    _collectData = other._collectData;

    other._id = -1;
    other._temperature = 0;
    other._holdTime = 0;
    other._orderNumber = 0;
    other._collectData = true;
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

    other._id = -1;
    other._temperature = 0;
    other._holdTime = 0;
    other._orderNumber = 0;
    other._collectData = true;

    return *this;
}
