#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

#include "icontrol.h"

class BidirectionalPWMController;
typedef BidirectionalPWMController HeatBlockZoneController;

class Step;
namespace Poco { class Timer; }

// Class HeatBlock
class HeatBlock : public IControl
{
public:
    HeatBlock(HeatBlockZoneController* zone1, HeatBlockZoneController* zone2, double beginStepTemperatureThreshold);
	~HeatBlock();
	
    void process();
    void setMode(bool mode);

    void setTargetTemperature(double targetTemperature);
    double zone1Temperature() const;
    double zone2Temperature() const;

    double maxTemperatureSetpointDelta () const;

    boost::signals2::signal<void()> stagesCompleted;
	
private:
    void stepBegun();
    void holdStepCallback(Poco::Timer &timer);

private:
    std::pair<HeatBlockZoneController*, HeatBlockZoneController*> _zones;

    Step *_step;
    double _beginStepTemperatureThreshold;

    Poco::Timer *_holdStepTimer;
};

#endif
