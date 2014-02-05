#ifndef _HEATBLOCKZONE_H_
#define _HEATBLOCKZONE_H_

#include "thermistor.h"

// Class HeatBlockZoneController
class HeatBlockZoneController : public IControl
{
public:
    HeatBlockZoneController();
	virtual ~HeatBlockZoneController();
	
    inline double currentTemp() { return _zoneThermistor->temperature(); }
    inline double targetTemp() { return _targetTemp.load(); }
    void setTargetTemp(double targetTemp) { _targetTemp.store(targetTemp); }
	
    void process();

private:
	//components
    boost::shared_ptr<Thermistor> _zoneThermistor;
	
	//state
    boost::atomic<double> _targetTemp;
};

#endif
