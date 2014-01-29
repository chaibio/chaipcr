#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "ltc2444.h"

////////////////////////////////////////////////////////////////////////////////
// Class ADCController
class ADCController {
public:
	ADCController(unsigned int csPinNumber, SPIPort& spiPort, unsigned int busyPinNumber) throw();
	~ADCController();
	
	void process() throw();
	
private:
	LTC2444 ltc2444_;
};

#endif
