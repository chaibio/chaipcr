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

void Thermistor::setADCValueMock(double adcValue) {
    _temperature.store(adcValue);
    temperatureChanged(adcValue);
}

////////////////////////////////////////////////////////////////////////////////
// Class SteinhartHartThermistor for C0123
SteinhartHartThermistorC0123::SteinhartHartThermistorC0123(unsigned int voltageDividerResistance, unsigned int adcBits,
        double c0, double c1, double c2, double c3):
    Thermistor(voltageDividerResistance, adcBits),
    _c0 {c0},
    _c1 {c1},
    _c2 {c2},
    _c3 {c3} {
}

double SteinhartHartThermistorC0123::temperatureForResistance(double resistanceOhms) {
    double lnRes = log(resistanceOhms);
    double lnRes2 = lnRes * lnRes;
    double lnRes3 = lnRes2 * lnRes;

    //steinhart-hart equation
    double degreesK = 1 / (_c0 + _c1*lnRes + _c2*lnRes2 + _c3*lnRes3);
    return degreesK - 273.15;
}

////////////////////////////////////////////////////////////////////////////////
// Class SteinhartHartThermistor for C0135
SteinhartHartThermistorC0135::SteinhartHartThermistorC0135(unsigned int voltageDividerResistance, unsigned int adcBits,
        double c0, double c1, double c3, double c5):
    Thermistor(voltageDividerResistance, adcBits),
    _c0 {c0},
    _c1 {c1},
    _c3 {c3},
    _c5 {c5} {
}

double SteinhartHartThermistorC0135::temperatureForResistance(double resistanceOhms) {
    double lnRes = log(resistanceOhms);
    double lnRes2 = lnRes * lnRes;
    double lnRes3 = lnRes2 * lnRes;
    double lnRes5 = lnRes2 * lnRes3;

    //steinhart-hart equation
    double degreesK = 1 / (_c0 + _c1*lnRes + _c3*lnRes3 + _c5*lnRes5);
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
