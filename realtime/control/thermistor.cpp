#include "pcrincludes.h"

#include "thermistor.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Thermistor
Thermistor::Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double a, double b, double c, double d) :
    _temperature {0},
    _a {a},
    _b {b},
    _c {c},
    _d {d},
    _maxADCValue ((1 << adcBits) - 1),
    _voltageDividerResistance {voltageDividerResistance} {
}

Thermistor::~Thermistor() {
}

void Thermistor::setADCValue(unsigned int adcValue) {
    double voltage = (double)adcValue / _maxADCValue * 5.0;
    double resistance = (_voltageDividerResistance * voltage / 3.3) / (1 - (voltage / 3.3));
    cout << "max = " << _maxADCValue << ", adc = " << adcValue << ", volt = " << voltage << ", res = " << resistance << endl;
    //double resistance = static_cast<double>(adcValue * _voltageDividerResistance) / (_maxADCValue - adcValue);
    setResistance(resistance);
}

void Thermistor::setResistance(double resistanceOhms) {	
	double lnRes = log(resistanceOhms);
	double lnRes2 = lnRes * lnRes;
	double lnRes3 = lnRes2 * lnRes;
	
	//steinhart-hart equation
    double degreesK = 1 / (_a + _b*lnRes + _c*lnRes2 + _d*lnRes3);
    _temperature.store(degreesK - 273.15);
}

