#ifndef _FAN_H_
#define _FAN_H_

#include "icontrol.h"

// Class Fan
class Fan : public IControl
{
public:
    Fan(const std::string &pwmPath);
	~Fan();

    void process();
	
	//accessors
    inline int targetRPM() const { return _targetRPM.load(); }
    inline void setTargetRPM(int targetRPM) { _targetRPM.store(targetRPM); }

    inline int currentRPM() const { return _currentRPM.load(); }

    inline unsigned long pwmDutyCycle() const { return _pwmDutyCycle.load(); }
    inline void setPWMDutyCycle(unsigned long dutyCycle) { dutyCycle <= kFanPWMPeriodNs ? _pwmDutyCycle.store(dutyCycle) : _pwmDutyCycle.store(kFanPWMPeriodNs); }

private:
    std::atomic<int> _targetRPM;
    std::atomic<int> _currentRPM;

    PWMPin _pwmControl;
    std::atomic<unsigned long> _pwmDutyCycle;
};

#endif

