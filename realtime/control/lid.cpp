#include "pcrincludes.h"
#include "boostincludes.h"
#include "experimentcontroller.h"

#include "lid.h"

Lid::Lid(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp,
         CPIDController *pidController, long pidTimerInterval, double pidRangeControlThreshold,
         const std::string &pwmPath, unsigned long pwmPeriod, double startTempThreshold)
    :TemperatureController(thermistor, minTargetTemp, maxTargetTemp, pidController, pidTimerInterval, pidRangeControlThreshold),
     PWMControl(pwmPath, pwmPeriod)
{
    _startTempThreshold = startTempThreshold;

    resetOutput();
}

void Lid::setOutput(double value)
{
    setPWMDutyCycle(value);
}

void Lid::resetOutput()
{
    setOutput(0);
}

bool Lid::outputDirection() const
{
    return true;
}

void Lid::processOutput()
{
    processPWM();

    if (ExperimentController::getInstance()->machineState() == ExperimentController::LidHeating && currentTemperature() >= (targetTemperature() - _startTempThreshold))
        startThresholdReached();
}
