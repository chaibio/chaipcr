#include "pcrincludes.h"
#include "ltc2444.h"

#include "pins.h"
#include <iostream>

////////////////////////////////////////////////////////////////////////////////
// Class LTC2444
LTC2444::LTC2444(unsigned int csPinNumber, SPIPort& spiPort) throw():
	 csPin_(csPinNumber, GPIOPin::kOutput),
	 spiPort_ (spiPort){}

LTC2444::~LTC2444() {
}

uint32_t LTC2444::readADC(uint8_t ch, bool SGL) {
	//0xA000000 the first 3 bits here represents 101, based on the datasheet.
	uint32_t data=0xA0000000,tmp=ch;
	if (SGL){
		//SGL=1 , ODD = ch&0x01, A2A1A0=(ch&0x0110>1)
		data |= 1<<28 |(tmp&0x01)<<27  |(tmp&0x110)<<23;
		std::cout << "Reading Single ended channel:" << ch<<std::endl;
	}
	else{
		data |= (tmp&0x01)<<27  |(tmp&0x110)<<23;
		std::cout << "Reading differential channel:" << ch<<std::endl;
	}
	data |= OSRTWOx<<19;
	
	//set CS low to initiate conversion
	csPin_.setValue(GPIOPin::kHigh);
	csPin_.setValue(GPIOPin::kLow);

	//read conversion value and write the settings for the nex conversion via SPI.
	uint32_t conversion;
	//convert data to big endian
	data = (data & 0xFF000000) >> 24 | (data & 0x00FF0000) >> 8 | (data & 0x0000FF00)<<8 | (data & 0x000000FF) << 24;
	spiPort_.readBytes((char*)&conversion, (char*)&data, 4, 1000000);
	
	// convert to little endian and get only ADC result (bit28 down to bit 5)
	conversion = ((conversion & 0xFF000000) >> 24 | (conversion & 0x00FF0000) >> 8 | (conversion & 0x0000FF00)<<8 | (conversion & 0x000000FF) << 24)&0x3FFFFFE0;
	
	std::cout << "Read ADC value: " << conversion << std::endl;
	csPin_.setValue(GPIOPin::kHigh);
	return conversion;

}
