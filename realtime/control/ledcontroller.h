#ifndef _LEDCONTROLLER_H_
#define _LEDCONTROLLER_H_

class PWMPin;

// Class LEDController
class LEDController
{
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
};

#endif
