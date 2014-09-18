#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

#include "icontrol.h"

#include <atomic>
#include <utility>
#include <boost/date_time/posix_time/ptime.hpp>
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
        inline void clear() { _rate.store(0.0); }
        inline bool isEmpty() const { return _rate.load() == 0.0; }

        double computeTemperature(double currentTargetTemperature);

    private:
        double _targetTemperature;
        std::atomic<double> _rate;
        boost::posix_time::ptime _lastChangesTime;
    };

public:
    HeatBlock(HeatBlockZoneController* zone1, HeatBlockZoneController* zone2, double beginStepTemperatureThreshold);
	~HeatBlock();
	
    void process();
    void setEnableMode(bool enableMode);
    inline void enableStepProcessing() { _stepProcessingState = true; }

    void setTargetTemperature(double targetTemperature, double rampRate = 0);
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
    std::atomic<bool> _stepProcessingState;

    HeatBlock::Ramp ramp;
};

#endif
