#ifndef _HEATBLOCKZONE_H_
#define _HEATBLOCKZONE_H_

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlockZoneController
class HeatBlockZoneController {
public:
	HeatBlockZoneController(unsigned int adcCSPinNumber) throw();
	virtual ~HeatBlockZoneController();
	
	inline float currentTemp() { return currentTemp_; }
	inline float targetTemp() { return targetTemp_; }
	void setTargetTemp(float targetTemp);
	
	void process() throw();

private:
	//components
	
	//state
	float currentTemp_;
	float targetTemp_;
};

#endif
