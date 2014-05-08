#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

#include "icontrol.h"

class BidirectionalPWMController;
typedef BidirectionalPWMController HeatBlockZoneController;

// Class HeatBlock
class HeatBlock : public IControl
{
public:
    HeatBlock(HeatBlockZoneController* zone1, HeatBlockZoneController* zone2, double beginStepTemperatureThreshold);
	~HeatBlock();
	
    void process();
    void setEnableMode(bool enableMode);
    inline void enableStepProcessing() { _stepProcessingState = true; }

    void setTargetTemperature(double targetTemperature);
    double zone1Temperature() const;
    double zone2Temperature() const;

    double maxTemperatureSetpointDelta () const;

    boost::signals2::signal<void()> stepBegun;

private:
    std::pair<HeatBlockZoneController*, HeatBlockZoneController*> _zones;

    double _beginStepTemperatureThreshold;
    std::atomic<bool> _stepProcessingState;
};

#endif
