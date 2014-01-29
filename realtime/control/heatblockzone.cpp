#include "pcrincludes.h"
#include "heatblockzone.h"

#include "qpcrcycler.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlockZoneController
HeatBlockZoneController::HeatBlockZoneController(unsigned int adcCSPinNumber) throw() {
		 
	auto cycler = QPCRCycler::instance();
}

HeatBlockZoneController::~HeatBlockZoneController() {
}

void HeatBlockZoneController::setTargetTemp(float targetTemp) {
	
}

void HeatBlockZoneController::process() throw() {
}
