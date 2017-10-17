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

#ifdef KERNEL_49
/*
	PWM Name 		File System Location 							Header Pin
	EHRPWM2B (pwm1) 	/sys/devices/platform/ocp/48304000.epwmss/48304200.pwm/pwm/pwmchipX	P8.13 (23), P8.46
	EHRPWM2A (pwm0) 	/sys/devices/platform/ocp/48304000.epwmss/48304200.pwm/pwm/pwmchipX	P8.19 (22), P8.45
	EHRPWM1A (pwm0) 	/sys/devices/platform/ocp/48302000.epwmss/48302200.pwm/pwm/pwmchipX 	P8.36, P9.14
	EHRPWM1B (pwm1) 	/sys/devices/platform/ocp/48302000.epwmss/48302200.pwm/pwm/pwmchipX 	P8.34, P9.16
	EHRPWM0A (pwm0) 	/sys/devices/platform/ocp/48300000.epwmss/48300200.pwm/pwm/pwmchipX 	P9.22, P9.31
	EHRPWM0B ) (pwm1) 	/sys/devices/platform/ocp/48300000.epwmss/48300200.pwm/pwm/pwmchipX 	P9.21, P9.29
	ECAPPWM0 	/sys/devices/platform/ocp/48300000.epwmss/48300100.ecap/pwm/pwmchipX (?) 	P9.42
	ECAPPWM2 	/sys/devices/platform/ocp/48304000.epwmss/48304100.ecap/pwm/pwmchipX (?) 	P9.28
*/
	//Heat Sink: P9.14 ehrpwm1a: 
	const string kHeatSinkFanControlPWMPath {"/run/chaipcr/realtime/kHeatSinkFanControl.pwm"};

	//LED control: P9.28 eCAP2_PWM2
	const std::string kLEDBlankPWMPath {"/run/chaipcr/realtime/kLEDBlank.pwm"};

	//Lid: P9.16 ehrpwm1b
	const std::string kLidControlPWMPath {"/run/chaipcr/realtime/kLidControl.pwm"};

	//Head Block: P8.13 ehrpwm2b, P8.19 ehrpwm2a
	const std::string kHeatBlockZone1PWMPath {"/run/chaipcr/realtime/kHeatBlockZone1.pwm"};
	const std::string kHeatBlockZone2PWMPath {"/run/chaipcr/realtime/kHeatBlockZone2.pwm"};
#else
	//Heat Sink
	const string kHeatSinkFanControlPWMPath {"/sys/devices/ocp.3/fan_pwm.17"};

	//LED control
	const std::string kLEDBlankPWMPath {"/sys/devices/ocp.3/lia_ref_pwm.18"};

	//Lid
	const std::string kLidControlPWMPath {"/sys/devices/ocp.3/lid_heater_pwm.16"};

	//Head Block
	const std::string kHeatBlockZone1PWMPath {"/sys/devices/ocp.3/peltier1_pwm.14"};
	const std::string kHeatBlockZone2PWMPath {"/sys/devices/ocp.3/peltier2_pwm.15"};
#endif

//ADC
const std::string kADCPinPath {"/sys/bus/iio/devices/iio:device0"};
