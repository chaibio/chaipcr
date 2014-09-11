#include "thermistor.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Thermistor
Thermistor::Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits, double referenceVoltage) :
    _temperature {0},
    _maxADCValue ((1 << adcBits) - 1),
    _voltageDividerResistance {voltageDividerResistance},
    _referenceVoltage {referenceVoltage} {
}

void Thermistor::setADCValues(unsigned int firstADCValue, unsigned int secondADCValue) {
    double resistance;

    if (secondADCValue == 0) {
        double voltage = (double)firstADCValue / _maxADCValue * _referenceVoltage;
        resistance = (_voltageDividerResistance * voltage / _referenceVoltage) / (1 - (voltage / _referenceVoltage));
    } else {
        unsigned int singularADCValue = secondADCValue;
        unsigned int differentialADCValue = firstADCValue;
        resistance = 27000 /*400*/ * (double)singularADCValue / differentialADCValue;
    }

    _temperature.store(temperatureForResistance(resistance));

    adcValueChanged();
}


////////////////////////////////////////////////////////////////////////////////
// Class SteinhartHartThermistor
SteinhartHartThermistor::SteinhartHartThermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double referenceVoltage, double a, double b, double c, double d):
    Thermistor(voltageDividerResistance, adcBits, referenceVoltage),
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
                               double referenceVoltage, double beta, double r0, double t0):
    Thermistor(voltageDividerResistance, adcBits, referenceVoltage),
    _beta {beta},
    _r0 {r0},
    _t0 {t0} {

    _rInfinity=_r0*exp(-_beta/_t0); //calculate _rInfnity

}

double BetaThermistor::temperatureForResistance(double resistanceOhms) {

    return _beta/(log(resistanceOhms/_rInfinity))-273.15;
}
