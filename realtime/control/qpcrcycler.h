#ifndef _QPCRCYCLER_H_
#define _QPCRCYCLER_H_

#include "spi.h"
#include "gpiopin.h"

class HeatBlock;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRCycler
class QPCRCycler {
public:
	QPCRCycler();
	~QPCRCycler();
	static QPCRCycler* instance();
	
	//port accessors
	inline SPIPort& spiPort0() { return spiPort0_; };
	inline GPIOPin& spiPort0DataInSensePin() { return spiPort0DataInSensePin_; }
	
	//execution
	void init();
	bool loop();
	
private:
	//ports
	SPIPort spiPort0_;
	GPIOPin spiPort0DataInSensePin_;
	
	//components
	static QPCRCycler* qpcrCycler_;
	HeatBlock* heatBlock_;
};

#endif
