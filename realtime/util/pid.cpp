#include "pcrincludes.h"
#include "pocoincludes.h"

#include "pid.h"

CPIDController::CPIDController(const std::vector<SPIDTuning>& pGainSchedule, int minOutput, int maxOutput):
    ipGainSchedule(pGainSchedule),
    iMinOutput(minOutput),
    iMaxOutput(maxOutput),
    iPreviousError(0),
    iIntegrator(0) {
}
//------------------------------------------------------------------------------
double CPIDController::compute(double target, double currentValue) {
    //calc values for this computation
    const SPIDTuning& pPIDTuning = determineGainSchedule(target);
    double error = target - currentValue;

    //perform basic PID calculation
    double pTerm = error;
    double iTerm = iIntegrator + error;
    double dTerm = error - iPreviousError;
    double output = (pPIDTuning.kP * pTerm) + (pPIDTuning.kI * iTerm) + (pPIDTuning.kD * dTerm);

    //reset integrator if pTerm maxed out in drivable direction
    if ((iMaxOutput && pTerm * pPIDTuning.kP > iMaxOutput) ||
        (iMinOutput && pTerm * pPIDTuning.kP < iMinOutput)) {
        iIntegrator = 0;

    //accumulate integrator if output not maxed out in drivable direction
    } else if ((iMinOutput == 0 || output > iMinOutput) &&
              (iMaxOutput == 0 || output < iMaxOutput)) {
        iIntegrator += error;
    }

    //latch integrator and output value to controllable range
    latchValue(&iIntegrator, iMinOutput, iMaxOutput);
    latchValue(&output, iMinOutput, iMaxOutput);

    //update values for next derivative computation
    iPreviousError = error;

    return output;
}
//------------------------------------------------------------------------------
const SPIDTuning& CPIDController::determineGainSchedule(double target) {
    /*const SPIDTuning* pGainScheduleItem = ipGainSchedule;

    while (target > pGainScheduleItem->maxValueInclusive)
        pGainScheduleItem++;

    return pGainScheduleItem;*/

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
