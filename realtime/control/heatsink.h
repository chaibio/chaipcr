#ifndef HEATSINK_H
#define HEATSINK_H

#include "temperaturecontroller.h"
#include "adcpin.h"

class PWMControl;

namespace Poco { class Timer; }

class HeatSink : public TemperatureController
{
public:
    HeatSink(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, double minTempThreshold, double maxTempThreshold,
             PIDController *pidController, const std::string &fanPWMPath, unsigned long fanPWMPeriod, const ADCPin &adcPin);
    ~HeatSink();

    Direction outputDirection() const;
    double fanDrive() const;

protected:
    void setOutput(double value);
    void resetOutput();
    void processOutput();

private:
    void readADCPin(Poco::Timer &timer);

private:
    PWMControl *_fan;

    ADCPin _adcPin;
    Poco::Timer *_adcTimer;
};

#endif // HEATSINK_H
