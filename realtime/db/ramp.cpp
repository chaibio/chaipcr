#include "pcrincludes.h"
#include "pocoincludes.h"

#include "ramp.h"

Ramp::Ramp()
{
    _rate = 0;
}

Ramp::Ramp(const Ramp &other)
    :Ramp()
{
    setRate(other.rate());
}

Ramp::Ramp(Ramp &&other)
    :Ramp()
{
    _rate = other._rate;
    other._rate = 0;
}

Ramp::~Ramp()
{

}

Ramp& Ramp::operator= (const Ramp &other)
{
    setRate(other.rate());

    return *this;
}

Ramp& Ramp::operator= (Ramp &&other)
{
    _rate = other._rate;
    other._rate = 0;

    return *this;
}
