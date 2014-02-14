#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

#include "icontrol.h"

class HeatBlockZoneController;

// Class HeatBlock
class HeatBlock : public IControl
{
public:
    HeatBlock();
	~HeatBlock();
	
    void process();

    void setTargetTemperature(double targetTemperature);
    void setTargetTemperature(double targetTemperatureZone1, double targetTemperatureZone2);
    double targetTemperature1() const;
    double targetTemperature2() const;
	
private:
    std::pair<HeatBlockZoneController*, HeatBlockZoneController*> _zones;
};

#endif
