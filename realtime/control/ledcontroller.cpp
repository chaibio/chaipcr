#include "pcrincludes.h"
#include "ledcontroller.h"

#include <iostream>

////////////////////////////////////////////////////////////////////////////////
// Class LEDController
LEDController::LEDController(float dutyCyclePercentage):
	dutyCyclePercentage_ {dutyCyclePercentage} {
	
	setIntensity(minLEDCurrent);
}

LEDController::~LEDController() {
	
}
	
void LEDController::initialize() throw() {
	
}

void LEDController::setIntensity(double onCurrent) throw() {
	//verify current
	if (onCurrent < minLEDCurrent)
		throw InvalidArgument("onCurrent too low");
	double avgCurrent = onCurrent * dutyCyclePercentage_ / 100;
	if (avgCurrent > 30 || onCurrent > 100)
		throw InvalidArgument("onCurrent too high");
	
	//calculate 
	double rIref = 1.24 / onCurrent * 31.5; //reference resistance for TLC5940
	int rN = (rIref - 75) * 256 / 5000;
	std::cout << "rN = " << rN << std::endl;
	
	
	
}

void LEDController::activateLED(unsigned int ledNumber) throw() {
	
}

void LEDController::disableLEDs() throw() {
	
}
	
// --- private member functions ------------------------------------------------
