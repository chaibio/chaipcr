#include "pcrincludes.h"

#include "thermistor.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Thermistor
Thermistor::Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits) :
    _temperature {0},
    _maxADCValue ((1 << adcBits) - 1),
    _voltageDividerResistance {voltageDividerResistance} {
}

void Thermistor::setADCValue(unsigned int adcValue) {
    double voltage = (double)adcValue / _maxADCValue * 5.0;
    double resistance = (_voltageDividerResistance * voltage / 3.3) / (1 - (voltage / 3.3));
    _temperature.store(temperatureForResistance(resistance));
}


////////////////////////////////////////////////////////////////////////////////
// Class SteinhartHartThermistor
SteinhartHartThermistor::SteinhartHartThermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double a, double b, double c, double d):
    Thermistor(voltageDividerResistance, adcBits),
    _a {a},
    _b {b},
    _c {c},
    _d {d} {
}

double SteinhartHartThermistor::temperatureForResistance(double resistanceOhms) {
    double lnRes = log(resistanceOhms);
    double lnRes2 = lnRes * lnRes;
    double lnRes3 = lnRes2 * lnRes;

    //steinhart-hart equation
    double degreesK = 1 / (_a + _b*lnRes + _c*lnRes2 + _d*lnRes3);
    return degreesK - 273.15;
}


////////////////////////////////////////////////////////////////////////////////
// Class BetaThermistor
BetaThermistor::BetaThermistor(unsigned int voltageDividerResistance, unsigned int adcBits, double beta):
    Thermistor(voltageDividerResistance, adcBits),
    _beta {beta} {
}

double BetaThermistor::temperatureForResistance(double resistanceOhms) {
    //steven todo
    return 0;
}
