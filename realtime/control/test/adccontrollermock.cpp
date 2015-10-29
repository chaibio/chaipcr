#include "adccontrollermock.h"
#include "maincontrollers.h"

const double kLidTempIncrement = 2.0;

ADCControllerMock::ADCControllerMock(ConsumersList &&consumers, unsigned int csPinNumber, SPIPort &&spiPort, unsigned int busyPinNumber):
    ADCController(std::move(consumers), csPinNumber, std::move(spiPort), busyPinNumber) {
}

void ADCControllerMock::process() {
    for (ConsumersList::iterator it = _consumers.begin(); it != _consumers.end(); ++it)
        it->second->setADCValueMock(30);

    _workState = true;
    while (_workState) {
        sleep(1);

        loopStarted();

        processHeatBlock();
        processLid();
        processOptics();

        _currentConversionState = calcNextState();
    }
}

void ADCControllerMock::processHeatBlock() {
    std::shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();

    if (heatBlock) {
        _consumers[EReadZone1Singular]->setADCValueMock(heatBlock->zone1TargetTemperature());
        _consumers[EReadZone2Singular]->setADCValueMock(heatBlock->zone1TargetTemperature());
    }
}

void ADCControllerMock::processLid() {
    std::shared_ptr<Lid> lid = LidInstance::getInstance();

    if (lid) {
        double targetTemp = lid->targetTemperature();
        double temp = lid->currentTemperature();

        if (targetTemp > temp) {
            if ((temp + kLidTempIncrement) > targetTemp)
                _consumers[EReadLid]->setADCValueMock(targetTemp);
            else
                _consumers[EReadLid]->setADCValueMock(temp + kLidTempIncrement);
        }
        else if (targetTemp < temp) {
            if ((temp - kLidTempIncrement) < targetTemp)
                _consumers[EReadLid]->setADCValueMock(targetTemp);
            else
                _consumers[EReadLid]->setADCValueMock(temp - kLidTempIncrement);
        }
    }
}

void ADCControllerMock::processOptics() {

}
