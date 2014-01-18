#ifndef _HEATSINK_H_
#define _HEATSINK_H_

#include "fan.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatSink
class HeatSink {
public:
	HeatSink() throw();
	~HeatSink();
	
	void process() throw();
	
private:
	Fan fan_;
};

#endif
