#include "pcrincludes.h"
#include "heatsink.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatSink
HeatSink::HeatSink() throw():
	thermistor_(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
		kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
		kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient) {
}

HeatSink::~HeatSink() {
}

void HeatSink::process() throw() {
	fan_.process();
}
