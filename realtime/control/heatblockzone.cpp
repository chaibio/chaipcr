#include "pcrincludes.h"
#include "heatblockzone.h"

#include "qpcrcycler.h"
#include "mcpadc.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlockZoneController
HeatBlockZoneController::HeatBlockZoneController(unsigned int adcCSPinNumber) throw():
	 tempAdc_(nullptr) {
		 
	auto cycler = QPCRCycler::instance();
	tempAdc_ = new MCPADC(adcCSPinNumber, cycler->spiPort0(), cycler->spiPort0DataInSensePin());
}

HeatBlockZoneController::~HeatBlockZoneController() {
	delete tempAdc_;
}

void HeatBlockZoneController::setTargetTemp(float targetTemp) {
	
}

void HeatBlockZoneController::process() throw() {
	tempAdc_->readTempBlocking();
}
