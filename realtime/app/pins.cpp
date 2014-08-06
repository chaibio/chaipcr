#include <string>

#include "pcrincludes.h"

using namespace std;

//Devices
const string kSPI0DevicePath {"/dev/spidev1.0"};
const string kSPI1DevicePath {"/dev/spidev2.0"};

//Heat Sink
const string kHeatSinkFanControlPWMPath {"/sys/devices/ocp.3/fan_pwm.*"};

//LED control
const std::string kLEDGrayscaleClockPWMPath {"/sys/devices/ocp.3/led_pwm.16"};
const std::string kLEDBlankPWMPath { "/sys/devices/ocp.3/lia_ref_pwm.16" };

//Lid
const std::string kLidControlPWMPath {"/sys/devices/ocp.3/lid_heater_pwm.18"};

//Head Block
const std::string kHeatBlockZone1PWMPath {"/sys/devices/ocp.3/peltier1_pwm.14"};
const std::string kHeatBlockZone2PWMPath {"/sys/devices/ocp.3/peltier2_pwm.15"};
