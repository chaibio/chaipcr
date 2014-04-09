#ifndef _HEATBLOCKZONE_H_
#define _HEATBLOCKZONE_H_

#include "icontrol.h"
#include "pwm.h"
#include "thermistor.h"
#include "gpio.h"

class CPIDController;

namespace Poco { class Timer; }

// Class HeatBlockZoneController
class HeatBlockZoneController : public IControl, public PWMControl, public TemperatureControl
{
public:
    HeatBlockZoneController(const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin);
    ~HeatBlockZoneController();

    void process();

    std::shared_ptr<Thermistor> thermistor() const;

private:
    void initPID();
    void pidCallback(Poco::Timer &timer);

    CPIDController *_pidController;
    Poco::Timer *_pidTimer;
    std::atomic<double> _pidResult;

    GPIO heatIO;
    GPIO coolIO;
};

#endif
