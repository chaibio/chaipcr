#include "pcrincludes.h"
#include "heatblockzone.h"

#include "qpcrcycler.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlockZoneController
HeatBlockZoneController::HeatBlockZoneController() throw():
	zoneThermistor_(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
		kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
		kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient) {
}

HeatBlockZoneController::~HeatBlockZoneController() {
}

void HeatBlockZoneController::setTargetTemp(double) {
	
}

void HeatBlockZoneController::process() throw() {
}
