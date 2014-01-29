#ifndef _THERMISTOR_H_
#define _THERMISTOR_H_


////////////////////////////////////////////////////////////////////////////////
// Class Thermistor
class Thermistor {
public:
	Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
		double a, double b, double c, double d) throw();
	virtual ~Thermistor();
	
	//accessors
	float temperature() { return temperature_; }
	
private:
	void setResistance(double resistanceOhms);
	
	//for ADCController
	void setADCValue(unsigned int adcValue);
	
private:
	double temperature_;
	const double a_, b_, c_, d_; //steinhart-hart coefficients
	const unsigned int maxADCValue_;
	const unsigned int voltageDividerResistance_;
	
	friend class ADCController;
};

#endif
