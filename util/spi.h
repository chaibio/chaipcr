#ifndef _SPI_H_
#define _SPI_H_

////////////////////////////////////////////////////////////////////////////////
// Class SPIPort
class SPIPort {
public:
	SPIPort(const char* spiDevicePath);
	~SPIPort();
	
private:
	const char* spiDevicePath_;
	
};

#endif
