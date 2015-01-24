#include "experimentcontroller.h"
#include "lid.h"

Lid::Lid(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, double minTempThreshold, double maxTempThreshold,
         PIDController *pidController, const std::string &pwmPath, unsigned long pwmPeriod, double startTempThreshold)
    :TemperatureController(thermistor, minTargetTemp, maxTargetTemp, minTempThreshold, maxTempThreshold, pidController),
     PWMControl(pwmPath, pwmPeriod)
{
    _startTempThreshold = startTempThreshold;

    resetOutput();
}

Lid::~Lid()
{
    resetOutput();
}

Lid::Direction Lid::outputDirection() const
{
    return EHeat;
}

void Lid::setOutput(double value)
{
    setPWMDutyCycle(value);
}

void Lid::resetOutput()
{
    setOutput(0);
}

void Lid::processOutput()
{
    if (ExperimentController::getInstance()->machineState() == ExperimentController::LidHeating && currentTemperature() >= (targetTemperature() - _startTempThreshold))
        startThresholdReached();
}
