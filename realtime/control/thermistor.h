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
	void setResistance(double resistanceOhms);

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
        double beta);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _beta; //beta coefficients
};

class TemperatureControl {
public:
    TemperatureControl(unsigned int voltageDividerResistance, unsigned int adcBits,
                       double a, double b, double c, double d)
    {
        _thermistor = std::make_shared<SteinhartHartThermistor>(voltageDividerResistance, adcBits, a, b, c, d);

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
