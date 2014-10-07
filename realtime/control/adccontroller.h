#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "icontrol.h"

#include "spi.h"

#include <vector>
#include <memory>
#include <atomic>
#include <boost/signals2.hpp>

class LTC2444;
class ADCConsumer;

// Class ADCController
class ADCController : public IThreadControl
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
    void stop();

    boost::signals2::signal<void()> loopStarted;

private:
    ADCState nextState() const;
	
private:
    std::atomic<bool> _workState;

    LTC2444 *_ltc2444;
    ADCState _currentConversionState;
    uint32_t _differentialValue;

    std::vector<std::shared_ptr<ADCConsumer>> _zoneConsumers;
    std::shared_ptr<ADCConsumer> _liaConsumer;
    std::shared_ptr<ADCConsumer> _lidConsumer;
};

#endif
