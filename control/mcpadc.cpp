#include "pcrincludes.h"
#include "mcpadc.h"

#include "pins.h"
#include "gpiopin.h"

////////////////////////////////////////////////////////////////////////////////
// Class MCPADC
MCPADC::MCPADC(unsigned int csPinNumber) throw():
	 csPin_(NULL) {
	
	csPin_ = new GPIOPin(csPinNumber, GPIOPin::kOutput);
}

MCPADC::~MCPADC() {
	delete csPin_;
}
