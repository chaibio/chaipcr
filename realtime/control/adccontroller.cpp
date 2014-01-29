#include "pcrincludes.h"
#include "adccontroller.h"

#include <iostream>

////////////////////////////////////////////////////////////////////////////////
// Class ADCController
ADCController::ADCController(unsigned int csPinNumber, SPIPort& spiPort, unsigned int busyPinNumber) throw():
	ltc2444_(csPinNumber, spiPort, busyPinNumber) {
}

ADCController::~ADCController() {
}

void ADCController::process() throw() {
	//read channel 1 as test
	ltc2444_.setup(0x6, false);
	ltc2444_.readADC(1, true);
	while (ltc2444_.busy()) {
		std::cout << "Waiting - busy" << std::endl;
	}
	uint32_t value = ltc2444_.readADC(1, true);
	std::cout << "Read value " << value << std::endl;
}
