#ifndef _THERMISTOR_H_
#define _THERMISTOR_H_

// Class Thermistor
class Thermistor
{
public:
	Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double a, double b, double c, double d);
	virtual ~Thermistor();
	
	//accessors
    inline double temperature() const { return _temperature; }
	
private:
	void setResistance(double resistanceOhms);
	
	//for ADCController
	void setADCValue(unsigned int adcValue);
	
private:
    std::atomic<double> _temperature;

    const double _a, _b, _c, _d; //steinhart-hart coefficients
    const unsigned int _maxADCValue;
    const unsigned int _voltageDividerResistance;
	
//	friend class ADCController;
};

#endif
