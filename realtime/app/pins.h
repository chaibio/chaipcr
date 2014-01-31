#ifndef _PINS_H_
#define _PINS_H_

#include <string>

//SPI devices
extern const std::string kSPI0DevicePath;
extern const std::string kSPI1DevicePath;

//LTC2444 Pins
static const int kLTC2444CSPinNumber = 60;
static const int kSPI0DataInSensePinNumber = 20;

//GPIO pins
static const int kLEDControlCSPinNumber = 44;
static const int kLEDDigiPotCSPinNumber = 65;

static const int kLidSensePinNumber = 61;
	
//fan
extern const std::string kHeatSinkFanControlPWMPath;
static const int kHeatSinkFanTachADCPinNumber = 0;

//LED control
extern const std::string kLEDGrayscaleClockPWMPath;


#endif
