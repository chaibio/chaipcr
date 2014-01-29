#include "pcrincludes.h"
#include "qpcrcycler.h"

#include "adccontroller.h"
#include "heatblock.h"
#include "heatsink.h"
#include "optics.h"

////////////////////////////////////////////////////////////////////////////////
// Class QPCRCycler
QPCRCycler* QPCRCycler::qpcrCycler_ { nullptr };

QPCRCycler::QPCRCycler():
	heatBlock_ {nullptr},
	heatSink_ {nullptr},
	optics_ {nullptr},
	spiPort0_(kSPI0DevicePath),
	spiPort0DataInSensePin_(kSPI0DataInSensePinNumber, GPIO::kInput) {
		
}

QPCRCycler::~QPCRCycler() {
	delete optics_;
	delete heatBlock_;
	delete heatSink_;
	delete adcController_;
}

QPCRCycler* QPCRCycler::instance() {
	if (!qpcrCycler_)
		qpcrCycler_ = new QPCRCycler();
	
	return QPCRCycler::qpcrCycler_;
}

void QPCRCycler::init() {
	adcController_ = new ADCController(kLTC2444CSPinNumber, spiPort0_, kSPI0DataInSensePinNumber);
	heatBlock_ = new HeatBlock();
	heatSink_ = new HeatSink();
	optics_ = new Optics();
}

void QPCRCycler::run() {
	while (true) {
		adcController_->process();
		heatBlock_->process();
		heatSink_->process();
		optics_->process();
	}
}
