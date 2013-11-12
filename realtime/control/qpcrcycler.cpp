#include "pcrincludes.h"
#include "qpcrcycler.h"

#include "spi.h"
#include "heatblock.h"

////////////////////////////////////////////////////////////////////////////////
// Class QPCRCycler
QPCRCycler* QPCRCycler::qpcrCycler_ { nullptr };

QPCRCycler::QPCRCycler():
	heatBlock_ {nullptr},
	spiPort0_(kSPI0DevicePath) {

	heatBlock_ = new HeatBlock();
}

QPCRCycler::~QPCRCycler() {git stat
	delete heatBlock_;
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
