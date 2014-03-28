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
    double zone1Temperature();
    double zone2Temperature();
	
private:
    std::pair<HeatBlockZoneController*, HeatBlockZoneController*> _zones;
};

#endif
