#include "ramp.h"
#include "constants.h"

Ramp::Ramp(int id)
{
    _id = id;
    _rate = 0;
    _collectData = true;
    _excitationIntensity = kDefaultLEDCurrent;
}

Ramp::Ramp(const Ramp &other)
    :Ramp(other.id())
{
    setRate(other.rate());
    setCollectData(other.collectData());
    setExcitationIntensity(other.excitationIntensity());
}

Ramp::Ramp(Ramp &&other)
    :Ramp(other.id())
{
    _rate = other._rate;
    _collectData = other._collectData;
    _excitationIntensity = other._excitationIntensity;

    other._id = -1;
    other._rate = 0;
    other._collectData = true;
    other._excitationIntensity = kDefaultLEDCurrent;
}

Ramp::~Ramp()
{

}

Ramp& Ramp::operator= (const Ramp &other)
{
    _id = other.id();
    setRate(other.rate());
    setCollectData(other.collectData());
    setExcitationIntensity(other.excitationIntensity());

    return *this;
}

Ramp& Ramp::operator= (Ramp &&other)
{
    _id = other._id;
    _rate = other._rate;
    _collectData = other._collectData;
    _excitationIntensity = other._excitationIntensity;

    other._id = -1;
    other._rate = 0;
    other._collectData = true;
    other._excitationIntensity = kDefaultLEDCurrent;

    return *this;
}
