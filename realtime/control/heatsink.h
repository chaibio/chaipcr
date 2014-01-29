#ifndef _HEATSINK_H_
#define _HEATSINK_H_

#include "fan.h"
#include "thermistor.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatSink
class HeatSink {
public:
	HeatSink() throw();
	~HeatSink();
	
	//accessors
	inline double temperature() { return thermistor_.temperature(); }
	
	void process() throw();
	
private:
	Fan fan_;
	Thermistor thermistor_;
};

#endif
