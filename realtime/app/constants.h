#ifndef _CONSTANTS_H_
#define _CONSTANTS_H_

//Steinhart-Hart coefficients for heat block thermistor (QTI Z Curve)
const double kQTICurveZThermistorACoefficient = 0.001116401465500;
const double kQTICurveZThermistorBCoefficient = 0.000237982973213;
const double kQTICurveZThermistorCCoefficient = -0.000000372283234;
const double kQTICurveZThermistorDCoefficient = 0.000000099063233;

//Lid
const unsigned long kLidPIDMin = 0;
const unsigned long kLidPIDMax = 1;
const unsigned long kLidPWMPeriodNs = 500000;

const double kLidThermistorBetaCoefficient = 3970;  //kelvins
const double kLidThermistorT0Resistance = 10000;    //ohms
const double kLidThermistorT0 = 298.15;             //kelvins

const double kLidMinTargetTemp = 0;
const double kLidMaxTargetTemp = 130;

const double kLidPIDThreshold = 100;

const double kProgramStartLidTempThreshold = 2;

//thermistor & ADC params
const unsigned int kHeatBlockThermistorVoltageDividerResistanceOhms = 14000;
const unsigned int kLidThermistorVoltageDividerResistanceOhms = 14000;
const int kLTC2444ADCBits = 24;

//HTTP server params
const int kHttpServerPort = 8000;

//Fan PWM params
const unsigned long kFanPWMPeriodNs = 1024;

//Heat Block params
const unsigned long kHeatBlockZone1PWMPeriodNs = 500000;
const unsigned long kHeatBlockZone2PWMPeriodNs = 500000;

const int kHeatBlockZonesPIDMin = -1;
const int kHeatBlockZonesPIDMax = 1;

const double kHeatBlockZonesMinTargetTemp = -10;
const double kHeatBlockZonesMaxTargetTemp = 105;

const double kHeatBlockZone1PIDThreshold = 500;
const double kHeatBlockZone2PIDThreshold = 500;

const long kPIDIntervalMs = 25;

//LED constants
const int kMinLEDCurrent = 5; //5mA
const int kGrayscaleClockPwmPeriodNs = 240;
const int kGrayscaleClockPwmDutyNs = 120;
const int kLedBlankPwmPeriodNs = 4096 * kGrayscaleClockPwmPeriodNs; //983040
const int kLedBlankPwmDutyNs = 4 * kGrayscaleClockPwmPeriodNs; //960

//Optics
const long kCollectDataInterval = 500;
const std::vector<int> kWellList = {4, 3, 2, 1, 16, 15, 14, 13, 5, 8, 7, 6, 11, 10, 9, 12};

//Steps
const double kPCRBeginStepTemperatureThreshold = 3;

//Experiment Controller
const long kTemperatureLogerInterval = 1000;

//Heat Sink
const double kHeatSinkThermistorBetaCoefficient = 3970;  //kelvins
const double kHeatSinkThermistorT0Resistance = 10000;    //ohms
const double kHeatSinkThermistorT0 = 298.15;             //kelvins

const double kHeatSinkMinTargetTemp = 0;
const double kHeatSinkMaxTargetTemp = 80;

const unsigned long kHeatSinkPIDMin = -1;
const unsigned long kHeatSinkPIDMax = 0;

const double kHeatSinkPIDThreshold = 100;

#endif
