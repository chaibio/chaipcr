#include "pcrincludes.h"
#include "heatblockzone.h"

#include "mcpadc.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlockZoneController
HeatBlockZoneController::HeatBlockZoneController(unsigned int adcCSPinNumber) throw():
	 tempAdc_(NULL) {
		 
	tempAdc_ = new MCPADC(adcCSPinNumber);
}

HeatBlockZoneController::~HeatBlockZoneController() {
	delete tempAdc_;
}

void HeatBlockZoneController::setTargetTemp(float targetTemp) {
	
}

chaistatus_t HeatBlockZoneController::process() {
	
}
