#ifndef _HEATSINK_H_
#define _HEATSINK_H_

#include "icontrol.h"
#include "thermistor.h"

class Fan;
class CPIDController;

namespace Poco { class Timer; }

// Class HeatSink
class HeatSink : public IControl, public TemperatureControl
{
public:
    HeatSink();
	~HeatSink();

    void process();
	
    //accessors
    inline int targetRPM() const { return _fan->targetRPM(); }
    inline void setTargetRPM(int targetRPM) { _fan->setTargetRPM(targetRPM); }
	
private:
    void initPID();
    void pidCallback(Poco::Timer &timer);

    Fan *_fan;

    CPIDController *_pidController;
    Poco::Timer *_pidTimer;
};

#endif
