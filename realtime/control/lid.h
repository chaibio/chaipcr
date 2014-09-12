#ifndef LID_H
#define LID_H

#include "temperaturecontroller.h"
#include "pwm.h"

#include <boost/signals2.hpp>

class Lid : public TemperatureController, public PWMControl
{
public:
    Lid(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController,
        const std::string &pwmPath, unsigned long pwmPeriod, double startTempThreshold);
    ~Lid();

    boost::signals2::signal<void()> startThresholdReached;

    Direction outputDirection() const;

protected:
    void setOutput(double value);
    void resetOutput();
    void processOutput();

private:
    double _startTempThreshold;
};

#endif // LID_H
