#ifndef _LEDCONTROLLER_H_
#define _LEDCONTROLLER_H_

////////////////////////////////////////////////////////////////////////////////
// Class LEDController
class LEDController {
public:
	LEDController(float dutyCyclePercentage);
	virtual ~LEDController();
	
	void initialize() throw();
	void setIntensity(double onCurrent) throw();
	void activateLED(unsigned int ledNumber) throw();
	void disableLEDs() throw();
	
private:
	float dutyCyclePercentage_;
	
	//constants
	const int minLEDCurrent = 5; //5mA
};

#endif
