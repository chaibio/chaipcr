#include "pcrincludes.h"
#include "utilincludes.h"

#include "fan.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Fan
Fan::Fan()
    :_pwmControl(PWMPin(kHeatSinkFanControlPWMPath))
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
	//test
    _pwmControl.setPWM(pwmDutyCycle(), kFanPWMPeriodNs, 0);
}
