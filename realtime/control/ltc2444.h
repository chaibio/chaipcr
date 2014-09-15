#ifndef _LTC2444_H_
#define _LTC2444_H_

#include "spi.h"
#include "gpio.h"

// Class LTC2444
class LTC2444  // will work with this class later
{
public:
    LTC2444(unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber);
	~LTC2444();

    typedef enum {
        kOversamplingRatio64 = 1,
        kOversamplingRatio128,
        kOversamplingRatio256,
        kOversamplingRatio512,
        kOversamplingRatio1024,
        kOversamplingRatio2048,
        kOversamplingRatio4096,
        kOversamplingRatio8192,
        kOversamplingRatio16384,
        kOversamplingRatio32768
    } OversamplingRatio;

    uint32_t readSingleEndedChannel(uint8_t channel, OversamplingRatio oversamplingRate);
    uint32_t readDifferentialChannels(uint8_t lowerChannel, bool lowerChannelPositive, OversamplingRatio oversamplingRate);

    uint32_t readADC(uint8_t ch, bool SGL, bool lowerChannelPositive, OversamplingRatio oversamplingRate);

	bool busy();
    bool waitBusy();
    void stopWaitinigBusy();

private:
	GPIO csPin_;
    SPIPort spiPort_;
	GPIO busyPin_;
	uint8_t OSRTWOx;
};




#endif
