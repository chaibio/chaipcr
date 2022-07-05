/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef _CONSTANTS_H_
#define _CONSTANTS_H_

#include <vector>
#include <string>

//Steinhart-Hart coefficients
const double kUSSensorJThermistorC0Coefficient = 0.00112502978660426;
const double kUSSensorJThermistorC1Coefficient = 0.000235057162160341;
const double kUSSensorJThermistorC3Coefficient = 0.0000000785661432368816;
const double kUSSensorJThermistorC5Coefficient = 0.0000000000395309964792414;

//Steinhart-Hart coefficients (new equation)
const double kUSSensorJThermistorACoefficient = 0.001129138;
const double kUSSensorJThermistorBCoefficient = 0.000234126;
const double kUSSensorJThermistorCCoefficient = 0.0000000876656;

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

const double kLidLowTempShutdownThreshold = -2;
const double kLidHighTempShutdownThreshold = 140;

const double kProgramStartLidTempThreshold = 2;

const double kLidCompletionTurnOffTemp = 25.0;

//PID
const int kPIDDerivativeGainLimiter = 12;

//ADC
const int kADCRepeatFrequency = 80; // Hz
const int kADCSPIFrequencyHz = 10000000; //10 MHz

const std::vector<uint8_t> kADCOpticsChannels = { 6, 5 };

const std::string kADCDebugReaderSamplesPath = "/tmp/data_logger.csv";

//thermistor & ADC params
const unsigned int kLidThermistorVoltageDividerResistanceOhms = 33000;
const int kLTC2444ADCBits = 24;
const long kHeatSinkADCInterval = 5 * 1000;

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

const double kHeatBlockLowTempShutdownThreshold = -5;
const double kHeatBlockHighTempShutdownThreshold = 120;

const double kMaxHeatBlockRampSpeed = 5.0;
const double kDurationCalcHeatBlockRampSpeed = kMaxHeatBlockRampSpeed;

//LED constants
const int kMinLEDCurrent = 8; //mA
const int kDefaultLEDCurrent = 60; //mA
const int kMaxInstantaneousLEDCurrent = 100;
const int kMaxAverageLEDCurrent = 30;

const int kLedBlankPwmPeriodNs = 1000000;
const int kLedBlankPwmDutyNs = 500000;

//Optics
const long kFluorescenceDataCollectionDelayTimeMs = 80;
const int kADCReadsPerOpticalMeasurement = 10;
const int kWellCount = 16;
const int kOpticalMeasurementsPerCycle = 1;
const int kOpticalMeasurementsPerCalibrationCycle = 5;
const int kBaselineMeasurementsPerCycle = 1;
const int kOpticalMeasurementsBufferTimeMs = 250;
const int kOpticalMeasurementDurationMs = kFluorescenceDataCollectionDelayTimeMs + 12 * kADCReadsPerOpticalMeasurement; //The magical number is X
const int kOpticalFluorescenceMeasurmentPeriodMs = (kOpticalMeasurementsPerCycle + kBaselineMeasurementsPerCycle) * kOpticalMeasurementDurationMs * 16 + kOpticalMeasurementsBufferTimeMs;
const int kOpticalRejectedOutlierMeasurements = 3;
const int kADCReadsPerOpticalMeasurementFinal = kADCReadsPerOpticalMeasurement - kOpticalRejectedOutlierMeasurements;

//LED
const int kLEDPotMinResistance = 75;
const int kLEDPotMaxResistance = 5000 + kLEDPotMinResistance;
const uint32_t kLEDSpiSpeed_Hz = 1000000;  //the actual freq is 750 KHz (possible bug in the kernel driver)
const uint8_t kLEDFineIntensityMax = 0x3F; //6-bit value
const std::vector<int> kWellToLedMappingList = {3, 2, 1, 0, 15, 14, 13, 12, 4, 5, 6, 7, 8, 9, 10, 11};

//Steps
const double kPCRBeginStepTemperatureThreshold = 0.5;

//Experiment Controller
const long kTemperatureLoggerInterval = 1000;
const long kTemperatureLoggerFlushInterval = 1000; //ms

const long kDataSpaceCheckInterval = 60 * 1000;

//Heat Sink
const double kHeatSinkTargetTemperature = 40; //C
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
const std::string kStartupFlagFilePath = "/run/startup_complete.flag";
const std::string kAppLogName = "QPCRApplication";

const std::string kDeviceFilePath = "/perm/device.json";
const std::string kConfigurationFilePath = "/root/configuration.json";

const std::string kDataPartitionpath = "/data";

const long kAppSignalInterval = 50 * 1000 * 1000; //Nanosec

//Http updage client

//Updater
const long kUpdateStartDelay = 15 * 60 * 1000;
const long kUpdateInterval = 4 * 60 * 60 * 1000;

const std::string kUpdateHost = "update.chaibio.com";
const std::string kUpdatesUrl = "http://update.chaibio.com/device/software_update";
const std::string kUpdateFilePath = "/sdcard/upgrade/upgrade.img.tar";
const std::string kUpdateFolder = "/sdcard/upgrade";
const std::string kUpdateScriptPath = "/sdcard/upgrade/scripts/perform_upgrade.sh";
const std::string kUpdateScriptOutputPath = "/root/chaipcr/perform_upgrade_output.txt";

const std::string kUpdateMountPoint = "/sdcard/upgrade";
const std::string kCheckSdcardPath = "/root/chaipcr/deploy/device/check_sdcard.sh";

const int kUpdateMoundPointError = 10000;
const int kUpdateSdcardError = 10001;
const int kUpdateDownloadError = 10002;

//Network settings
const std::string kNetworkInterfacesFile = "/etc/network/interfaces";
static const std::string kNetworkDriverName = "8192cu";
static const std::string kNetworkDriverPath = "/lib/modules/4.9.78-ti-chai-r94/updates/dkms/" + kNetworkDriverName + ".ko";

struct WifiDriver
{
    const char* pszNetworkDriverName;
    const char* pszNetworkDriverPath;
    const bool bSupportsIfup;
    const char* pszUSBID[5];
};

static const WifiDriver wifiDrivers[] = {

    // Edimax ew-7811Un
    // Bus 001 Device 003: ID 0bda:8176 Realtek Semiconductor Corp. RTL8188CUS 802.11n WLAN Adapter
    // Bus 001 Device 002: ID 7392:7811 Edimax Technology Co., Ltd EW-7811Un 802.11n Wireless Adapter [Realtek RTL8188CUS]
    { "8192cu", "/lib/modules/4.9.78-ti-chai-r94/updates/dkms/8192cu.ko", true, {"0bda:8176", "7392:7811", "RTL8188CUS", nullptr} },        // this may drop compatibles
    
    // Cudy AC600 https://www.cudytech.com/wu600_software_download
    // Bus 001 Device 002: ID 0bda:1a2b Realtek Semiconductor Corp. << Mas storage
    // Bus 001 Device 003: ID 0bda:c811 Realtek Semiconductor Corp. << switching to this one
    { "8821cu", "/lib/modules/4.9.78-ti-chai-r94/kernel/drivers/net/wireless/8821cu.ko", false, {"0bda:c811", nullptr} },

    // Cudy AC1300 https://www.cudytech.com/wu1300_software_download
    // Bus 001 Device 003: ID 0bda:b812 Realtek Semiconductor Corp.
    { "88x2bu", "/lib/modules/4.9.78-ti-chai-r94/kernel/drivers/net/wireless/88x2bu.ko", false, {"0bda:b812", "2357:012d", "2001:331c", nullptr} },

    { nullptr, nullptr, false, { nullptr} }
};

//Time checker
const std::string kSavedTimePath = "/data/chaipcr_saved_time";

#endif
