#include "pcrincludes.h"

#include "thermistor.h"
#include "heatblockzone.h"

using namespace std;

// Class HeatBlockZoneController
HeatBlockZoneController::HeatBlockZoneController()
{
    _zoneThermistor = make_shared<Thermistor>(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                     kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                     kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient);
}

HeatBlockZoneController::~HeatBlockZoneController()
{
}

void HeatBlockZoneController::process()
{
}
