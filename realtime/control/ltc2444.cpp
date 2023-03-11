//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include <iostream>
#include <limits>

#include "pcrincludes.h"
#include "ltc2444.h"
#include "logger.h"

////////////////////////////////////////////////////////////////////////////////
// Class LTC2444
LTC2444::LTC2444(unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber) :
     csPin_(csPinNumber, GPIO::kOutput),
	 spiPort_ (spiPort),
     busyPin_ (busyPinNumber, GPIO::kInput, GPIO::kPoll){}

LTC2444::~LTC2444() {
}

int32_t LTC2444::readSingleEndedChannel(uint8_t channel, OversamplingRatio oversamplingRate, bool &readyFlag) {
    return readADC(channel, true, false, oversamplingRate, readyFlag);
}

int32_t LTC2444::readDifferentialChannels(uint8_t lowerChannel, bool lowerChannelPositive, OversamplingRatio oversamplingRate, bool &readyFlag) {
    return readADC(lowerChannel / 2, false, lowerChannelPositive, oversamplingRate, readyFlag);
}

int32_t LTC2444::readADC(uint8_t ch, bool SGL, bool lowerChannelPositive, OversamplingRatio oversamplingRate, bool &readyFlag) {
    readyFlag = true;

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
    int32_t conversion = 0;
	//convert data to big endian
	dataOut[0] = (data>>24);
	dataOut[1] = (data>>16);
	dataOut[2] = (data>>8);
	dataOut[3] = (data);

    spiPort_.readBytes(dataIn, dataOut, 4, kADCSPIFrequencyHz);

    if (dataIn[0] >> 7) {
        readyFlag = false;
    }
    else if ((dataIn[0] >> 5) & (dataIn[0] >> 4) & 1) {
        //APP_LOGGER << "LTC2444::readADC - overvoltage occured" << std::endl;

        conversion = std::numeric_limits<int32_t>::max();
    }
    else if (!((dataIn[0] >> 5) | (dataIn[0] >> 4) | 0)) {
        //APP_LOGGER << "LTC2444::readADC - undervoltage occured" << std::endl;

        conversion = std::numeric_limits<int32_t>::min();
    }
    else {
        // convert to little endian and get only ADC result (bit28 down to bit 5)
        uint32_t sign_extend=0x00000000;
        if ((dataIn[0]>>4) & 1){ //if MSB of the LTC2444 data is 1, extend the sign
            sign_extend=0xFF000000;
        }
        conversion = sign_extend | (((((uint32_t)dataIn[0])<<24|((uint32_t)dataIn[1])<<16|((uint32_t)dataIn[2])<<8|dataIn[3])&0x1FFFFFE0)>>5);
    }

    return conversion;
}

bool LTC2444::waitBusy() {
    try
    {
        GPIO::Value value = GPIO::kLow;

        if (busyPin_.pollValue(GPIO::kLow, value))
            return value == GPIO::kHigh;
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "LTC2444::waitBusy - exception: " << ex.what() << std::endl;
    }

    return true;
}

void LTC2444::stopWaitinigBusy() {
    busyPin_.cancelPolling();
}
