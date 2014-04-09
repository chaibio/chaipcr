#include "pcrincludes.h"
#include "utilincludes.h"
#include "qpcrfactory.h"

#include "controlincludes.h"
#include "heatblock.h"
#include "heatblockzone.h"

using namespace std;

// Class QPCRFactory
void QPCRFactory::constructMachine(std::vector<std::shared_ptr<IControl>>& controlUnits) {
    //construct SPI devices
    SPIPort spiPort0 = SPIPort(kSPI0DevicePath);
    SPIPort spiPort1 = SPIPort(kSPI1DevicePath);

    //construct optics
    //TODO: not yet refactored
    controlUnits.push_back(static_pointer_cast<IControl>(OpticsInstance::createInstance(spiPort1)));

    //construct heat block
    //zone controllers
    HeatBlockZoneController* zone1 = new HeatBlockZoneController(kHeatBlockZone1PWMPath, kHeatBlockZone1PWMPeriod, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin);
    HeatBlockZoneController* zone2 = new HeatBlockZoneController(kHeatBlockZone2PWMPath, kHeatBlockZone2PWMPeriod, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin);
    //heat block
    auto heatBlock = HeatBlockInstance::createInstance(zone1, zone2);
    controlUnits.push_back(static_pointer_cast<IControl>(heatBlock));

    //ADC Controller
    vector<shared_ptr<ADCConsumer>> consumers = {nullptr, heatBlock->zone1Thermistor(), heatBlock->zone2Thermistor(), nullptr};
    controlUnits.push_back(static_pointer_cast<IControl>(ADCControllerInstance::createInstance(consumers,
                                                                    kLTC2444CSPinNumber, std::move(spiPort0), kSPI0DataInSensePinNumber
                                                                    )));
}

