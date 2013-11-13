#ifndef _MCPADC_H_
#define _MCPADC_H_

#include "gpiopin.h"
#include "spi.h"

////////////////////////////////////////////////////////////////////////////////
// Class MCPADC
class MCPADC {
public:
	MCPADC(unsigned int csPinNumber, SPIPort& spiPort, GPIOPin& spiDataInSensePin) throw();
	~MCPADC();
	
	float readTempBlocking();
	
private:
	GPIOPin csPin_;
	GPIOPin& spiDataInSensePin_;
	SPIPort& spiPort_;
};

#endif
