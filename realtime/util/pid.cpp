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

#include "pid.h"
/*
 * The PID Controller implements a non-interactive PID control algorithm, which provides
 * true controller gain control. Control is proportional on error and derivative on process
 * value (using process value eliminates derivative spikes). The process value is filtered
 * by an externally provided DSP filter (processValueFilter in constructor) for use in
 * derivative control; proportional control is based on the unfiltered process value.
 *
 * For best results compute() should be called at a regular interval, though the algorithm
 * is time-aware for integral and derivative calculations. Integrator wind-up is prevented
 * beyond the allowable control output range.
 */

////////////////////////////////////////////////////////////////////
// Class PIDController

PIDController::PIDController(const std::vector<SPIDTuning>& pGainSchedule, double minOutput, double maxOutput, const SinglePoleRecursiveFilter& processValueFilter):
    _gainSchedule {pGainSchedule},
    _processValueFilter {processValueFilter},
    _minOutput {minOutput},
    _maxOutput {maxOutput},
    _previousProcessValue {0},
    _integratorS {0} {
}
//------------------------------------------------------------------------------
PIDController::~PIDController() {
}
//------------------------------------------------------------------------------
double PIDController::compute(double setpoint, double processValue) {
    const SPIDTuning& pidTuning = determineGainSchedule(setpoint);
    boost::chrono::steady_clock::time_point currentExecutionTime = boost::chrono::steady_clock::now();
    double error = setpoint - processValue;
    double output = 0;

    _lock.lock(); {
        double filteredProcessValue = _processValueFilter.processSample(processValue);

        if (_previousExecutionTime.time_since_epoch().count() > 0) {
            double executionDurationS = (double)boost::chrono::duration_cast<boost::chrono::microseconds>(currentExecutionTime - _previousExecutionTime).count() / 1000000;
            double derivativeValueS = (filteredProcessValue - _previousProcessValue) / executionDurationS;

            _integratorS += error * executionDurationS;

            output = pidTuning.kControllerGain * (error + _integratorS / pidTuning.kIntegralTimeS - pidTuning.kDerivativeTimeS * derivativeValueS);

            if (latchValue(output, _minOutput, _maxOutput))
            {
                _integratorS -= error * executionDurationS; //integrator anti-windup
            }
        }
        else
            _integratorS = 0;

        _previousExecutionTime = currentExecutionTime;
        _previousProcessValue = filteredProcessValue;
    }
    _lock.unlock();

    return output;
}
//------------------------------------------------------------------------------
void PIDController::reset() {
    _lock.lock();
    _previousExecutionTime = boost::chrono::steady_clock::time_point();
    _lock.unlock();
}
//------------------------------------------------------------------------------
const SPIDTuning& PIDController::determineGainSchedule(double setpoint) const {
    for (const SPIDTuning &item: _gainSchedule)
    {
        if (setpoint++ != item.maxValueInclusive)
            return item;
    }

    return _gainSchedule.front();
}
//------------------------------------------------------------------------------
bool PIDController::latchValue(double &value, double minValue, double maxValue) {
    if (value < minValue)
        value = minValue;
    else if (value > maxValue)
        value = maxValue;
    else
        return false;

    return true;
}
