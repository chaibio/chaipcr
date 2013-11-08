#include "pcrincludes.h"
#include "qpcrcycler.h"

#include "spi.h"
#include "heatblock.h"

////////////////////////////////////////////////////////////////////////////////
// Class QPCRCycler
QPCRCycler* QPCRCycler::qpcrCycler_ = 0;

QPCRCycler::QPCRCycler():
	heatBlock_(NULL) {
	
	spiPort0_ = new SPIPort(kSPI0DevicePath);
	heatBlock_ = new HeatBlock();
}

QPCRCycler::~QPCRCycler() {
	delete heatBlock_;
	delete spiPort0_;
}

QPCRCycler* QPCRCycler::instance() {
	if (!qpcrCycler_)
		qpcrCycler_ = new QPCRCycler();
	
	return QPCRCycler::qpcrCycler_;
}

bool QPCRCycler::loop() {
	heatBlock_->process();
	
	return true;
}
