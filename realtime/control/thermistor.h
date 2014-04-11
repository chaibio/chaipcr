#ifndef _THERMISTOR_H_
#define _THERMISTOR_H_

#include "adcconsumer.h"

// Class Thermistor
class Thermistor: public ADCConsumer {
public:
    Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits);
    virtual ~Thermistor() {}
	
	//accessors
    inline double temperature() const { return _temperature; }

    //ADCConsumer
    void setADCValue(unsigned int adcValue) override;

protected:
    virtual double temperatureForResistance(double resistanceOhms) = 0;
	
private:
    std::atomic<double> _temperature;

    const unsigned int _maxADCValue;
    const unsigned int _voltageDividerResistance;
};

class SteinhartHartThermistor: public Thermistor {
public:
    SteinhartHartThermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double a, double b, double c, double d);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _a, _b, _c, _d; //steinhart-hart coefficients
};

class BetaThermistor: public Thermistor {
public:
    BetaThermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double beta, double r0, double t0);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _beta; //beta coefficients
    const double _r0;   //resistance at _t0
    const double _t0;   //in kelvins - usually 298.15K
    double _rInfinity;  //calculated from _r0 and _beta
};

class TemperatureControl {
public:
    TemperatureControl(std::shared_ptr<Thermistor> thermistor):
        _thermistor {thermistor}
    {
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
