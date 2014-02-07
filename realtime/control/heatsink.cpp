#include "pcrincludes.h"
#include "utilincludes.h"

#include "fan.h"
#include "thermistor.h"
#include "heatsink.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class HeatSink
HeatSink::HeatSink()
{
    _fan = make_shared<Fan>();
    _thermistor = make_shared<Thermistor>(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                 kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                 kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient);
}

HeatSink::~HeatSink() {
}

void HeatSink::process() {
    _fan->process();
}
