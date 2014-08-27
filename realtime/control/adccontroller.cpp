#include "ltc2444.h"
#include "adcconsumer.h"
#include "adccontroller.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class ADCController
ADCController::ADCController(std::vector<std::shared_ptr<ADCConsumer>> zoneConsumers, std::shared_ptr<ADCConsumer> liaConsumer, std::shared_ptr<ADCConsumer> lidConsumer,
                             unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber):
    _currentConversionState {EReadZone1Differential},
    _zoneConsumers {zoneConsumers},
    _liaConsumer {liaConsumer},
    _lidConsumer {lidConsumer} {
    _workState = false;

    _ltc2444 = new LTC2444(csPinNumber, std::move(spiPort), busyPinNumber);
    _ltc2444->setup(0x4, false);

    //start first read
    _ltc2444->readSingleEndedChannel(0);
}

ADCController::~ADCController() {
    stop();
    join();

    delete _ltc2444;
}

void ADCController::process() {
    _workState = true;
    while (_workState) {
        //if (_ltc2444->waitBusy())
        //    continue;

        if (_ltc2444->busy())
           continue;

        uint32_t value;
        /*switch (nextState()) {
        case EReadZone1Differential:
            value = _ltc2444->readDifferentialChannels(0, true);
            break;
        case EReadZone1Singular:
            value = _ltc2444->readSingleEndedChannel(4);
            break;
        case EReadZone2Differential:
            value = _ltc2444->readDifferentialChannels(2, true);
            break;
        case EReadZone2Singular:
            value = _ltc2444->readSingleEndedChannel(5);
            break;
        case EReadLIA:
            value = _ltc2444->readSingleEndedChannel(6);
            break;
        case EReadLid:*/
            value = _ltc2444->readSingleEndedChannel(7);
            /*break;
        default:
            assert(false);
        }*/

     /*   switch (_currentConversionState) {
        case EReadZone1Differential:
        case EReadZone2Differential:
            _differentialValue = value;
            break;
        case EReadZone1Singular:
            _zoneConsumers.at(0)->setADCValues(_differentialValue, value);
            break;
        case EReadZone2Singular:
            _zoneConsumers.at(1)->setADCValues(_differentialValue, value);
            break;
        case EReadLIA:
            _liaConsumer->setADCValues(value);
            break;
        case EReadLid:*/
            _lidConsumer->setADCValues(value);
            /*break;
        default:
            assert(false);
        }*/

        _currentConversionState = nextState();
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
