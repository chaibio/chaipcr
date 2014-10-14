#include <cassert>
#include <boost/chrono.hpp>

#include "pcrincludes.h"
#include "ltc2444.h"
#include "adcconsumer.h"
#include "adccontroller.h"
#include "qpcrapplication.h"

using namespace std;

const LTC2444::OversamplingRatio kThermistorOversamplingRate = LTC2444::kOversamplingRatio512;
const LTC2444::OversamplingRatio kLIAOversamplingRate = LTC2444::kOversamplingRatio512;

////////////////////////////////////////////////////////////////////////////////
// Class ADCController
ADCController::ADCController(std::vector<std::shared_ptr<ADCConsumer>> zoneConsumers, std::shared_ptr<ADCConsumer> liaConsumer, std::shared_ptr<ADCConsumer> lidConsumer,
                             unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber):
    _currentConversionState {static_cast<ADCController::ADCState>(0)},
    _zoneConsumers {zoneConsumers},
    _liaConsumer {liaConsumer},
    _lidConsumer {lidConsumer} {
    _workState = false;

    _ltc2444 = new LTC2444(csPinNumber, std::move(spiPort), busyPinNumber);
    _ltc2444->readSingleEndedChannel(4, kThermistorOversamplingRate); //start first read
}

ADCController::~ADCController() {
    stop();

    if (joinable())
        join();

    delete _ltc2444;
}

void ADCController::process() {
    static const boost::chrono::microseconds repeatFrequencyInterval((boost::chrono::microseconds::rep)round(1.0 / kADCRepeatFrequency * 1000 * 1000));
    boost::chrono::high_resolution_clock::time_point repeatFrequencyLastTime;

    setMaxRealtimePriority();

    try {
        _workState = true;
        while (_workState) {
            if (_ltc2444->waitBusy())
                continue;

            ADCState state = nextState();

            //ensure ADC loop runs at regular interval without jitter
            if (state == 0) {
                loopStarted();

                if (repeatFrequencyLastTime.time_since_epoch().count() > 0)
                {
                    boost::chrono::high_resolution_clock::time_point previousTime = repeatFrequencyLastTime;
                    repeatFrequencyLastTime = boost::chrono::high_resolution_clock::now();

                    boost::chrono::microseconds executionTime(boost::chrono::duration_cast<boost::chrono::microseconds>(repeatFrequencyLastTime - previousTime));

                    if (executionTime < repeatFrequencyInterval)
                    {
                        usleep((repeatFrequencyInterval - executionTime).count());

                        repeatFrequencyLastTime = boost::chrono::high_resolution_clock::now();
                    }
                    else
                        std::cout << "ADCController::process - ADC measurements could not be completed in scheduled time\n";
                }
                else
                    repeatFrequencyLastTime = boost::chrono::high_resolution_clock::now();
            }

            //schedule conversion for next state, retrieve previous conversion value
            uint32_t value;
            switch (state) {
            case EReadZone1Singular:
                value = _ltc2444->readSingleEndedChannel(4, kThermistorOversamplingRate);
                break;
            case EReadZone2Singular:
                value = _ltc2444->readSingleEndedChannel(5, kThermistorOversamplingRate);
                break;
            case EReadLIA:
                value = _ltc2444->readSingleEndedChannel(6, kLIAOversamplingRate);
                break;
            case EReadLid:
                value = _ltc2444->readSingleEndedChannel(7, kThermistorOversamplingRate);
                break;
            default:
                assert(false);
            }

            //process previous conversion value
            switch (_currentConversionState) {
            case EReadZone1Singular:
                _zoneConsumers.at(0)->setADCValue(value);
                break;
            case EReadZone2Singular:
                _zoneConsumers.at(1)->setADCValue(value);
                break;
            case EReadLIA:
                _liaConsumer->setADCValue(value);
                break;
            case EReadLid:
                _lidConsumer->setADCValue(value);
                break;
            default:
                assert(false);
            }

            _currentConversionState = state;
        }
    }
    catch (...) {
        qpcrApp.setException(std::current_exception());
    }
}

void ADCController::stop() {
    _workState = false;
    _ltc2444->stopWaitinigBusy();
}

ADCController::ADCState ADCController::nextState() const {
    ADCController::ADCState nextState = static_cast<ADCController::ADCState>(static_cast<int>(_currentConversionState) + 1);
    return nextState == EFinal ? static_cast<ADCController::ADCState>(0) : nextState;
}
