#ifndef _MCPADC_H_
#define _MCPADC_H_

#include "gpio.h"
#include "spi.h"

////////////////////////////////////////////////////////////////////////////////
// Class MCPADC
class MCPADC {
public:
	MCPADC(unsigned int csPinNumber, SPIPort& spiPort, GPIO& spiDataInSensePin) throw();
	~MCPADC();
	
	float readTempBlocking();
	
private:
	GPIO csPin_;
	GPIO& spiDataInSensePin_;
	SPIPort& spiPort_;
};

#endif
