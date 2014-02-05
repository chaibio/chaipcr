#include "pcrincludes.h"
#include "heatsink.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatSink
HeatSink::HeatSink()
{
    _fan = boost::make_shared<Fan>();
    _thermistor = boost::make_shared<Thermistor>(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                 kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                 kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient);
}

HeatSink::~HeatSink() {
}

void HeatSink::process() {
    _fan->process();
}
