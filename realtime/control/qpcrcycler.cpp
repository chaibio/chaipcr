#include "pcrincludes.h"
#include "qpcrcycler.h"

#include "heatblock.h"

////////////////////////////////////////////////////////////////////////////////
// Class QPCRCycler
QPCRCycler* QPCRCycler::qpcrCycler_ { nullptr };

QPCRCycler::QPCRCycler():
	heatBlock_ {nullptr},
	spiPort0_(kSPI0DevicePath),
	spiPort0DataInSensePin_(kSPI0DataInSensePinNumber, GPIOPin::kInput) {
}

QPCRCycler::~QPCRCycler() {
	delete heatBlock_;
}

QPCRCycler* QPCRCycler::instance() {
	if (!qpcrCycler_)
		qpcrCycler_ = new QPCRCycler();
	
	return QPCRCycler::qpcrCycler_;
}

void QPCRCycler::init() {
	heatBlock_ = new HeatBlock();
}

bool QPCRCycler::loop() {
	heatBlock_->process();

	return true;
}
