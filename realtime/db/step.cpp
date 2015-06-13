#include "step.h"

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

    other._id = -1;
    other._temperature = 0;
    other._holdTime = 0;
    other._orderNumber = 0;
    other._collectData = true;
    other._deltaTemperature = 0;
    other._deltaDuration = 0;
    other._pauseState = false;
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

    other._id = -1;
    other._temperature = 0;
    other._holdTime = 0;
    other._orderNumber = 0;
    other._collectData = true;
    other._deltaTemperature = 0;
    other._deltaDuration = 0;
    other._pauseState = false;

    return *this;
}
