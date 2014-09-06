#include "fan.h"
#include "heatsink.h"

HeatSink::HeatSink(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController)
    :TemperatureController(thermistor, minTargetTemp, maxTargetTemp, pidController)
{
    _fan = new Fan();

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
    _fan->process();
}

/*int HeatSink::targetRPM() const
{
    return _fan->targetRPM();
}

void HeatSink::setTargetRPM(int targetRPM)
{
    _fan->setTargetRPM(targetRPM);
}*/
