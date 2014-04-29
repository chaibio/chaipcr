#include "pcrincludes.h"
#include "boostincludes.h"

#include "lid.h"

Lid::Lid(TEMPERATURE_CONTROLLER_ARGS, const std::string &pwmPath, unsigned long pwmPeriod, double startTempThreshold)
    :TEMPERATURE_CONTROLLER_INIT,
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

    if (currentTemperature() >= (targetTemperature() - _startTempThreshold))
        startThresholdReached();
}
