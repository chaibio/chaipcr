#ifndef _FAN_H_
#define _FAN_H_

#include "icontrol.h"
#include "pwm.h"

#include <atomic>

// Class Fan
class Fan : public IControl, public PWMControl
{
public:
    Fan();
	~Fan();

    void process();
	
	//accessors
    inline int targetRPM() const { return _targetRPM; }
    inline void setTargetRPM(int targetRPM) { _targetRPM = targetRPM; }

    inline int currentRPM() const { return _currentRPM; }

private:
    std::atomic<int> _targetRPM;
    std::atomic<int> _currentRPM;
};

#endif

