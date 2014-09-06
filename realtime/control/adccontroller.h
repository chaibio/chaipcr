#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "icontrol.h"

#include "spi.h"
#include "adcpin.h"

#include <vector>
#include <memory>
#include <atomic>

class LTC2444;
class ADCConsumer;

namespace Poco { class Timer; }

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

    ADCController(std::vector<std::shared_ptr<ADCConsumer>> zoneConsumers, std::shared_ptr<ADCConsumer> liaConsumer, std::shared_ptr<ADCConsumer> lidConsumer, std::shared_ptr<ADCConsumer> heatSinkConsumer,
                  unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber, const ADCPin &adcPin);
	~ADCController();
	
    void process();
    void stop();

private:
    ADCState nextState() const;

    void readADCPin(Poco::Timer &timer);
	
private:
    std::atomic<bool> _workState;

    LTC2444 *_ltc2444;
    ADCState _currentConversionState;
    uint32_t _differentialValue;

    std::vector<std::shared_ptr<ADCConsumer>> _zoneConsumers;
    std::shared_ptr<ADCConsumer> _liaConsumer;
    std::shared_ptr<ADCConsumer> _lidConsumer;
    std::shared_ptr<ADCConsumer> _heatSinkConsumer;

    ADCPin _adcPin;
    Poco::Timer *_heatSinkTimer;
};

#endif
