#ifndef HEATSINK_H
#define HEATSINK_H

#include "temperaturecontroller.h"

class Fan;

class HeatSink : public TemperatureController
{
public:
    HeatSink(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp,
             PIDController *pidController, long pidTimerInterval);
    ~HeatSink();

    int targetRPM() const;
    void setTargetRPM(int targetRPM);

protected:
    void setOutput(double value);
    void resetOutput();
    bool outputDirection() const;
    void processOutput();

private:
    Fan *_fan;
};

#endif // HEATSINK_H
