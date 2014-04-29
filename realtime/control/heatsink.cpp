#include "pcrincludes.h"

#include "fan.h"
#include "heatsink.h"

HeatSink::HeatSink(TEMPERATURE_CONTROLLER_ARGS)
    :TEMPERATURE_CONTROLLER_INIT
{
    _fan = new Fan();

    resetOutput();
}

HeatSink::~HeatSink()
{
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
