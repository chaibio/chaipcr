#include "pcrincludes.h"

using namespace std;

//devices
const string kSPI0DevicePath {"/dev/spidev1.0"};
const string kSPI1DevicePath {"/dev/spidev1.1"};

//fan
const string kHeatSinkFanControlPWMPath {"/sys/devices/ocp.3/pwm_P9_42.11"};
