#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "icontrol.h"
#include "spi.h"

class LTC2444;

//Interface ADCConsumer
class ADCConsumer {
public:
    virtual ~ADCConsumer() {}

    ADCConsumer(ADCConsumer const&) = delete;
    ADCConsumer& operator=(ADCConsumer const&) = delete;

    virtual void setADCValue(unsigned int adcValue) = 0;

protected:
    ADCConsumer() {}

};

// Class ADCController
class ADCController : public IControl
{
public:
    ADCController(std::vector<std::shared_ptr<ADCConsumer>> consumers, unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber);
	~ADCController();
	
    void process();
	
private:
    std::shared_ptr<LTC2444> _ltc2444;
    std::vector<std::shared_ptr<ADCConsumer>> _consumers;
    int _currentChannel;
};

#endif
