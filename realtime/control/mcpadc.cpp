#include "pcrincludes.h"
#include "mcpadc.h"

#include "pins.h"

////////////////////////////////////////////////////////////////////////////////
// Class MCPADC
MCPADC::MCPADC(unsigned int csPinNumber, SPIPort& spiPort) throw():
	 csPin_(csPinNumber, GPIOPin::kOutput),
	 spiPort(spiPort) {}

MCPADC::~MCPADC() {
}
