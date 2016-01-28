#include "pcrincludes.h"
#include "heatsink.h"
#include "pwm.h"
#include "thermistor.h"
#include "qpcrapplication.h"

#include <Poco/Timer.h>

HeatSink::HeatSink(Settings settings, const std::string &fanPWMPath, unsigned long fanPWMPeriod, const ADCPin &adcPin)
    :TemperatureController(settings), _adcPin(adcPin)
{
    _fan = new PWMControl(fanPWMPath, fanPWMPeriod);
    _adcTimer = new Poco::Timer;

    _fan->setPWMDutyCycle((unsigned long)0);

    resetOutput();
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
    return _fan->drive();
}

void HeatSink::startADCReading()
{
    _adcTimer->setPeriodicInterval(kHeatSinkADCInterval);
    _adcTimer->start(Poco::TimerCallback<HeatSink>(*this, &HeatSink::readADCPin));
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

void HeatSink::readADCPin(Poco::Timer &/*timer*/)
{
    try
    {
        _thermistor->setADCValue(_adcPin.readValue());
    }
    catch (const std::exception &ex)
    {
        if (std::string("basic_filebuf::underflow error reading the file") == ex.what())
            return;

        qpcrApp.stopExperiment(ex.what());
    }
    catch (...)
    {
        qpcrApp.setException(std::current_exception());
    }
}
