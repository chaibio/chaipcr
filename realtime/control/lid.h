#ifndef LID_H
#define LID_H

#include "icontrol.h"
#include "pwm.h"

class Thermistor;
class CPIDController;

namespace Poco { class Timer; }

class Lid : public IControl, public PWMControl
{
public:
    Lid();
    ~Lid();

    void process();

    inline double targetTemperature() const { return _targetTemperature; }
    inline void setTargetTemperature(double temperature) { _targetTemperature = temperature; }

private:
    void initPID();
    void pidCallback(Poco::Timer &timer);

    Thermistor *_thermistor;
    std::atomic<double> _targetTemperature;

    std::atomic<CPIDController*> _pidController;
    Poco::Timer *_pidTimer;
};

#endif // LID_H
