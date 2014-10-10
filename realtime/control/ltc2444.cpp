#include <iostream>

#include "pcrincludes.h"
#include "ltc2444.h"

////////////////////////////////////////////////////////////////////////////////
// Class LTC2444
LTC2444::LTC2444(SPIPort spiPort, unsigned int busyPinNumber) :
	 spiPort_ (spiPort),
	 busyPin_ (busyPinNumber, GPIO::kInput){}

LTC2444::~LTC2444() {
}

uint32_t LTC2444::readSingleEndedChannel(uint8_t channel, OversamplingRatio oversamplingRate) {
    return readADC(channel, true, false, oversamplingRate);
}

uint32_t LTC2444::readDifferentialChannels(uint8_t lowerChannel, bool lowerChannelPositive, OversamplingRatio oversamplingRate) {
    return readADC(lowerChannel / 2, false, lowerChannelPositive, oversamplingRate);
}

uint32_t LTC2444::readADC(uint8_t ch, bool SGL, bool lowerChannelPositive, OversamplingRatio oversamplingRate) {
    uint32_t modeBits = (uint32_t)oversamplingRate << 1; //OSR3_OSR2_OSR1_OSR0_TWOX; TWOX = 0

	//0xA000000 the first 3 bits here represents 101, based on the datasheet.
    uint32_t data=0xA0000000;

	char dataOut[4];
	char dataIn[4];

    if (SGL)
		//SGL=1 , ODD = ch&0x01, A2A1A0=(ch&0x0110>1) 0r SGL_ODD_A
        data |= ((uint32_t)1) << 28 | ((ch & 0x01)) << 27 | ((uint32_t)(ch & 0b110)) << 23;
    else
        data |= ((uint32_t)!lowerChannelPositive) << 27 | ((uint32_t)(ch & 0b110)) << 23;

	//data that will be sent is: 101_SGL_ODD_A_OSRTWOx based ifrom the datasheet Table 4. Channel Selection
    data |= modeBits << 19;
	
	//read conversion value and write the settings for the nex conversion via SPI.
    uint32_t conversion;
	//convert data to big endian
	dataOut[0] = (data>>24);
	dataOut[1] = (data>>16);
	dataOut[2] = (data>>8);
	dataOut[3] = (data);
    spiPort_.readBytes(dataIn, dataOut, 4, kADCSPIFrequencyHz);

    if ((dataIn[0] >> 4) & 1)
        conversion = 0; //undervoltage
    else
        // convert to little endian and get only ADC result (bit28 down to bit 5)
        conversion = ((((uint32_t)dataIn[0])<<24|((uint32_t)dataIn[1])<<16|((uint32_t)dataIn[2])<<8|dataIn[3])&0x1FFFFFE0)>>5;

    return conversion;
}

bool LTC2444::busy(){
    return busyPin_.value() == GPIO::kHigh;
}

bool LTC2444::waitBusy() {
    return busyPin_.waitValue(GPIO::kLow) == GPIO::kHigh;
}

void LTC2444::stopWaitinigBusy() {
    busyPin_.stopWaitinigValue();
}
