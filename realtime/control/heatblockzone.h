#ifndef _HEATBLOCKZONE_H_
#define _HEATBLOCKZONE_H_

#include "icontrol.h"
#include "pwm.h"
#include "thermistor.h"

class CPIDController;

namespace Poco { class Timer; }

// Class HeatBlockZoneController
class HeatBlockZoneController : public IControl, public PWMControl
{
public:
    HeatBlockZoneController(const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin);
	virtual ~HeatBlockZoneController();

    void process();
	
    inline double currentTemp() const { return _thermistor->temperature(); }

    inline double targetTemp() const { return _targetTemp; }
    inline void setTargetTemp(double targetTemp) { _targetTemp = targetTemp; }

    std::shared_ptr<Thermistor> thermistor() { return _thermistor; }

private:
    void initPID();
    void pidCallback(Poco::Timer &timer);

    std::shared_ptr<Thermistor> _thermistor;
    std::atomic<double> _targetTemp;

    std::atomic<CPIDController*> _pidController;
    Poco::Timer *_pidTimer;
    std::atomic<double> _pidResult;

    GPIO heatIO;
    GPIO coolIO;
};

#endif
