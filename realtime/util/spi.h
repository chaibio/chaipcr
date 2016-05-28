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

#ifndef _SPI_H_
#define _SPI_H_

#include <string>

////////////////////////////////////////////////////////////////////////////////
// Class SPIPort
class SPIPort {
public:
    SPIPort(const std::string& spiDevicePath);
    SPIPort(const SPIPort &other);
    SPIPort(SPIPort &&other);
	~SPIPort();

    SPIPort& operator= (const SPIPort &other);
    SPIPort& operator= (SPIPort &&other);
	
    void setMode(uint8_t mode);
    void readBytes(char* rxbuffer, char* txbuffer,unsigned int length, unsigned int speedHz);
	
private:
    std::string spiDevicePath_;
	int deviceFile_;
};

#endif
