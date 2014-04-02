#ifndef LID_H
#define LID_H

#include "icontrol.h"
#include "pwm.h"
#include "thermistor.h"

class CPIDController;

namespace Poco { class Timer; }

class Lid : public IControl, public PWMControl, public TemperatureControl
{
public:
    Lid();
    ~Lid();

    void process();

private:
    void initPID();
    void pidCallback(Poco::Timer &timer);

    CPIDController *_pidController;
    Poco::Timer *_pidTimer;
};

#endif // LID_H
