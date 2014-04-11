#include "pcrincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

#include "qpcrfactory.h"

using namespace std;

// Class QPCRFactory
vector<shared_ptr<IControl> > QPCRFactory::constructMachine() {
    vector<shared_ptr<IControl>> controls;

    //shared_ptr<SPIPort> spiPort0(new SPIPort(kSPI0DevicePath));
    shared_ptr<SPIPort> spiPort1(new SPIPort(kSPI1DevicePath));

    controls.push_back(QPCRFactory::constructOptics(spiPort1));

    //construct SPI devices
    SPIPort spiPort0 = SPIPort(kSPI0DevicePath);
    //SPIPort spiPort1 = SPIPort(kSPI1DevicePath);


    //construct optics
    //TODO: not yet refactored
	//test
    //controls.push_back(static_pointer_cast<IControl>(OpticsInstance::createInstance(spiPort1)));

    //construct heat block
    //zone controllers
    HeatBlockZoneController* zone1 = new HeatBlockZoneController(kHeatBlockZone1PWMPath, kHeatBlockZone1PWMPeriod, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin);
    HeatBlockZoneController* zone2 = new HeatBlockZoneController(kHeatBlockZone2PWMPath, kHeatBlockZone2PWMPeriod, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin);
    //heat block
    auto heatBlock = HeatBlockInstance::createInstance(zone1, zone2);
    controls.push_back(static_pointer_cast<IControl>(heatBlock));

    auto lid = LidInstance::createInstance();
    controls.push_back(static_pointer_cast<IControl>(lid));


    //ADC Controller
    vector<shared_ptr<ADCConsumer>> consumers = {nullptr, heatBlock->zone1Thermistor(), heatBlock->zone2Thermistor(), lid->thermistor()};
    controls.push_back(static_pointer_cast<IControl>(ADCControllerInstance::createInstance(consumers,
                                                                    kLTC2444CSPinNumber, std::move(spiPort0), kSPI0DataInSensePinNumber
                                                                    )));

    return controls;
}

shared_ptr<IControl> QPCRFactory::constructOptics(shared_ptr<SPIPort> ledSPIPort)
{
    shared_ptr<LEDController> ledControl(new LEDController(PWMPin(kLEDGrayscaleClockPWMPath),
                                                           ledSPIPort,
                                                           GPIO(kLEDDigiPotCSPinNumber, GPIO::kOutput),
                                                           GPIO(kLEDControlXLATPinNumber, GPIO::kOutput),
                                                           PWMPin(kLEDBlankPWMPath),
                                                           50));

    vector<GPIO> photoDiodeMux;
    photoDiodeMux.emplace_back(kMuxControlPin1, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin2, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin3, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin4, GPIO::kOutput);

    shared_ptr<Optics> optics = OpticsInstance::createInstance(GPIO(kLidSensePinNumber, GPIO::kInput), ledControl, MUX(move(photoDiodeMux)));

    return static_pointer_cast<IControl>(optics);
}
