#ifndef LID_H
#define LID_H

#include "temperaturecontroller.h"
#include "pwm.h"

class Lid : public TemperatureController, public PWMControl
{
public:
    Lid(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp,
        CPIDController *pidController, long pidTimerInterval, double pidRangeControlThreshold,
        const std::string &pwmPath, unsigned long pwmPeriod, double startTempThreshold);
    ~Lid();

    boost::signals2::signal<void()> startThresholdReached;

protected:
    void setOutput(double value);
    void resetOutput();
    bool outputDirection() const;
    void processOutput();

private:
    double _startTempThreshold;
};

#endif // LID_H
