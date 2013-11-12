#include "pcrincludes.h"
#include "heatblockzone.h"

#include "qpcrcycler.h"
#include "mcpadc.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlockZoneController
HeatBlockZoneController::HeatBlockZoneController(unsigned int adcCSPinNumber) throw():
	 tempAdc_(nullptr) {
		 
	tempAdc_ = new MCPADC(adcCSPinNumber, QPCRCycler::instance()->spiPort0());
}

HeatBlockZoneController::~HeatBlockZoneController() {
	delete tempAdc_;
}

void HeatBlockZoneController::setTargetTemp(float targetTemp) {
	
}

void HeatBlockZoneController::process() throw() {
	
}
