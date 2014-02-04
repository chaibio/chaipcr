#ifndef _LEDCONTROLLER_H_
#define _LEDCONTROLLER_H_

#include "pwm.h"

////////////////////////////////////////////////////////////////////////////////
// Class LEDController
class LEDController {
public:
    LEDController(float dutyCyclePercentage);
	virtual ~LEDController();
	
    void setIntensity(double onCurrent);
    void activateLED(unsigned int ledNumber);
    void disableLEDs();
	
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
