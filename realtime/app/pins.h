#ifndef _PINS_H_
#define _PINS_H_

#include <string>

//devices
extern const std::string kSPI0DevicePath;

//GPIO pins
static const int kHeatBlockADCTherm1CSPinNumber = 66;
static const int kSPI0DataInSensePinNumber = 67;
static const int kLidSensePinNumber = 61;
	
//fan
extern const std::string kHeatSinkFanControlPWMPath;
static const int kHeatSinkFanTachADCPinNumber = 0;

#endif
