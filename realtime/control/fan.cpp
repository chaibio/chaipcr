#include "pcrincludes.h"

#include "fan.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Fan
Fan::Fan()
    :PWMControl(kHeatSinkFanControlPWMPath, kFanPWMPeriodNs)
{
    _currentRPM.store(0);

    setTargetRPM(0);
    setPWMDutyCycle(kFanPWMPeriodNs * 0.5);
}

Fan::~Fan()
{
}

void Fan::process()
{

}
