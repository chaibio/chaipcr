#include "pcrincludes.h"
#include "qpcrcycler.h"

////////////////////////////////////////////////////////////////////////////////
// Class QPCRCycler
QPCRCycler::QPCRCycler() {
	
}
// -----------------------------------------------------------------------------
QPCRCycler::~QPCRCycler() {
	delete spiPort0_;
}
// -----------------------------------------------------------------------------
chaistatus_t QPCRCycler::init() {
	spiPort0_ = new SPIPort(kSPI0Device);
	
	return kSuccess;
}
// -----------------------------------------------------------------------------
QPCRCycler* qpcrCycler() {
	if (!qpcrCycler_)
		qpcrCycler_ = new QPCRCycler();
	
	return qpcrCycler_;
}
// -----------------------------------------------------------------------------
chaistatus_t QPCRCycler::loop() {

	return kSuccess;
}