#ifndef _QPCRCYCLER_H_
#define _QPCRCYCLER_H_

class SPIPort;
class HeatBlock;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRCycler
class QPCRCycler {
public:
	QPCRCycler();
	~QPCRCycler();
	static QPCRCycler* instance();
	
	//component accessors
	inline SPIPort* spiPort0() const { return spiPort0_; };
	
	//execution
	bool loop();
	
private:
	//ports
	SPIPort* spiPort0_;
	
	//components
	static QPCRCycler* qpcrCycler_;
	HeatBlock* heatBlock_;
};

#endif
