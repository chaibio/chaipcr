#ifndef _LEDCONTROLLER_H_
#define _LEDCONTROLLER_H_

#include "pwm.h"

// Class LEDController
class LEDController {
public:
    LEDController(SPIPort spiPort, float dutyCyclePercentage);
	virtual ~LEDController();
	
    void setIntensity(double onCurrentMilliamps);
    double intensity() const { return _intensity; }
    void activateLED(unsigned int ledNumber);
    void disableLEDs();
	
private:
    std::atomic<float> _dutyCyclePercentage;
    double _intensity;
	
	//components
    std::shared_ptr<PWMPin> _grayscaleClock;
    SPIPort _spiPort;
    GPIO _potCSPin;
    GPIO _ledXLATPin;
    PWMPin _ledBlankPWM;
};

#endif
