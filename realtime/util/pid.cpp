#include <boost/date_time.hpp>

#include "pid.h"

using namespace boost::posix_time;

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
    ptime currentExecutionTime = microsec_clock::universal_time();
    double error = setpoint - processValue;
    double output = 0;

    _lock.lock(); {
        double filteredProcessValue = _processValueFilter.processSample(processValue);

        if (!_previousExecutionTime.is_not_a_date_time()) {
            double executionDurationS = (double)(currentExecutionTime - _previousExecutionTime).total_microseconds() / 1000000;
            double derivativeValueS = (filteredProcessValue - _previousProcessValue) / executionDurationS;

            _integratorS += error * executionDurationS;
            output = pidTuning.kControllerGain * (error + _integratorS / pidTuning.kIntegralTimeS + pidTuning.kDerivativeTimeS * derivativeValueS);

            if (latchValue(output, _minOutput, _maxOutput))
                _integratorS = 0;
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
    _previousExecutionTime = not_a_date_time;
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
