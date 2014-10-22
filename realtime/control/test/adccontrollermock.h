#ifndef ADCCONTROLLERMOCK_H
#define ADCCONTROLLERMOCK_H

#include "adccontroller.h"

class ADCControllerMock : public ADCController
{
public:
    ADCControllerMock(ConsumersList &&consumers, unsigned int csPinNumber, SPIPort &&spiPort, unsigned int busyPinNumber);

    void process();

private:
    void processHeatBlock();
    void processLid();
    void processOptics();
};

#endif // ADCCONTROLLERMOCK_H
