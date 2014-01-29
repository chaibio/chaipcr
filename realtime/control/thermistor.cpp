#include "pcrincludes.h"
#include "thermistor.h"

#include <cmath>

////////////////////////////////////////////////////////////////////////////////
// Class Fan
Thermistor::Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
		double a, double b, double c, double d) throw():
	temperature_ {0},
	maxADCValue_ (1 << (adcBits - 1) - 1),
	voltageDividerResistance_ {voltageDividerResistance},
	a_ {a},
	b_ {b},
	c_ {c},
	d_ {d} {
}

Thermistor::~Thermistor() {
}

void Thermistor::setResistance(double resistanceOhms) {	
	double lnRes = log(resistanceOhms);
	double lnRes2 = lnRes * lnRes;
	double lnRes3 = lnRes2 * lnRes;
	
	//steinhart-hart equation
	double degreesK = 1 / (a_ + b_*lnRes + c_*lnRes2 + d_*lnRes3);
	temperature_ = degreesK - 273.15;
}

void Thermistor::setADCValue(unsigned int adcValue) {
	double resistance = static_cast<double>(adcValue * voltageDividerResistance_) / (maxADCValue_ - adcValue);
	setResistance(resistance);
}
