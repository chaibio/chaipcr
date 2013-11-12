#ifndef _MCPADC_H_
#define _MCPADC_H_

#include "gpiopin.h"
#include "spi.h"

////////////////////////////////////////////////////////////////////////////////
// Class MCPADC
class MCPADC {
public:
	MCPADC(unsigned int csPinNumber, SPIPort& spiPort) throw();
	~MCPADC();
	
private:
	GPIOPin csPin_;
	SPIPort& spiPort;
};

#endif
