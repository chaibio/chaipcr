#ifndef _QPCRCYCLER_H_
#define _QPCRCYCLER_H_

class SPIPort;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRCycler
class QPCRCycler {
public:
	QPCRCycler();
	~QPCRCycler();
	chaistatus_t init();
	static QPCRCycler* qpcrCycler();
	
	chaistatus_t loop();
	
private:
	//ports
	SPIPort* spiPort0_;
	
	//components
	QPCRCycler* qpcrCycler_;
};

#endif