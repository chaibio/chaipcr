#ifndef _HEATSINK_H_
#define _HEATSINK_H_

#include "icontrol.h"

// Class HeatSink
class HeatSink : public IControl
{
public:
    HeatSink();
	~HeatSink();
	
	//accessors
    inline double temperature() { return _thermistor->temperature(); }
    inline std::shared_ptr<Fan> getFan() { return _fan; }
	
    void process();
	
private:
    std::shared_ptr<Fan> _fan;
    std::shared_ptr<Thermistor> _thermistor;
};

#endif
