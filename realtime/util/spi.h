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
