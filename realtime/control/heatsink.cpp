#include "pcrincludes.h"
#include "heatsink.h"
#include "pwm.h"
#include "thermistor.h"

#include <Poco/Timer.h>

HeatSink::HeatSink(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController,
                   const std::string &fanPWMPath, unsigned long fanPWMPeriod, const ADCPin &adcPin)
    :TemperatureController(thermistor, minTargetTemp, maxTargetTemp, pidController),
      _adcPin(adcPin)
{
    _fan = new PWMControl(fanPWMPath, fanPWMPeriod);
    _adcTimer = new Poco::Timer;

    _fan->setPWMDutyCycle((unsigned long)0);

    resetOutput();

    _adcTimer->setPeriodicInterval(kHeatSinkADCInterval);
    _adcTimer->start(Poco::TimerCallback<HeatSink>(*this, &HeatSink::readADCPin));
}

HeatSink::~HeatSink()
{
    _adcTimer->stop();

    resetOutput();

    delete _fan;
    delete _adcTimer;
}


HeatSink::Direction HeatSink::outputDirection() const
{
    return ECool;
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

void HeatSink::processOutput()
{
}

void HeatSink::readADCPin(Poco::Timer &/*timer*/) {
    _thermistor->setADCValues(_adcPin.readValue());
}
