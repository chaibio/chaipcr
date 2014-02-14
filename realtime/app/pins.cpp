#include "pcrincludes.h"

using namespace std;

//Devices
const string kSPI0DevicePath {"/dev/spidev1.0"};
const string kSPI1DevicePath {"/dev/spidev2.0"};

//Heat Sink
const string kHeatSinkFanControlPWMPath {"/sys/devices/ocp.*/fan_pwm.*"};

//LED control
const std::string kLEDGrayscaleClockPWMPath {"/sys/devices/ocp.3/led_pwm.16"};

//Lid
const std::string kLidControlPWMPath {"I am ugly, change me"};

//Head Block
const std::string kHeatBlockZone1PWMPath {"I am ugly, change me"};
const std::string kHeatBlockZone2PWMPath {"I am ugly, change me"};
