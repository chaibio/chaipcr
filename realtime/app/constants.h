#ifndef _CONSTANTS_H_
#define _CONSTANTS_H_

//Steinhart-Hart coefficients for heat block thermistor (QTI Z Curve)
const double kQTICurveZThermistorACoefficient = 0.001116401465500;
const double kQTICurveZThermistorBCoefficient = 0.000237982973213;
const double kQTICurveZThermistorCCoefficient = -0.000000372283234;
const double kQTICurveZThermistorDCoefficient = 0.000000099063233;

//Lid
const double kLidThermistorBetaCoefficient = 3970;  //kelvins
const double kLidThermistorT0Resistance = 10000;    //ohms
const double kLidThermistorT0 = 298.15;             //kelvins

const double kLidMinTargetTemp = 0;
const double kLidMaxTargetTemp = 130;

//thermistor & ADC params
const unsigned int kThermistorVoltageDividerResistanceOhms = 14000;
const int kLTC2444ADCBits = 24;

//HTTP server params
const int kHttpServerPort = 8000;

//Fan PWM params
const unsigned long kFanPWMPeriodNs = 1024;

//Lid PWM params
const unsigned long kLidPWMPeriodNs = 500000;

//Heat Block params
const unsigned long kHeatBlockZone1PWMPeriod = kFanPWMPeriodNs;
const unsigned long kHeatBlockZone2PWMPeriod = kFanPWMPeriodNs;

const int kHeatBlockZonesPIDMin = -1024;
const int kHeatBlockZonesPIDMax = 1024;

const double kHeatBlockZonesMinTargetTemp = -10;
const double kHeatBlockZonesMaxTargetTemp = 105;

const long kPIDInterval = 100;

//LED constants
const int kMinLEDCurrent = 5; //5mA
const int kGrayscaleClockPwmPeriodNs = 240;
const int kGrayscaleClockPwmDutyNs = 120;
const int kLedBlankPwmPeriodNs = 983090;
const int kLedBlankPwmDutyNs = 50;

//Optics
const long kCollectDataInterval = 150;
const std::vector<int> kWellList = {5, 8, 7, 6, 11, 10, 9, 12, 4, 3, 2, 1, 16, 15, 14, 13};

#endif
