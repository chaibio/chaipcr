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
    Lid(std::vector<SPIDTuning> pidTunningList);
    ~Lid();

    void process();
    std::shared_ptr<Thermistor> thermistor() const {return _thermistor;}

private:
    void initPID();
    void pidCallback(Poco::Timer &timer);

    CPIDController *_pidController;
    Poco::Timer *_pidTimer;
    std::vector<SPIDTuning> _pidTuningList;
};

#endif // LID_H
