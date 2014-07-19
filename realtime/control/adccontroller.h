#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "icontrol.h"

class LTC2444;
class ADCConsumer;

// Class ADCController
class ADCController : public IControl
{
public:
    enum ADCState {
        EReadZone1Differential = 0,
        EReadZone1Singular,
        EReadZone2Differential,
        EReadZone2Singular,
        EReadLIA,
        EReadLid,
        EFinal
    };

    ADCController(std::vector<std::shared_ptr<ADCConsumer>> zoneConsumers, std::shared_ptr<ADCConsumer> liaConsumer, std::shared_ptr<ADCConsumer> lidConsumer,
                  unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber);
	~ADCController();
	
    void process();

private:
    ADCState nextState() const;
	
private:
    std::shared_ptr<LTC2444> _ltc2444;
    ADCState _currentConversionState;
    uint32_t _differentialValue;

    std::vector<std::shared_ptr<ADCConsumer>> _zoneConsumers;
    std::shared_ptr<ADCConsumer> _liaConsumer;
    std::shared_ptr<ADCConsumer> _lidConsumer;
};

#endif
