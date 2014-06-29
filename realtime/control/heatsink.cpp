#include "pcrincludes.h"

#include "fan.h"
#include "heatsink.h"

HeatSink::HeatSink(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp,
                   PIDController *pidController, long pidTimerInterval, double pidRangeControlThreshold)
    :TemperatureController(thermistor, minTargetTemp, maxTargetTemp, pidController, pidTimerInterval, pidRangeControlThreshold)
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
    _fan->setPWMDutyCycle(value);
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

int HeatSink::targetRPM() const
{
    return _fan->targetRPM();
}

void HeatSink::setTargetRPM(int targetRPM)
{
    _fan->setTargetRPM(targetRPM);
}
