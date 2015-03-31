#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "icontrol.h"
#include "spi.h"
#include "lockfreesignal.h"

#include <vector>
#include <memory>
#include <atomic>
#include <map>

class LTC2444;
class ADCConsumer;

// Class ADCController
class ADCController : public IThreadControl
{
public:
    enum ADCState {
        EReadZone1Singular = 0,
        EReadZone2Singular,
        EReadLIA,
        EReadLid,
        EFinal
    };

    typedef std::map<ADCState, std::shared_ptr<ADCConsumer>> ConsumersList;

    ADCController(ConsumersList &&consumers, unsigned int csPinNumber, SPIPort &&spiPort, unsigned int busyPinNumber);
	~ADCController();
	
    void process();
    void stop();

    boost::signals2::lockfree_signal<void()> loopStarted;

protected:
    ADCState nextState() const;
	
protected:
    std::atomic<bool> _workState;

    LTC2444 *_ltc2444;
    ADCState _currentConversionState;
    uint32_t _differentialValue;

    ConsumersList _consumers;

    std::vector<std::shared_ptr<ADCConsumer>> _zoneConsumers;
    std::shared_ptr<ADCConsumer> _liaConsumer;
    std::shared_ptr<ADCConsumer> _lidConsumer;
};

#endif
