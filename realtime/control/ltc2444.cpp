#include "pcrincludes.h"
#include "utilincludes.h"

#include "ltc2444.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class LTC2444
LTC2444::LTC2444(unsigned int csPinNumber, SPIPort& spiPort, unsigned int busyPinNumber) :
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

uint32_t LTC2444::readADC(uint8_t ch, bool SGL) {
	//0xA000000 the first 3 bits here represents 101, based on the datasheet.
    uint32_t data=0xA0000000;
	if (SGL){
		//SGL=1 , ODD = ch&0x01, A2A1A0=(ch&0x0110>1) 0r SGL_ODD_A
		data |= 1<<28 |(ch&0x01)<<27  |(ch&0x110)<<23;
        cout << "Reading Single ended channel:" << ch<< endl;
	}
	else{
		data |= (ch&0x01)<<27  |(ch&0x110)<<23;
        cout << "Reading differential channel:" << ch<< endl;
	}
	//data that will be sent is: 101_SGL_ODD_A_OSRTWOx based ifrom the datasheet Table 4. Channel Selection
	data |= OSRTWOx<<19;
	
	//set CS low to initiate conversion
	csPin_.setValue(GPIO::kHigh);
	csPin_.setValue(GPIO::kLow);

	//read conversion value and write the settings for the nex conversion via SPI.
	uint32_t conversion;
	//convert data to big endian

	data = (data & 0xFF000000) >> 24 | (data & 0x00FF0000) >> 8 | (data & 0x0000FF00)<<8 | (data & 0x000000FF) << 24;
	spiPort_.readBytes((char*)&conversion, (char*)&data, 4, 1000000);
    cout << "Command sent to LTC2444: " << data << endl;
	
	// convert to little endian and get only ADC result (bit28 down to bit 5)
	conversion = ((conversion & 0xFF000000) >> 24 | (conversion & 0x00FF0000) >> 8 | (conversion & 0x0000FF00)<<8 | (conversion & 0x000000FF) << 24)&0x3FFFFFE0;
	
    cout << "Read ADC value: " << conversion << endl;
	csPin_.setValue(GPIO::kHigh);
	return conversion;

}

uint32_t LTC2444::repeat() {
	//0xA000000 the first 3 bits here represents 101, based on the datasheet.
	uint32_t data=0x80000000;

	//set CS low to initiate conversion
	csPin_.setValue(GPIO::kHigh);
	csPin_.setValue(GPIO::kLow);

	//read conversion value and write the settings for the nex conversion via SPI.
	uint32_t conversion;
	//convert data to big endian
	data = (data & 0xFF000000) >> 24 | (data & 0x00FF0000) >> 8 | (data & 0x0000FF00)<<8 | (data & 0x000000FF) << 24;
	spiPort_.readBytes((char*)&conversion, (char*)&data, 4, 1000000);
    cout << "Command sent to LTC2444: " << data << endl;
	// convert to little endian and get only ADC result (bit28 down to bit 5)
	conversion = ((conversion & 0xFF000000) >> 24 | (conversion & 0x00FF0000) >> 8 | (conversion & 0x0000FF00)<<8 | (conversion & 0x000000FF) << 24)&0x3FFFFFE0;

    cout << "Read ADC value: " << conversion << endl;
	csPin_.setValue(GPIO::kHigh);
	return conversion;

}

bool LTC2444::busy(){
	if(busyPin_.value()== GPIO::kHigh)
		return 1;
	else
		return 0;
}
