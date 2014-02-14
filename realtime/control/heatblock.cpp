#include "pcrincludes.h"
#include "utilincludes.h"

#include "heatblockzone.h"
#include "heatblock.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
HeatBlock::HeatBlock()
{
    _zones = make_pair(new HeatBlockZoneController(kHeatBlockZone1PWMPath, kHeatBlockZone1PWMPeriod, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin),
                       new HeatBlockZoneController(kHeatBlockZone2PWMPath, kHeatBlockZone2PWMPeriod, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin));
}

HeatBlock::~HeatBlock()
{
    delete _zones.second;
    delete _zones.first;
}

void HeatBlock::process()
{
    _zones.first->process();
    _zones.second->process();
}

void HeatBlock::setTargetTemperature(double targetTemperature)
{
    _zones.first->setTargetTemp(targetTemperature);
    _zones.second->setTargetTemp(targetTemperature);
}

void HeatBlock::setTargetTemperature(double targetTemperatureZone1, double targetTemperatureZone2)
{
    _zones.first->setTargetTemp(targetTemperatureZone1);
    _zones.second->setTargetTemp(targetTemperatureZone2);
}

double HeatBlock::targetTemperature1() const
{
    return _zones.first->targetTemp();
}

double HeatBlock::targetTemperature2() const
{
    return _zones.second->targetTemp();
}
