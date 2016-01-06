#ifndef _CONSTANTS_H_
#define _CONSTANTS_H_

#include <vector>
#include <string>

//Steinhart-Hart coefficients
const double kUSSensorJThermistorC0Coefficient = 0.00112502978660426;
const double kUSSensorJThermistorC1Coefficient = 0.000235057162160341;
const double kUSSensorJThermistorC3Coefficient = 0.0000000785661432368816;
const double kUSSensorJThermistorC5Coefficient = 0.0000000000395309964792414;

const double kQTICurveZThermistorC0Coefficient = 0.001116401465500;
const double kQTICurveZThermistorC1Coefficient = 0.000237982973213;
const double kQTICurveZThermistorC2Coefficient = -0.000000372283234;
const double kQTICurveZThermistorC3Coefficient = 0.000000099063233;

//Lid
const unsigned long kLidPIDMin = 0;
const unsigned long kLidPIDMax = 1;
const unsigned long kLidPWMPeriodNs = 500000;

const double kLidThermistorBetaCoefficient = 3500;  //kelvins
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

const std::vector<uint8_t> kADCOpticsChannels = { 6, 5 };

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
const unsigned long kHeatBlockZone1PWMPeriodNs = 50000;
const unsigned long kHeatBlockZone2PWMPeriodNs = 50000;

const double kHeatBlockZonesPIDMin = -1;
const double kHeatBlockZonesPIDMax = 1;

const double kHeatBlockZonesMinTargetTemp = -10;
const double kHeatBlockZonesMaxTargetTemp = 105;

const double kHeatBlockLowTempShutdownThreshold = -20;
const double kHeatBlockHighTempShutdownThreshold = 120;

const double kMaxHeatBlockRampSpeed = 6.0;
const double kDurationCalcHeatBlockRampSpeed = kMaxHeatBlockRampSpeed;

//LED constants
const int kMinLEDCurrent = 5; //mA
const int kDefaultLEDCurrent = 60; //mA
const int kMaxInstantaneousLEDCurrent = 100;
const int kMaxAverageLEDCurrent = 30;

const int kLedBlankPwmPeriodNs = 1000000;
const int kLedBlankPwmDutyNs = 500000;

//Optics
const long kFluorescenceDataCollectionDelayTimeMs = 70;
const int kADCReadsPerOpticalMeasurement = 3;
const std::vector<int> kWellToLedMappingList = {4, 3, 2, 1, 16, 15, 14, 13, 5, 6, 7, 8, 9, 10, 11, 12};

//Steps
const double kPCRBeginStepTemperatureThreshold = 0.5;

//Experiment Controller
const long kTemperatureLoggerInterval = 1000;
const long kTemperatureLoggerFlushInterval = 1000; //ms

//Heat Sink
const double kHeatSinkTargetTemperature = 50; //C
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
const std::string kDeviceFilePath = "/root/device.json";
const std::string kConfigurationFilePath = "/root/configuration.json";

const long kAppSignalInterval = 50 * 1000 * 1000; //Nanosec

//Http updage client

//Updater
const long kUpdateInterval = 4 * 60 * 60 * 1000;

const std::string kUpdateHost = "update.chaibio.com";
const std::string kUpdatesUrl = "http://update.chaibio.com/device/software_update";
const std::string kUpdateFilePath = "/sdcard/upgrade/upgrade.img.gz";
const std::string kUpdateScriptPath = "/sdcard/factory/perform_upgrade.sh";

const std::string kUpdateMountPoint = "/sdcard/upgrade";
const std::string kCheckSdcardPath = "/root/chaipcr/deploy/device/check_sdcard.sh";

//Network settings
const std::string kNetworkInterfacesFile = "/etc/network/interfaces";

#endif
