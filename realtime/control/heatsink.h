#ifndef _HEATSINK_H_
#define _HEATSINK_H_

#include "icontrol.h"

class Fan;
class Thermistor;
class CPIDController;

namespace Poco { class Timer; }

// Class HeatSink
class HeatSink : public IControl
{
public:
    HeatSink();
	~HeatSink();

    void process();
	
    //accessors
    inline double targetTemperature() const { return _targetTemperature; }
    inline void setTargetTemperature(double temperature) { _targetTemperature = temperature; }

    inline int targetRPM() const { return _fan->targetRPM(); }
    inline void setTargetRPM(int targetRPM) { _fan->setTargetRPM(targetRPM); }
	
private:
    void initPID();
    void pidCallback(Poco::Timer &timer);

    Fan *_fan;

    Thermistor *_thermistor;
    std::atomic<double> _targetTemperature;

    std::atomic<CPIDController*> _pidController;
    Poco::Timer *_pidTimer;
};

#endif
