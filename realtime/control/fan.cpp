#include "pcrincludes.h"
#include "fan.h"

////////////////////////////////////////////////////////////////////////////////
// Class Fan
Fan::Fan() throw():
	targetRPM_ {0},
	currentRPM_ {0},
	pwmControl_(kHeatSinkFanControlPWMPath) {
}

Fan::~Fan() {
}

void Fan::process() throw() {
	//test
	pwmControl_.setPWM(512, 1024, 0);
}
