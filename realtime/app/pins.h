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

#ifndef _PINS_H_
#define _PINS_H_

//SPI devices
extern const std::string kSPI0DevicePath;
extern const std::string kSPI1DevicePath;

//LTC2444 Pins
static const int kLTC2444CSPinNumber = 60;
static const int kSPI0DataInSensePinNumber = 20;

//LED GPIO pins
static const int kLEDControlXLATPinNumber = 44;
static const int kLEDControlGSPinNumber = 26;
static const int kLEDDigiPotCSPinNumber = 65;

static const int kLidSensePinNumber = 61;
	
//Heat Sink
extern const std::string kHeatSinkFanControlPWMPath;
static const int kHeatSinkFanTachADCPinNumber = 0;

//LED control
extern const std::string kLEDBlankPWMPath;

//Lid
extern const std::string kLidControlPWMPath;

//Heat Block
extern const std::string kHeatBlockZone1PWMPath;
extern const std::string kHeatBlockZone2PWMPath;

static const unsigned int kHeadBlockZone1HeatPin = 45;
static const unsigned int kHeadBlockZone1CoolPin = 69;

static const unsigned int kHeadBlockZone2HeatPin = 27;
static const unsigned int kHeadBlockZone2CoolPin = 47;

//Photodiode Mux Pins
static const int kMuxControlPin1 = 30;
static const int kMuxControlPin2 = 31;
static const int kMuxControlPin3 = 48;
static const int kMuxControlPin4 = 60;

//ADC
extern const std::string kADCPinPath;
static const unsigned int kHeatSinkThermistorADCPinChannel = 5;

#endif
