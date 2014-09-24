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
    double temp = temperatureForResistance((double)_voltageDividerResistance * adcValue / (_maxADCValue - adcValue));

    _temperature.store(temp);
    temperatureChanged(temp);
}

void Thermistor::setADCValues(unsigned int differentialADCValue, unsigned int singularADCValue) {
    double temp = temperatureForResistance(2050 * (double)singularADCValue / differentialADCValue);

    _temperature.store(temp);
    temperatureChanged(temp);
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
BetaThermistor::BetaThermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
                               double beta, double r0, double t0):
    Thermistor(voltageDividerResistance, adcBits),
    _beta {beta},
    _r0 {r0},
    _t0 {t0} {

    _rInfinity=_r0*exp(-_beta/_t0); //calculate _rInfnity

}

double BetaThermistor::temperatureForResistance(double resistanceOhms) {

    return _beta/(log(resistanceOhms/_rInfinity))-273.15;
}
