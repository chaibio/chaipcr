#include "experimentcontroller.h"
#include "lid.h"

Lid::Lid(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController,
         const std::string &pwmPath, unsigned long pwmPeriod, double startTempThreshold)
    :TemperatureController(thermistor, minTargetTemp, maxTargetTemp, pidController),
     PWMControl(pwmPath, pwmPeriod)
{
    _startTempThreshold = startTempThreshold;

    resetOutput();
}

Lid::~Lid()
{
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
    if (ExperimentController::getInstance()->machineState() == ExperimentController::LidHeating && currentTemperature() >= (targetTemperature() - _startTempThreshold))
        startThresholdReached();
}
