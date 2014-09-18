#ifndef _THERMISTOR_H_
#define _THERMISTOR_H_

#include "adcconsumer.h"

#include <atomic>
#include <boost/signals2.hpp>

// Class Thermistor
class Thermistor: public ADCConsumer {
public:
    Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits, double referenceVoltage);
    virtual ~Thermistor() {}
	
	//accessors
    inline double temperature() const { return _temperature; }
    boost::signals2::signal<void(double)> temperatureChanged;

    //ADCConsumer
    void setADCValue(unsigned int adcValue);
    void setADCValues(unsigned int differentialADCValue, unsigned int singularADCValue);

protected:
    virtual double temperatureForResistance(double resistanceOhms) = 0;
	
private:
    std::atomic<double> _temperature;

    const unsigned int _maxADCValue;
    const unsigned int _voltageDividerResistance;
    const double _referenceVoltage;
};

class SteinhartHartThermistor: public Thermistor {
public:
    SteinhartHartThermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double referenceVoltage, double a, double b, double c, double d);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _a, _b, _c, _d; //steinhart-hart coefficients
};

class BetaThermistor: public Thermistor {
public:
    BetaThermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double referenceVoltage, double beta, double r0, double t0);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _beta; //beta coefficients
    const double _r0;   //resistance at _t0
    const double _t0;   //in kelvins - usually 298.15K
    double _rInfinity;  //calculated from _r0 and _beta
};

#endif
