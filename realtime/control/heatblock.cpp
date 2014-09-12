#include <boost/date_time.hpp>

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

    if (_stepProcessingState)
    {
        if (ramp.isEmpty()) {
            if (_beginStepTemperatureThreshold > maxTemperatureSetpointDelta()) {
                _stepProcessingState = false;
                stepBegun();
            }
        }
        else {
            double temp = ramp.computeTemperature(_zones.first->targetTemperature());

            _zones.first->setTargetTemperature(temp);
            _zones.second->setTargetTemperature(temp);
        }
    }
}

void HeatBlock::setEnableMode(bool enableMode) {
    _zones.first->setEnableMode(enableMode);
    _zones.second->setEnableMode(enableMode);

    if (!enableMode)
        _stepProcessingState = false;
}

void HeatBlock::setTargetTemperature(double targetTemperature, double rampRate) {
    ramp.clear();

    if (rampRate == 0) {
        _zones.first->setTargetTemperature(targetTemperature);
        _zones.second->setTargetTemperature(targetTemperature);
    }
    else
        ramp.set(targetTemperature, rampRate);
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

double HeatBlock::zone1DriveValue() const {
    return (double)_zones.first->pwmDutyCycle() / _zones.first->pwmPeriod() * (_zones.first->outputDirection() == TemperatureController::EHeat ? 1 : -1);
}

double HeatBlock::zone2DriveValue() const {
    return (double)_zones.second->pwmDutyCycle() / _zones.second->pwmPeriod() * (_zones.second->outputDirection() == TemperatureController::EHeat ? 1 : -1);
}

// Class HeatBlock::Ramp
HeatBlock::Ramp::Ramp() {
    clear();
}

void HeatBlock::Ramp::set(double targetTemperature, double rate) {
    _targetTemperature = targetTemperature;
    _lastChangesTime = boost::posix_time::microsec_clock::local_time();
    _rate.store(rate);
}

double HeatBlock::Ramp::computeTemperature(double currentTargetTemperature) {
    if (isEmpty())
        return 0.0;

    boost::posix_time::time_duration pastTime = boost::posix_time::microsec_clock::local_time() - _lastChangesTime;
    _lastChangesTime = boost::posix_time::microsec_clock::local_time();

    if (pastTime.total_milliseconds() > 0) {
        double temp = currentTargetTemperature + (_rate * (pastTime.total_milliseconds() / (double)1000 * 100) / 100);

        if (temp < _targetTemperature)
            return temp;
        else {
            clear();

            return _targetTemperature;
        }
    }
    else
        return currentTargetTemperature;
}
