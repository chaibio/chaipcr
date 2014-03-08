#include "pcrincludes.h"
#include "pocoincludes.h"

#include "step.h"

Step::Step()
{
    _temperature = 0;
    _holdTime = 0;
    _orderNumber = 0;
}

Step::Step(const Step &other)
{
    setName(other.name());
    setTemperature(other.temperature());
    setHoldTime(other.holdTime());
    setOrderNumber(other.orderNumber());
}

Step::Step(Step &&other)
{
    _name = std::move(other._name);
    _temperature = other._temperature;
    _holdTime = other._holdTime;
    _orderNumber = other._orderNumber;

    other._temperature = 0;
    other._holdTime = 0;
    other._orderNumber = 0;
}

Step::~Step()
{

}

Step& Step::operator= (const Step &other)
{
    setName(other.name());
    setTemperature(other.temperature());
    setHoldTime(other.holdTime());
    setOrderNumber(other.orderNumber());

    return *this;
}

Step& Step::operator= (Step &&other)
{
    _name = std::move(other._name);
    _temperature = other._temperature;
    _holdTime = other._holdTime;
    _orderNumber = other._orderNumber;

    other._temperature = 0;
    other._holdTime = 0;
    other._orderNumber = 0;

    return *this;
}
