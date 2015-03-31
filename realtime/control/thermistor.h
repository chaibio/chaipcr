#ifndef _THERMISTOR_H_
#define _THERMISTOR_H_

#include "adcconsumer.h"
#include "lockfreesignal.h"

#include <atomic>

// Class Thermistor
class Thermistor: public ADCConsumer {
public:
    Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits);
    virtual ~Thermistor() {}
	
	//accessors
    inline double temperature() const { return _temperature; }
    boost::signals2::lockfree_signal<void(double)> temperatureChanged;

    //ADCConsumer
    void setADCValue(unsigned int adcValue);
    void setADCValues(unsigned int differentialADCValue, unsigned int singularADCValue);
    void setADCValueMock(double adcValue);

protected:
    virtual double temperatureForResistance(double resistanceOhms) = 0;
	
private:
    std::atomic<double> _temperature;

    const unsigned int _maxADCValue;
    const unsigned int _voltageDividerResistance;
};

class SteinhartHartThermistorC0123: public Thermistor {
public:
    SteinhartHartThermistorC0123(unsigned int voltageDividerResistance, unsigned int adcBits,
        double c0, double c1, double c2, double c3);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _c0, _c1, _c2, _c3; //steinhart-hart coefficients
};

class SteinhartHartThermistorC0135: public Thermistor {
public:
    SteinhartHartThermistorC0135(unsigned int voltageDividerResistance, unsigned int adcBits,
        double c0, double c1, double c3, double c5);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _c0, _c1, _c3, _c5; //steinhart-hart coefficients
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

#endif
