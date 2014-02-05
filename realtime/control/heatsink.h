#ifndef _HEATSINK_H_
#define _HEATSINK_H_

#include "fan.h"
#include "thermistor.h"

// Class HeatSink
class HeatSink : public IControl
{
public:
    HeatSink();
	~HeatSink();
	
	//accessors
    inline double temperature() { return _thermistor->temperature(); }
	
    void process();
	
private:
    boost::shared_ptr<Fan> _fan;
    boost::shared_ptr<Thermistor> _thermistor;
};

#endif
