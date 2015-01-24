#ifndef _CONSTANTS_H_
#define _CONSTANTS_H_

#include <vector>

//Steinhart-Hart coefficients
const double kUSSensorJThermistorACoefficient = 0.00112502978660426;
const double kUSSensorJThermistorBCoefficient = 0.000235057162160341;
const double kUSSensorJThermistorCCoefficient = 0.0000000785661432368816;
const double kUSSensorJThermistorDCoefficient = 0.0000000000395309964792414;

const double kQTICurveZThermistorACoefficient = 0.001116401465500;
const double kQTICurveZThermistorBCoefficient = 0.000237982973213;
const double kQTICurveZThermistorCCoefficient = -0.000000372283234;
const double kQTICurveZThermistorDCoefficient = 0.000000099063233;

const double kQTICurveDThermistorACoefficient = 0.001119828875495430;
const double kQTICurveDThermistorBCoefficient = 0.0002360897740308300;
const double kQTICurveDThermistorCCoefficient = 0.00000007508299550946710;
const double kQTICurveDThermistorDCoefficient = 0;

//Lid
const unsigned long kLidPIDMin = 0;
const unsigned long kLidPIDMax = 1;
const unsigned long kLidPWMPeriodNs = 500000;

const double kLidThermistorBetaCoefficient = 3970;  //kelvins
const double kLidThermistorT0Resistance = 10000;    //ohms
const double kLidThermistorT0 = 298.15;             //kelvins

const double kLidMinTargetTemp = 0;
const double kLidMaxTargetTemp = 130;

const double kLidLowTempShutdownThreshold = -20;
const double kLidHighTempShutdownThreshold = 140;

const double kProgramStartLidTempThreshold = 2;

//PID
const int kPIDDerivativeGainLimiter = 12;

//ADC
const int kADCRepeatFrequency = 80; // Hz
const int kADCSPIFrequencyHz = 10000000; //10 MHz

//thermistor & ADC params
const unsigned int kLidThermistorVoltageDividerResistanceOhms = 33000;
const int kLTC2444ADCBits = 24;
const long kHeatSinkADCInterval = 1000;

//HTTP server params
const int kHttpServerPort = 8000;

//Fan PWM params
const unsigned long kFanPWMPeriodNs = 500000;

//Heat Block params
const unsigned int kHeatBlockThermistorVoltageDividerResistanceOhms = 43000;
const unsigned long kHeatBlockZone1PWMPeriodNs = 100000;
const unsigned long kHeatBlockZone2PWMPeriodNs = 100000;

const double kHeatBlockZonesPIDMin = -1;
const double kHeatBlockZonesPIDMax = 1;

const double kHeatBlockZonesMinTargetTemp = -10;
const double kHeatBlockZonesMaxTargetTemp = 105;

const double kHeatBlockLowTempShutdownThreshold = -20;
const double kHeatBlockHighTempShutdownThreshold = 120;

const double kMaxHeatBlockRampSpeed = 3.0;

//LED constants
const int kMinLEDCurrent = 5; //mA
const int kDefaultLEDCurrent = 60; //mA

const int kLedBlankPwmPeriodNs = 1000000;
const int kLedBlankPwmDutyNs = 500000;

//Optics
const long kFluorescenceDataCollectionDelayTimeMs = 70;
const int kADCReadsPerOpticalMeasurement = 3;
const std::vector<int> kWellList = {4, 3, 2, 1, 16, 15, 14, 13, 5, 8, 7, 6, 11, 10, 9, 12};

//Steps
const double kPCRBeginStepTemperatureThreshold = 0.5;

//Experiment Controller
const long kTemperatureLoggerInterval = 1000;
const long kTemperatureLoggerFlushInterval = 10000; //ms

//Heat Sink
const double kHeatSinkTargetTemperature = 38; //C
const unsigned int kHeatSinkThermistorVoltageDividerResistanceOhms = 6800;

const double kHeatSinkMinTargetTemp = 0;
const double kHeatSinkMaxTargetTemp = 80;

const double kHeatSinkLowTempShutdownThreshold = -20;
const double kHeatSinkHighTempShutdownThreshold = 90;

const double kHeatSinkPIDMin = -1;
const double kHeatSinkPIDMax = 0;

//beaglebone
const unsigned int kBeagleboneADCBits = 12;

//App
const long kAppSignalInterval = 5 * 1000 * 1000; //Nanosec

#endif
