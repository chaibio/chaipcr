#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "icontrol.h"

// Class ADCController
class ADCController : public IControl
{
public:
    ADCController(unsigned int csPinNumber, SPIPort& spiPort, unsigned int busyPinNumber);
	~ADCController();
	
    void process();
	
private:
    std::shared_ptr<LTC2444> _ltc2444;
};

#endif
