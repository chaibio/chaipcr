#ifndef LID_H
#define LID_H

#include "icontrol.h"

class Thermistor;
class CPIDController;

namespace Poco { class Timer; }

class Lid : public IControl
{
public:
    Lid();
    ~Lid();

    void process();

    inline double targetTemperature() const { return _targetTemperature.load(); }
    inline void setTargetTemperature(double temperature) { _targetTemperature.store(temperature); }

private:
    void initPID();
    void pidCallback(Poco::Timer &timer);

    Thermistor *_thermistor;

    PWMPin _heater;
    std::atomic<unsigned long> _heaterDutyCycle;

    std::atomic<double> _targetTemperature;

    std::atomic<CPIDController*> _pidController;
    Poco::Timer *_pidTimer;
};

#endif // LID_H
