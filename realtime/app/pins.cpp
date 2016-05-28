//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include <string>

#include "pcrincludes.h"

using namespace std;

//Devices
const string kSPI0DevicePath {"/dev/spidev1.0"};
const string kSPI1DevicePath {"/dev/spidev2.0"};

//Heat Sink
const string kHeatSinkFanControlPWMPath {"/sys/devices/ocp.3/fan_pwm.17"};

//LED control
const std::string kLEDBlankPWMPath {"/sys/devices/ocp.3/lia_ref_pwm.18"};

//Lid
const std::string kLidControlPWMPath {"/sys/devices/ocp.3/lid_heater_pwm.16"};

//Head Block
const std::string kHeatBlockZone1PWMPath {"/sys/devices/ocp.3/peltier1_pwm.14"};
const std::string kHeatBlockZone2PWMPath {"/sys/devices/ocp.3/peltier2_pwm.15"};

//ADC
const std::string kADCPinPath {"/sys/bus/iio/devices/iio:device0"};
