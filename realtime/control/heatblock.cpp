#include "pcrincludes.h"
#include "utilincludes.h"

#include "heatblockzone.h"
#include "heatblock.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
HeatBlock::HeatBlock() {
    _zones = make_pair(new HeatBlockZoneController(kHeatBlockZone1PWMPath, kHeatBlockZone1PWMPeriod, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin),
                       new HeatBlockZoneController(kHeatBlockZone2PWMPath, kHeatBlockZone2PWMPeriod, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin));
}

HeatBlock::~HeatBlock() {
    delete _zones.second;
    delete _zones.first;
}

void HeatBlock::process() {
    //_zones.first->process();
    //_zones.second->process();
}

void HeatBlock::setTargetTemperature(double targetTemperature) {
    _zones.first->setTargetTemp(targetTemperature);
    _zones.second->setTargetTemp(targetTemperature);
}

double HeatBlock::zone1Temperature() const {
    return _zones.first->currentTemp();
}

double HeatBlock::zone2Temperature() const {
    return _zones.second->currentTemp();
}

shared_ptr<Thermistor> HeatBlock::zone1Thermistor() const {
    return _zones.first->thermistor();
}

shared_ptr<Thermistor> HeatBlock::zone2Thermistor() const {
    return _zones.second->thermistor();
}
