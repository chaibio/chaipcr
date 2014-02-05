#ifndef _FAN_H_
#define _FAN_H_

#include "pwm.h"

// Class Fan
class Fan : public IControl
{
public:
    Fan();
	~Fan();
	
	//accessors
    inline int targetRPM() { return _targetRPM.load(); }
    inline void setTargetRPM(int targetRPM) { _targetRPM.store(targetRPM); }
    inline int currentRPM() { return _currentRPM.load(); }
	
    void process();

private:
    boost::atomic<int> _targetRPM;
    boost::atomic<int> _currentRPM;
    boost::shared_ptr<PWMPin> _pwmControl;
//    PWMPin _pwmControl;
};

#endif

