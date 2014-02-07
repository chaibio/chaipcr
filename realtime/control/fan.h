#ifndef _FAN_H_
#define _FAN_H_

#include "icontrol.h"

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
    std::atomic<int> _targetRPM;
    std::atomic<int> _currentRPM;
    std::shared_ptr<PWMPin> _pwmControl;
//    PWMPin _pwmControl;
};

#endif

