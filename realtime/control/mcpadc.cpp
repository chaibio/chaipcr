#include "pcrincludes.h"
#include "mcpadc.h"

#include "pins.h"
#include <iostream>

////////////////////////////////////////////////////////////////////////////////
// Class MCPADC
MCPADC::MCPADC(unsigned int csPinNumber, SPIPort& spiPort, GPIO& spiDataInSensePin) throw():
	 csPin_(csPinNumber, GPIO::kOutput),
	 spiPort_ (spiPort),
	 spiDataInSensePin_ (spiDataInSensePin) {}

MCPADC::~MCPADC() {
}

float MCPADC::readTempBlocking() {
	std::cout << "Reading block temp" << std::endl;
	//set CS low to initiate conversion
	csPin_.setValue(GPIO::kHigh);
	csPin_.setValue(GPIO::kLow);
	
	//wait for conversion to complete
	auto value = spiDataInSensePin_.value();
	while (value != GPIO::kLow) {
		std::cout << "Read pin value " << value << std::endl;
	}
	
	//read conversion value via SPI, convert to little endian
	uint32_t conversion,data=0;
	spiPort_.readBytes((char*)&conversion, (char*)&data,3, 1000000);
	conversion = (conversion & 0x00FF0000) >> 16 | (conversion & 0x0000FF00) | (conversion & 0x000000FF) << 16;
	
	std::cout << "Read ADC value " << conversion << std::endl;
}
