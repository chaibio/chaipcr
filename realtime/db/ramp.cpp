#include "ramp.h"

Ramp::Ramp(int id)
{
    _id = id;
    _rate = 0;
    _collectData = true;
}

Ramp::Ramp(const Ramp &other)
    :Ramp(other.id())
{
    setRate(other.rate());
    setCollectData(other.collectData());
}

Ramp::Ramp(Ramp &&other)
    :Ramp(other.id())
{
    _rate = other._rate;
    _collectData = other._collectData;

    other._id = -1;
    other._rate = 0;
    other._collectData = true;
}

Ramp::~Ramp()
{

}

Ramp& Ramp::operator= (const Ramp &other)
{
    _id = other.id();
    setRate(other.rate());
    setCollectData(other.collectData());

    return *this;
}

Ramp& Ramp::operator= (Ramp &&other)
{
    _id = other._id;
    _rate = other._rate;
    _collectData = other._collectData;

    other._id = -1;
    other._rate = 0;
    other._collectData = true;

    return *this;
}
