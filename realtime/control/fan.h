#ifndef _FAN_H_
#define _FAN_H_

#include "pwm.h"

////////////////////////////////////////////////////////////////////////////////
// Class Fan
class Fan {
public:
    Fan();
	~Fan();
	
	//accessors
	inline int targetRPM() { return targetRPM_; }
	inline void setTargetRPM(int targetRPM) { targetRPM_ = targetRPM; }
	inline int currentRPM() { return currentRPM_; }
	
    void process();
	
private:
	int targetRPM_;
	int currentRPM_;
	PWMPin pwmControl_;
};

#endif
