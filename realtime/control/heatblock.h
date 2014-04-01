#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

#include "icontrol.h"

class Thermistor;
class HeatBlockZoneController;

// Class HeatBlock
class HeatBlock : public IControl
{
public:
    HeatBlock();
	~HeatBlock();
	
    void process();

    void setTargetTemperature(double targetTemperature);
    double zone1Temperature() const;
    double zone2Temperature() const;
    std::shared_ptr<Thermistor> zone1Thermistor();
    std::shared_ptr<Thermistor> zone2Thermistor();
	
private:
    std::pair<HeatBlockZoneController*, HeatBlockZoneController*> _zones;
};

#endif
