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
static const int kMuxControlPin4 = 5;

//ADC
extern const std::string kADCPinPath;
static const unsigned int kADCPinChannel = 5;

#endif
