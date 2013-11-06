#ifndef _SPI_H_
#define _SPI_H_

////////////////////////////////////////////////////////////////////////////////
// Class CSPIPort
class CSPIPort {
public:
	CSPIPort(const char* SPIDevice);
	~CSPIPort();
	
	PCRSTATUS init();
	
private:
	const char* iSPIDevice;
	
};

#endif