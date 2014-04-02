#ifndef _THERMISTOR_H_
#define _THERMISTOR_H_

#include "adcconsumer.h"

// Class Thermistor
class Thermistor: public ADCConsumer {
public:
	Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double a, double b, double c, double d);
	virtual ~Thermistor();
	
	//accessors
    inline double temperature() const { return _temperature; }

    //ADCConsumer
    void setADCValue(unsigned int adcValue);
	
private:
	void setResistance(double resistanceOhms);

    std::atomic<double> _temperature;

    const double _a, _b, _c, _d; //steinhart-hart coefficients
    const unsigned int _maxADCValue;
    const unsigned int _voltageDividerResistance;
};

class TemperatureControl {
public:
    TemperatureControl(unsigned int voltageDividerResistance, unsigned int adcBits,
                       double a, double b, double c, double d)
    {
        _thermistor = std::make_shared<Thermistor>(voltageDividerResistance, adcBits, a, b, c, d);

        setTargetTemperature(0);
    }

    virtual ~TemperatureControl() {}

    inline double targetTemperature() const { return _targetTemperature.load(); }
    inline void setTargetTemperature(double temperature) { _targetTemperature.store(temperature); }

    inline double currentTemperature() const { return _thermistor->temperature(); }

protected:
    std::shared_ptr<Thermistor> _thermistor;
    std::atomic<double> _targetTemperature;
};

#endif
