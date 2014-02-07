#ifndef _LEDCONTROLLER_H_
#define _LEDCONTROLLER_H_

// Class LEDController
class LEDController
{
public:
    LEDController(float dutyCyclePercentage);
	virtual ~LEDController();
	
    void setIntensity(double onCurrent);
    void activateLED(unsigned int ledNumber);
    void disableLEDs();
	
private:
    std::atomic<float> _dutyCyclePercentage;
	
    //constants
	const int kMinLEDCurrent = 5; //5mA
	const int kGrayscaleClockPwmPeriodNs = 240;
	const int kGrayscaleClockPwmDutyNs = 120;
	
	//components
    std::shared_ptr<PWMPin> _grayscaleClock;
};

#endif
