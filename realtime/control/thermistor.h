#ifndef _THERMISTOR_H_
#define _THERMISTOR_H_

#include "adccontroller.h"

// Class Thermistor
class Thermistor: public ADCConsumer {
public:
	Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double a, double b, double c, double d);
	virtual ~Thermistor();
	
	//accessors
    inline double temperature() const { return _temperature; }

    //ADCConsumer
    void setADCValue(unsigned int adcValue) override;
	
private:
	void setResistance(double resistanceOhms);
	
private:
    std::atomic<double> _temperature;

    const double _a, _b, _c, _d; //steinhart-hart coefficients
    const unsigned int _maxADCValue;
    const unsigned int _voltageDividerResistance;
};

#endif
