#ifndef _HEATBLOCKZONE_H_
#define _HEATBLOCKZONE_H_

class MCPADC;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlockZoneController
class HeatBlockZoneController {
public:
	HeatBlockZoneController(unsigned int adcCSPinNumber) throw();
	~HeatBlockZoneController();
	
	inline float currentTemp() { return currentTemp_; }
	inline float targetTemp() { return targetTemp_; }
	void setTargetTemp(float targetTemp);
	
	chaistatus_t process();

private:
	//components
	MCPADC* tempAdc_;
	
	//state
	float currentTemp_;
	float targetTemp_;
};

#endif
