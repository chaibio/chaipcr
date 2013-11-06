#include "pcrincludes.h"
#include "spi.h"

////////////////////////////////////////////////////////////////////////////////
// Class CSPIPort
CSPIPort::CSPIPort(const char* SPIDevice):
  iSPIDevice(SPIDevice) {
	
}
// -----------------------------------------------------------------------------
CSPIPort::~CSPIPort() {
	
}
// -----------------------------------------------------------------------------
PCRSTATUS CSPIPort::init() {
	return SUCCESS;
}