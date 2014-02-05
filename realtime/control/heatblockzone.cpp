#include "pcrincludes.h"
#include "heatblockzone.h"


// Class HeatBlockZoneController
HeatBlockZoneController::HeatBlockZoneController()
{
    _zoneThermistor = boost::make_shared<Thermistor>(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                     kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                     kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient);
}

HeatBlockZoneController::~HeatBlockZoneController()
{
}

void HeatBlockZoneController::process()
{
}
