#ifndef _HEATBLOCKZONE_H_
#define _HEATBLOCKZONE_H_

#include "thermistor.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlockZoneController
class HeatBlockZoneController {
public:
    HeatBlockZoneController();
	virtual ~HeatBlockZoneController();
	
	inline double currentTemp() { return zoneThermistor_.temperature(); }
	inline double targetTemp() { return targetTemp_; }
	void setTargetTemp(double targetTemp);
	
    void process();

private:
	//components
	Thermistor zoneThermistor_;
	
	//state
	double targetTemp_;
};

#endif
