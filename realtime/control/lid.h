#ifndef LID_H
#define LID_H

#include "temperaturecontroller.h"
#include "pwm.h"
#include "lockfreesignal.h"

class Lid : public TemperatureController, public PWMControl
{
public:
    Lid(Settings settings, const std::string &pwmPath, unsigned long pwmPeriod, double startTempThreshold);
    ~Lid();

    boost::signals2::lockfree_signal<void()> startThresholdReached;

    Direction outputDirection() const;
    void setOutput(double value);

protected:
    void resetOutput();
    void processOutput();

private:
    double _startTempThreshold;
};

#endif // LID_H
