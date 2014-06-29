#include "pcrincludes.h"
#include "pocoincludes.h"

#include "pid.h"

using namespace boost::posix_time;

////////////////////////////////////////////////////////////////////
// Class PIDController
PIDController::PIDController(const std::vector<SPIDTuning>& pGainSchedule, int minOutput, int maxOutput, const SinglePoleRecursiveFilter& processValueFilter):
    _gainSchedule {pGainSchedule},
    _processValueFilter {processValueFilter},
    _minOutput {minOutput},
    _maxOutput {maxOutput},
    _previousProcessValue {0},
    _integratorS {0} {

    lock = new Poco::RWLock;
}
//------------------------------------------------------------------------------
PIDController::~PIDController() {
    delete lock;
}
//------------------------------------------------------------------------------
double PIDController::compute(double setpoint, double processValue) {
    //calc values for this computation
    const SPIDTuning& PIDTuning = determineGainSchedule(setpoint);
    double error = setpoint - processValue;

    //calculate time since last execution
    ptime currentExecutionTime = microsec_clock::universal_time();
    time_duration executionDuration = currentExecutionTime - _previousExecutionTime;
    double executionDurationS = executionDuration.total_microseconds() / 1000000;

    lock->writeLock();

    //non-interactive PID algorithm
    double filteredProcessValue = _processValueFilter.processSample(processValue);
    _integratorS += error * executionDurationS;
    double derivativeValueS = (filteredProcessValue - _previousProcessValue) / executionDurationS;
    double output = PIDTuning.kControllerGain * (error + _integratorS / PIDTuning.kIntegralTimeS + PIDTuning.kDerivativeTimeS * derivativeValueS);

    //limit drive to system limits, clear integrator when output is maxed to prevent windup
    if (latchValue(&output, _minOutput, _maxOutput))
        _integratorS = 0;

    //set values for next computation
    _previousProcessValue = filteredProcessValue;
    _previousExecutionTime = currentExecutionTime;

    lock->unlock();

    return output;
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
bool PIDController::latchValue(double* value, double minValue, double maxValue) {
    if (*value < minValue)
        *value = minValue;
    else if (*value > maxValue)
        *value = maxValue;
    else
        return false;

    return true;
}

/*--------------------------------------------PIDControl--------------------------------------------*/
PIDControl::PIDControl(PIDController *pidController, long pidTimerInterval) {
    _pidController = pidController;
    _pidResult.store(0);
    _pidTimerInterval = pidTimerInterval;
    _pidTimer = new Poco::Timer;
}

PIDControl::~PIDControl() {
    delete _pidTimer;
    delete _pidController;
}

void PIDControl::startPid() {
    if (!_targetValue)
        throw std::logic_error("targetValue is empty");
    else if (!_currentValue)
        throw std::logic_error("currentValue is empty");

    _pidTimer->setPeriodicInterval(_pidTimerInterval);
    _pidTimer->start(Poco::TimerCallback<PIDControl>(*this, &PIDControl::pidCallback));
}

void PIDControl::stopPid() {
    _pidTimer->stop();
}

void PIDControl::pidCallback(Poco::Timer &) {
    double result = _pidController->compute(_targetValue(), _currentValue());

    if (result != _pidResult.load())
    {
        _pidResult.store(result);

        pidCallback(result);
    }
}
