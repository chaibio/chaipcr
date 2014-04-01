#ifndef _LEDCONTROLLER_H_
#define _LEDCONTROLLER_H_

// Class LEDController
class LEDController
{
public:
    LEDController(std::shared_ptr<SPIPort> spiPort, float dutyCyclePercentage);
	virtual ~LEDController();
	
    void setIntensity(double onCurrentMilliamps);
    double intensity() const { return _intensity; }
    void activateLED(unsigned int ledNumber);
    void disableLEDs();
	
private:
    std::atomic<float> _dutyCyclePercentage;
    double _intensity;
	
    //constants
	const int kMinLEDCurrent = 5; //5mA
	const int kGrayscaleClockPwmPeriodNs = 240;
	const int kGrayscaleClockPwmDutyNs = 120;
	
	//components
    std::shared_ptr<PWMPin> _grayscaleClock;
    std::shared_ptr<SPIPort> _spiPort;
    GPIO _potCSPin;
};

#endif
