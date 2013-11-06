#ifndef _SPI_H_
#define _SPI_H_

////////////////////////////////////////////////////////////////////////////////
// Class SPIPort
class SPIPort {
public:
	SPIPort(const char* spiDevice);
	~SPIPort();
	
	chaistatus_t init();
	
private:
	const char* iSPIDevice;
	
};

#endif