#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

#include "icontrol.h"

#include <mutex>
#include <utility>
#include <boost/chrono.hpp>
#include <boost/signals2.hpp>

class BidirectionalPWMController;
typedef BidirectionalPWMController HeatBlockZoneController;

// Class HeatBlock
class HeatBlock : public IControl
{
    class Ramp
    {
    public:
        Ramp();

        void set(double targetTemperature, double rate);
        inline void clear() { _rate = 0.0; }
        inline bool isEmpty() const { return _rate == 0.0; }

        double computeTemperature(double currentTargetTemperature);

    private:
        double _targetTemperature;
        double _rate;
        boost::chrono::high_resolution_clock::time_point _lastChangesTime;
    };

public:
    HeatBlock(HeatBlockZoneController* zone1, HeatBlockZoneController* zone2, double beginStepTemperatureThreshold, double maxRampSpeed);
	~HeatBlock();
	
    void process();

    void setEnableMode(bool enableMode);
    void enableStepProcessing();

    void setTargetTemperature(double targetTemperature, double rampRate = 0);
    void calculateTargetTemperature();
    double zone1Temperature() const;
    double zone2Temperature() const;

    double maxTemperatureSetpointDelta () const;

    void setDrive(double drive);
    double zone1DriveValue() const;
    double zone2DriveValue() const;

    boost::signals2::signal<void()> stepBegun;

private:
    std::pair<HeatBlockZoneController*, HeatBlockZoneController*> _zones;

    double _beginStepTemperatureThreshold;
    double _maxRampSpeed;

    bool _stepProcessingState;
    std::mutex _stepProcessingMutex;

    HeatBlock::Ramp _ramp;
};

#endif
