#ifndef _LEDCONTROLLER_H_
#define _LEDCONTROLLER_H_

#include "pwm.h"
#include "gpio.h"

#include <memory>

class SPIPort;

// Class LEDController
class LEDController {
public:
    LEDController(std::shared_ptr<SPIPort> spiPort, unsigned int potCSPin,
                  unsigned int ledXLATPin, const std::string &ledBlankPWMPath, float dutyCyclePercentage);
	virtual ~LEDController();
	
    void setIntensity(double onCurrentMilliamps);
    inline double intensity() const { return _intensity; }
    void activateLED(unsigned int ledNumber);
    inline void disableLEDs() { disableLEDs(true); }

private:
    void disableLEDs(bool clearLastLed);

    void sendLEDGrayscaleValues(const uint8_t (&values)[24]);
	
private:
    std::atomic<float> _dutyCyclePercentage;
    double _intensity;

    unsigned _lastLedNumber;
	
	//components
    std::shared_ptr<SPIPort> _spiPort;
    GPIO _potCSPin;
    GPIO _ledXLATPin;
    GPIO _ledGSPin;
    PWMPin _ledBlankPWM;
};

#endif
