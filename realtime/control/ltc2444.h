/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
        kOversamplingRatio32768 = 15
    } OversamplingRatio;

    int32_t readSingleEndedChannel(uint8_t channel, OversamplingRatio oversamplingRate, bool &readyFlag);
    int32_t readDifferentialChannels(uint8_t lowerChannel, bool lowerChannelPositive, OversamplingRatio oversamplingRate, bool &readyFlag);

    int32_t readADC(uint8_t ch, bool SGL, bool lowerChannelPositive, OversamplingRatio oversamplingRate, bool &readyFlag);

    bool waitBusy();
    void stopWaitinigBusy();

private:
    GPIO csPin_;
    SPIPort spiPort_;
	GPIO busyPin_;
	uint8_t OSRTWOx;
};

#endif
