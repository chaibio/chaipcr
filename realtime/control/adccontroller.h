#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "ltc2444.h"

#include <boost/shared_ptr.hpp>

// Class ADCController
class ADCController : public IControl
{
public:
    ADCController(unsigned int csPinNumber, SPIPort& spiPort, unsigned int busyPinNumber);
	~ADCController();
	
    void process();
	
private:
    boost::shared_ptr<LTC2444> _ltc2444;
};

#endif
