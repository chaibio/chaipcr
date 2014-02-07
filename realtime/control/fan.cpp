#include "pcrincludes.h"
#include "utilincludes.h"

#include "fan.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Fan
Fan::Fan()
{
    _targetRPM.store(0);
    _currentRPM.store(0);
    _pwmControl = make_shared<PWMPin>(kHeatSinkFanControlPWMPath);
}

Fan::~Fan()
{
}

void Fan::process()
{
	//test
    _pwmControl->setPWM(512, 1024, 0);
}
