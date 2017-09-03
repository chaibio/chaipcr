//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include "bidirectionalpwmcontroller.h"
#include "heatblock.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
HeatBlock::HeatBlock(HeatBlockZoneController* zone1, HeatBlockZoneController* zone2, double beginStepTemperatureThreshold, double maxRampSpeed) {
    _zones = make_pair(zone1, zone2);
    _beginStepTemperatureThreshold = beginStepTemperatureThreshold;
    _maxRampSpeed = maxRampSpeed;
    _stepProcessingState = false;
    _targetTempDirtyState = false;
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
    if (enableMode) {
        std::lock_guard<std::mutex> lock(_stepProcessingMutex);
        _targetTempDirtyState = true;
    }
    else {
        std::lock_guard<std::mutex> lock(_stepProcessingMutex);
        _stepProcessingState = false;
        _targetTempDirtyState = false;
        _ramp.clear();
    }

    _zones.first->setEnableMode(enableMode);
    _zones.second->setEnableMode(enableMode);
}

void HeatBlock::enableStepProcessing() {
    _stepProcessingMutex.lock();
    _stepProcessingState = true;
    _stepProcessingMutex.unlock();
}

double HeatBlock::minTargetTemperature() const {
    return _zones.first->minTargetTemperature();
}

double HeatBlock::maxTargetTemperature() const {
    return _zones.first->maxTargetTemperature();
}

void HeatBlock::setTargetTemperature(double targetTemperature, double rampRate) {
    if (targetTemperature < minTargetTemperature() || targetTemperature > maxTargetTemperature() || std::isnan(targetTemperature))
    {
        std::stringstream string;
        string << "Requested heat block temperature outside limits of " << minTargetTemperature() << '-' << maxTargetTemperature() << " C";

        throw std::out_of_range(string.str());
    }
    else if (rampRate <= 0)
    {
        std::stringstream string;
        string << "Requested heat block ramp rate is equal or below 0";

        throw std::out_of_range(string.str());
    }
    else if (rampRate > _maxRampSpeed)
        rampRate = _maxRampSpeed;

    std::lock_guard<std::mutex> lock(_stepProcessingMutex);
    _ramp.set(targetTemperature, rampRate);
}

double HeatBlock::targetTemperature() const {
    std::lock_guard<std::mutex> lock(_stepProcessingMutex);
    return _ramp.targetTemperature();
}

void HeatBlock::calculateTemperature() {
    bool finished = false;

    {
        std::lock_guard<std::mutex> lock(_stepProcessingMutex);

        if (!_ramp.isEmpty()) {
            double temp = 0;

            if (!_targetTempDirtyState) {
                temp = _ramp.computeTemperature(_zones.first->targetTemperature());
            }
            else {
                temp = _ramp.computeTemperature(_zones.first->currentTemperature());
                _targetTempDirtyState = false;
            }

            _zones.first->setTargetTemperature(temp);
            _zones.second->setTargetTemperature(temp);

            finished = _ramp.isEmpty();
        }
    }

    if (finished)
        rampFinished();
}

double HeatBlock::zone1Temperature() const {
    return _zones.first->currentTemperature();
}

double HeatBlock::zone1TargetTemperature() const {
    return _zones.first->targetTemperature();
}

double HeatBlock::zone2Temperature() const {
    return _zones.second->currentTemperature();
}

double HeatBlock::zone2TargetTemperature() const {
    return _zones.second->targetTemperature();
}

double HeatBlock::temperature() const {
    return (zone1Temperature() + zone2Temperature()) / 2;
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
    _lastChangesTime = boost::chrono::high_resolution_clock::now();
}

double HeatBlock::Ramp::computeTemperature(double currentTargetTemperature) {
    if (isEmpty())
        return _targetTemperature;

    boost::chrono::high_resolution_clock::time_point previousTime = _lastChangesTime;
    _lastChangesTime = boost::chrono::high_resolution_clock::now();

    boost::chrono::milliseconds pastTime(boost::chrono::duration_cast<boost::chrono::milliseconds>(_lastChangesTime - previousTime));

    if (pastTime.count() > 0) {
        if (currentTargetTemperature > _targetTemperature) {
            double temp = currentTargetTemperature - (_rate * (pastTime.count() / (double)1000 * 100) / 100);

            if (temp <= _targetTemperature) {
                clear();
                return _targetTemperature;
            }
            else
                return temp;
        }
        else {
            double temp = currentTargetTemperature + (_rate * (pastTime.count() / (double)1000 * 100) / 100);

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
