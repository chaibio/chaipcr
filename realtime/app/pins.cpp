#include "pcrincludes.h"

using namespace std;

//Devices
const string kSPI0DevicePath {"/dev/spidev1.0"};
const string kSPI1DevicePath {"/dev/spidev2.0"};

//Heat Sink
const string kHeatSinkFanControlPWMPath {"/sys/devices/ocp.*/fan_pwm.*"};

//LED control
const std::string kLEDGrayscaleClockPWMPath {"/sys/devices/ocp.3/led_pwm.16"};
const std::string kLEDBlankPWMPath { "/sys/devices/ocp.3/blank_pwm.17" };

//Lid
const std::string kLidControlPWMPath {"/sys/devices/ocp.*/lid_heater_pwm.*"};

//Head Block
const std::string kHeatBlockZone1PWMPath {"/sys/devices/ocp.*/peltier1_pwm.*"};
const std::string kHeatBlockZone2PWMPath {"/sys/devices/ocp.*/peltier2_pwm.*"};
