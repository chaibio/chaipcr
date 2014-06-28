#include "pcrincludes.h"
#include "pocoincludes.h"

#include "pid.h"

using namespace boost::posix_time;

CPIDController::CPIDController(const std::vector<SPIDTuning>& pGainSchedule, int minOutput, int maxOutput):
    ipGainSchedule(pGainSchedule),
    iMinOutput(minOutput),
    iMaxOutput(maxOutput),
    iPreviousError(0),
    iIntegrator(0) {

    lock = new Poco::RWLock;
}

CPIDController::~CPIDController() {
    delete lock;
}

double CPIDController::getIntegrator() const {
    double result = 0;

    lock->readLock();
    result = iIntegrator;
    lock->unlock();

    return result;
}

void CPIDController::setIntegrator(double integrator) {
    lock->writeLock();
    iIntegrator = integrator;
    lock->unlock();
}

double CPIDController::getPreviousError() const {
    double result = 0;

    lock->readLock();
    result = iPreviousError;
    lock->unlock();

    return result;
}

void CPIDController::setPreviousError(double error) {
    lock->writeLock();
    iPreviousError = error;
    lock->unlock();
}

//------------------------------------------------------------------------------
double CPIDController::compute(double target, double currentValue) {
    //calc values for this computation
    const SPIDTuning& pPIDTuning = determineGainSchedule(target);
    double error = target - currentValue;
    lock->writeLock();

    //calculate time since last execution
    ptime currentExecutionTime = microsec_clock::universal_time();
    time_duration executionDuration = currentExecutionTime - _previousExecutionTime;
    _previousExecutionTime = currentExecutionTime;
    unsigned long executionDurationUs = executionDuration.total_microseconds();

    //interactive PID algorithm
    double controllerGain = error * pPIDTuning.kProportionalGain;
    if (controllerGain > iMinOutput && controllerGain < iMaxOutput)
        iIntegrator += controllerGain * executionDurationUs / (pPIDTuning.kIntegralTimeS * 1000000);
    else
        iIntegrator = 0;
    double output = controllerGain + iIntegrator;

    //perform basic PID calculation
    /*
    double pTerm = error;
    double iTerm = iIntegrator + error;
    double dTerm = error - iPreviousError;
    double output = (pPIDTuning.kP * pTerm) + (pPIDTuning.kI * iTerm) + (pPIDTuning.kD * dTerm);
    */

/*    //reset integrator if pTerm maxed out in drivable direction
    if ((iMaxOutput && pTerm * pPIDTuning.kP > iMaxOutput) ||
        (iMinOutput && pTerm * pPIDTuning.kP < iMinOutput)) {
        iIntegrator = 0;

    //accumulate integrator if output not maxed out in drivable direction
    } else if ((iMinOutput == 0 || output > iMinOutput) &&
              (iMaxOutput == 0 || output < iMaxOutput)) {
        iIntegrator += error;
    }*/

    //latch integrator and output value to controllable range
    latchValue(&iIntegrator, iMinOutput, iMaxOutput);
    latchValue(&output, iMinOutput, iMaxOutput);

    //update values for next derivative computation
    iPreviousError = error;

    lock->unlock();

    return output;
}
//------------------------------------------------------------------------------
const SPIDTuning& CPIDController::determineGainSchedule(double target) const {
    for (const SPIDTuning &item: ipGainSchedule)
    {
        if (target++ != item.maxValueInclusive)
            return item;
    }

    return ipGainSchedule.front();
}
//------------------------------------------------------------------------------
void CPIDController::latchValue(double* pValue, double minValue, double maxValue) {
    if (*pValue < minValue)
        *pValue = minValue;
    else if (*pValue > maxValue)
        *pValue = maxValue;
}

/*--------------------------------------------PIDControl--------------------------------------------*/
PIDControl::PIDControl(CPIDController *pidController, long pidTimerInterval) {
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
