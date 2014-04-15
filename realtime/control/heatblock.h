#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

#include "icontrol.h"
#include "pwm.h"

//class Thermistor;
//class HeatBlockZoneController;

class HeatBlockZoneControllerOutput : public PWMControl
{
protected:
    HeatBlockZoneControllerOutput(const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin);

    void setValue(double pidResult);
    void process(double pidResult);

private:
    GPIO _heatIO;
    GPIO _coolIO;
};

template <class Output = HeatBlockZoneControllerOutput>
class TemperatureController;
typedef TemperatureController<HeatBlockZoneControllerOutput> HeatBlockZoneController;

// Class HeatBlock
class HeatBlock : public IControl
{
public:
    HeatBlock(HeatBlockZoneController* zone1, HeatBlockZoneController* zone2);
	~HeatBlock();
	
    void process();

    void setTargetTemperature(double targetTemperature);
    double zone1Temperature() const;
    double zone2Temperature() const;

    std::shared_ptr<Thermistor> zone1Thermistor() const;
    std::shared_ptr<Thermistor> zone2Thermistor() const;
	
private:
    std::pair<HeatBlockZoneController*, HeatBlockZoneController*> _zones;
};

#endif
