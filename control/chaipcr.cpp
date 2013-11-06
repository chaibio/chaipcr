#include "pcrincludes.h"
#include "chaipcr.h"

////////////////////////////////////////////////////////////////////////////////
// Class CChaiPCR
CChaiPCR::CChaiPCR() {
	
}
// -----------------------------------------------------------------------------
CChaiPCR::~CChaiPCR() {
	delete iSPIPort0;
	
}
// -----------------------------------------------------------------------------
PCRSTATUS CChaiPCR::init() {
	iSPIPort0 = new CSPIPort(SPI0_DEVICE);
}