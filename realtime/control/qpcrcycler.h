#ifndef _QPCRCYCLER_H_
#define _QPCRCYCLER_H_

#include <Poco/Runnable.h>

#include "spi.h"
#include "gpio.h"

class ADCController;
class HeatBlock;
class HeatSink;
class Optics;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRCycler
class QPCRCycler: public Poco::Runnable {
public:
	QPCRCycler();
	virtual ~QPCRCycler();
	static QPCRCycler* instance();
	
	//port accessors
	inline SPIPort& spiPort0() { return spiPort0_; };
	inline GPIO& spiPort0DataInSensePin() { return spiPort0DataInSensePin_; }
	
	//component accessors
	Optics& optics() { return *optics_; }
	
	//execution
	void init();
	virtual void run();
	
private:
	//ports
	SPIPort spiPort0_;
	GPIO spiPort0DataInSensePin_;
	
	//components
	static QPCRCycler* qpcrCycler_;
	ADCController* adcController_;
	HeatBlock* heatBlock_;
	HeatSink* heatSink_;
	Optics* optics_;
};

#endif
