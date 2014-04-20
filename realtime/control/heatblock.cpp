#include "pcrincludes.h"
#include "utilincludes.h"

//#include "heatblockzone.h"
#include "temperaturecontroller.h"
#include "heatblock.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
HeatBlock::HeatBlock(HeatBlockZoneController* zone1, HeatBlockZoneController* zone2) {
    _zones = make_pair(zone1, zone2);
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
    _zones.first->setTargetTemperature(targetTemperature);
    _zones.second->setTargetTemperature(targetTemperature);
}

double HeatBlock::zone1Temperature() const {
    return _zones.first->currentTemperature();
}

double HeatBlock::zone2Temperature() const {
    return _zones.second->currentTemperature();
}

/*shared_ptr<Thermistor> HeatBlock::zone1Thermistor() const {
    return _zones.first->thermistor();
}

shared_ptr<Thermistor> HeatBlock::zone2Thermistor() const {
    return _zones.second->thermistor();
}*/
