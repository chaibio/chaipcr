#include "pcrincludes.h"
#include "adccontroller.h"

#include <iostream>

////////////////////////////////////////////////////////////////////////////////
// Class ADCController
ADCController::ADCController(unsigned int csPinNumber, SPIPort& spiPort, unsigned int busyPinNumber)
{
    _ltc2444 = boost::make_shared<LTC2444>(csPinNumber, spiPort, busyPinNumber);
}

ADCController::~ADCController()
{
}

void ADCController::process()
{
	//read channel 1 as test
    _ltc2444->setup(0x6, false);
    _ltc2444->readADC(1, true);
    while (_ltc2444->busy()) {
		std::cout << "Waiting - busy" << std::endl;
	}
    uint32_t value = _ltc2444->readADC(1, true);
	std::cout << "Read value " << value << std::endl;
}
