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

void HeatBlock::setDrive(double drive) {
    _zones.first->setOutput(drive);
    _zones.second->setOutput(drive);
}

double HeatBlock::zone1DriveValue() const {
    return _zones.first->drive() * (_zones.first->outputDirection() == TemperatureController::EHeat ? 1 : -1);
}

double HeatBlock::zone2DriveValue() const {
    return _zones.second->drive() * (_zones.second->outputDirection() == TemperatureController::EHeat ? 1 : -1);
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

    boost::posix_time::ptime previousTime = _lastChangesTime;
    _lastChangesTime = boost::posix_time::microsec_clock::local_time();

    boost::posix_time::time_duration pastTime = _lastChangesTime - previousTime;

    if (pastTime.total_milliseconds() > 0) {
        if (currentTargetTemperature > _targetTemperature)
        {
            double temp = currentTargetTemperature - (_rate * (pastTime.total_milliseconds() / (double)1000 * 100) / 100);

            if (temp <= _targetTemperature)
            {
                clear();
                return _targetTemperature;
            }
            else
                return temp;
        }
        else
        {
            double temp = currentTargetTemperature + (_rate * (pastTime.total_milliseconds() / (double)1000 * 100) / 100);

            if (temp >= _targetTemperature)
            {
                clear();
                return _targetTemperature;
            }
            else
                return temp;
        }
    }
    else
        return currentTargetTemperature;
}
