#include "heatsink.h"
#include "pwm.h"

HeatSink::HeatSink(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController, const std::string &fanPWMPath, unsigned long fanPWMPeriod)
    :TemperatureController(thermistor, minTargetTemp, maxTargetTemp, pidController)
{
    _fan = new PWMControl(fanPWMPath, fanPWMPeriod);
    _fan->setPWMDutyCycle(fanPWMPeriod * 0.5);

    resetOutput();
}

HeatSink::~HeatSink()
{
    resetOutput();

    delete _fan;
}

void HeatSink::setOutput(double value)
{
    if (currentTemperature() >= targetTemperature())
        _fan->setPWMDutyCycle(value);
    else
        _fan->setPWMDutyCycle(0.0);
}

void HeatSink::resetOutput()
{
    setOutput(0);
}

bool HeatSink::outputDirection() const
{
    return false;
}

void HeatSink::processOutput()
{
}
