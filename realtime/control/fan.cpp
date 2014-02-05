#include "pcrincludes.h"
#include "fan.h"

////////////////////////////////////////////////////////////////////////////////
// Class Fan
Fan::Fan() :
    targetRPM_ {0},
    currentRPM_ {0},
    pwmControl_(kHeatSinkFanControlPWMPath) {
}

Fan::~Fan() {
}

void Fan::process() {
	//test
    pwmControl_.setPWM(512, 1024, 0);
}
