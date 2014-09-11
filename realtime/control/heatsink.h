#ifndef HEATSINK_H
#define HEATSINK_H

#include "temperaturecontroller.h"

class PWMControl;

class HeatSink : public TemperatureController
{
public:
    HeatSink(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController,
             const std::string &fanPWMPath, unsigned long fanPWMPeriod);
    ~HeatSink();

    double fanDrive() const;

protected:
    void setOutput(double value);
    void resetOutput();
    bool outputDirection() const;
    void processOutput();

private:
    PWMControl *_fan;
};

#endif // HEATSINK_H
