/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef PID_H
#define PID_H

#include "filters.h"

#include <vector>
#include <mutex>
#include <boost/chrono.hpp>

struct SPIDTuning {
    int maxValueInclusive;
    double kControllerGain;
    double kIntegralTimeS;
    double kDerivativeTimeS;
};

////////////////////////////////////////////////////////////////////
// Class PIDController
class PIDController {
public:
    PIDController(const std::vector<SPIDTuning>& pGainSchedule, double minOutput, double maxOutput, const SinglePoleRecursiveFilter& processValueFilter);
    ~PIDController();

    inline double getMinOutput() const { return _minOutput; }
    inline double getMaxOutput() const { return _maxOutput; }

    //computation
    double compute(double setpoint, double processValue);
    void reset();

private:
    const SPIDTuning& determineGainSchedule(double setpoint) const;
    bool latchValue(double& value, double minValue, double maxValue);

private:
    std::vector<SPIDTuning> _gainSchedule;
    SinglePoleRecursiveFilter _processValueFilter;
    const double _minOutput, _maxOutput;

    double _previousProcessValue;
    double _integratorS;
    boost::chrono::steady_clock::time_point _previousExecutionTime;

    mutable std::mutex _lock;
};

#endif // PID_H
