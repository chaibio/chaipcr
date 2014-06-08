#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "icontrol.h"

class LTC2444;
class ADCConsumer;

// Class ADCController
class ADCController : public IControl
{
public:
    ADCController(std::vector<std::shared_ptr<ADCConsumer>> consumers, unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber);
	~ADCController();
	
    void process();

    int consumerChannel(const ADCConsumer *consumer) const;
	
private:
    std::shared_ptr<LTC2444> _ltc2444;
    std::vector<std::shared_ptr<ADCConsumer>> _consumers;
    int _currentChannel;
};

#endif
