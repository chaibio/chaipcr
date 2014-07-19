#include "pcrincludes.h"
#include "utilincludes.h"

#include "ltc2444.h"

////////////////////////////////////////////////////////////////////////////////
// Class LTC2444
LTC2444::LTC2444(unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber) :
	 csPin_(csPinNumber, GPIO::kOutput),
	 spiPort_ (spiPort),
	 busyPin_ (busyPinNumber, GPIO::kInput){}

LTC2444::~LTC2444() {
}

void LTC2444::setup(char mode, bool TWOx){
	char x2=0;
	if(TWOx){
		x2=1;
	}
	if (mode>0 && mode <=9){
		//format so to match table 5(Speed/Resolution Selection of LTC2444 datasheet
		//format: OSR3_OSR2_OSR1_OSR0_TWOx
		OSRTWOx =  ((mode&0x0f)<<1) | x2;
	}
	else if (mode==10){
			//format so to match table 5(Speed/Resolution Selection of LTC2444 datasheet
			//format: OSR3_OSR2_OSR1_OSR0_TWOx
			OSRTWOx =  (0x0f<<1) | x2;
	}
}

uint32_t LTC2444::readSingleEndedChannel(uint8_t channel) {
    return readADC(channel, true);
}

uint32_t LTC2444::readDifferentialChannels(uint8_t lowerChannel, bool lowerChannelPositive) {
    return readADC(lowerChannel / 2, false, lowerChannelPositive);
}

uint32_t LTC2444::readADC(uint8_t ch, bool SGL, bool lowerChannelPositive) {
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
	data |= ((uint32_t)OSRTWOx)<<19;
	
	//set CS low to initiate conversion
	csPin_.setValue(GPIO::kHigh);
	csPin_.setValue(GPIO::kLow);

	//read conversion value and write the settings for the nex conversion via SPI.
	uint32_t conversion;
	//convert data to big endian
	dataOut[0] = (data>>24);
	dataOut[1] = (data>>16);
	dataOut[2] = (data>>8);
	dataOut[3] = (data);
	spiPort_.readBytes(dataIn, dataOut, 4, 1000000);
	// convert to little endian and get only ADC result (bit28 down to bit 5)
	//conversion = ((conversion & 0xFF000000) >> 24 | (conversion & 0x00FF0000) >> 8 | (conversion & 0x0000FF00)<<8 | (conversion & 0x000000FF) << 24)&0x1FFFFFE0;
	conversion = ((((uint32_t)dataIn[0])<<24|((uint32_t)dataIn[1])<<16|((uint32_t)dataIn[2])<<8|dataIn[3])&0x1FFFFFE0)>>5;
	csPin_.setValue(GPIO::kHigh);
	return conversion;

}

uint32_t LTC2444::repeat() {
	//0xA000000 the first 3 bits here represents 101, based on the datasheet.
	uint32_t data=0x80000000;
	char dataOut[4];
	char dataIn[4];
	//set CS low to initiate conversion
	csPin_.setValue(GPIO::kHigh);
	csPin_.setValue(GPIO::kLow);

	//read conversion value and write the settings for the nex conversion via SPI.
	uint32_t conversion;
	//convert data to big endian
	dataOut[0] = (data>>24);
	dataOut[1] = (data>>16);
	dataOut[2] = (data>>8);
	dataOut[3] = (data);

	spiPort_.readBytes(dataIn, dataOut, 4, 1000000);

	// convert to little endian and get only ADC result (bit28 down to bit 5)
	//conversion = ((conversion & 0xFF000000) >> 24 | (conversion & 0x00FF0000) >> 8 | (conversion & 0x0000FF00)<<8 | (conversion & 0x000000FF) << 24)&0x1FFFFFE0;
	conversion = ((((uint32_t)dataIn[0])<<24|((uint32_t)dataIn[1])<<16|((uint32_t)dataIn[2])<<8|dataIn[3])&0x1FFFFFE0)>>5;
	std::cout << "Read ADC value: " << conversion << std::endl;
	csPin_.setValue(GPIO::kHigh);
	return conversion;

}

bool LTC2444::busy(){
	if(busyPin_.value()== GPIO::kHigh)
		return 1;
	else
		return 0;
}
