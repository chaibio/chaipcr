#include "pcrincludes.h"
#include "boostincludes.h"
#include "utilincludes.h"

#include "bidirectionalpwmcontroller.h"
#include "heatblock.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
HeatBlock::HeatBlock(HeatBlockZoneController* zone1, HeatBlockZoneController* zone2, double beginStepTemperatureThreshold) {
    _zones = make_pair(zone1, zone2);
    _beginStepTemperatureThreshold = beginStepTemperatureThreshold;
    _stepProcessingState = false;
}

HeatBlock::~HeatBlock() {
    delete _zones.second;
    delete _zones.first;
}

void HeatBlock::process() {
    _zones.first->process();
    _zones.second->process();

    if (_stepProcessingState && _beginStepTemperatureThreshold > maxTemperatureSetpointDelta())
    {
        _stepProcessingState = false;
        stepBegun();
    }
}

void HeatBlock::setEnableMode(bool enableMode) {
    _zones.first->setEnableMode(enableMode);
    _zones.second->setEnableMode(enableMode);

    if (!enableMode)
        _stepProcessingState = false;
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

double HeatBlock::maxTemperatureSetpointDelta() const {
    double zone1Abs = std::abs(_zones.first->targetTemperature() - zone1Temperature());
    double zone2Abs = std::abs(_zones.second->targetTemperature() - zone2Temperature());

    return zone1Abs > zone2Abs ? zone1Abs : zone2Abs;
}
