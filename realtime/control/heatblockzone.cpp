#include "pcrincludes.h"
#include "heatblockzone.h"

#include "qpcrcycler.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlockZoneController
HeatBlockZoneController::HeatBlockZoneController() throw():
	zoneThermistor_(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
		kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
		kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient) {
		 
	auto cycler = QPCRCycler::instance();
}

HeatBlockZoneController::~HeatBlockZoneController() {
}

void HeatBlockZoneController::setTargetTemp(double targetTemp) {
	
}

void HeatBlockZoneController::process() throw() {
}
