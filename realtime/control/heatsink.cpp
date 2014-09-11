#include "heatsink.h"
#include "pwm.h"

HeatSink::HeatSink(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController, const std::string &fanPWMPath, unsigned long fanPWMPeriod)
    :TemperatureController(thermistor, minTargetTemp, maxTargetTemp, pidController)
{
    _fan = new PWMControl(fanPWMPath, fanPWMPeriod);
    _fan->setPWMDutyCycle((unsigned long)0);

    resetOutput();
}

HeatSink::~HeatSink()
{
    resetOutput();

    delete _fan;
}

double HeatSink::fanDrive() const
{
    return (double)_fan->pwmDutyCycle() / _fan->pwmPeriod();
}

void HeatSink::setOutput(double value)
{
    _fan->setPWMDutyCycle(value * -1);
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
