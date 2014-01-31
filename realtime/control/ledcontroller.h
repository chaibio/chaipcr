#ifndef _LEDCONTROLLER_H_
#define _LEDCONTROLLER_H_

#include "pwm.h"

////////////////////////////////////////////////////////////////////////////////
// Class LEDController
class LEDController {
public:
	LEDController(float dutyCyclePercentage) throw();
	virtual ~LEDController();
	
	void setIntensity(double onCurrent) throw();
	void activateLED(unsigned int ledNumber) throw();
	void disableLEDs() throw();
	
private:
	float dutyCyclePercentage_;
	
	//constants
	const int kMinLEDCurrent = 5; //5mA
	const int kGrayscaleClockPwmPeriodNs = 240;
	const int kGrayscaleClockPwmDutyNs = 120;
	
	//components
	PWMPin grayscaleClock_;
};

#endif
