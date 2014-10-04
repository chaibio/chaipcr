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
    bool begunStep = false;

    _zones.first->process();
    _zones.second->process();

    _stepProcessingMutex.lock(); {
        if (_stepProcessingState && _ramp.isEmpty()) {
            if (_beginStepTemperatureThreshold > maxTemperatureSetpointDelta()) {
                _stepProcessingState = false;
                begunStep = true;
            }
        }
    }
    _stepProcessingMutex.unlock();

    if (begunStep)
        stepBegun();
}

void HeatBlock::setEnableMode(bool enableMode) {
    if (!enableMode) {
        _stepProcessingMutex.lock();
        _stepProcessingState = false;
        _stepProcessingMutex.unlock();
    }

    _zones.first->setEnableMode(enableMode);
    _zones.second->setEnableMode(enableMode);
}

void HeatBlock::enableStepProcessing() {
    _stepProcessingMutex.lock();
    _stepProcessingState = true;
    _stepProcessingMutex.unlock();
}

void HeatBlock::setTargetTemperature(double targetTemperature, double rampRate) {
    _stepProcessingMutex.lock(); {
        if (rampRate == 0) {
            _zones.first->setTargetTemperature(targetTemperature);
            _zones.second->setTargetTemperature(targetTemperature);
        }
        else
            _ramp.set(targetTemperature, rampRate);
    }
    _stepProcessingMutex.unlock();
}

void HeatBlock::calculateTargetTemperature() {
    _stepProcessingMutex.lock(); {
        if (_stepProcessingState && !_ramp.isEmpty()) {
            double temp = _ramp.computeTemperature(_zones.first->targetTemperature());

            _zones.first->setTargetTemperature(temp);
            _zones.second->setTargetTemperature(temp);
        }
    }
    _stepProcessingMutex.unlock();
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
    clear();

    _targetTemperature = targetTemperature;
    _rate = rate;
    _lastChangesTime = boost::posix_time::microsec_clock::local_time();
}

double HeatBlock::Ramp::computeTemperature(double currentTargetTemperature) {
    if (isEmpty())
        return 0.0;

    boost::posix_time::ptime previousTime = _lastChangesTime;
    _lastChangesTime = boost::posix_time::microsec_clock::local_time();

    boost::posix_time::time_duration pastTime = _lastChangesTime - previousTime;

    if (pastTime.total_milliseconds() > 0) {
        if (currentTargetTemperature > _targetTemperature) {
            double temp = currentTargetTemperature - (_rate * (pastTime.total_milliseconds() / (double)1000 * 100) / 100);

            if (temp <= _targetTemperature) {
                clear();
                return _targetTemperature;
            }
            else
                return temp;
        }
        else {
            double temp = currentTargetTemperature + (_rate * (pastTime.total_milliseconds() / (double)1000 * 100) / 100);

            if (temp >= _targetTemperature) {
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
