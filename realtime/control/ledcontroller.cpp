#include "pcrincludes.h"
#include "ledcontroller.h"

#include <iostream>

////////////////////////////////////////////////////////////////////////////////
// Class LEDController
LEDController::LEDController(float dutyCyclePercentage)
{
    _dutyCyclePercentage.store(dutyCyclePercentage);
    _grayscaleClock = boost::make_shared<PWMPin>(kLEDGrayscaleClockPWMPath);
	setIntensity(kMinLEDCurrent);
    _grayscaleClock->setPWM(kGrayscaleClockPwmDutyNs, kGrayscaleClockPwmPeriodNs, 0);
}

LEDController::~LEDController()
{
	
}
	
void LEDController::setIntensity(double onCurrent)
{
	//verify current
	if (onCurrent < kMinLEDCurrent)
		throw InvalidArgument("onCurrent too low");
    double avgCurrent = onCurrent * _dutyCyclePercentage / 100;
	if (avgCurrent > 30 || onCurrent > 100)
		throw InvalidArgument("onCurrent too high");
	
	//calculate 
	double rIref = 1.24 / onCurrent * 31.5; //reference resistance for TLC5940
	int rN = (rIref - 75) * 256 / 5000;
	std::cout << "rN = " << rN << std::endl;	
}

void LEDController::activateLED(unsigned int)
{
	
}

void LEDController::disableLEDs()
{
	
}
	
// --- private member functions ------------------------------------------------
