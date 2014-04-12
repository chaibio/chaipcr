#include "pcrincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

#include "qpcrfactory.h"

using namespace std;

const struct SPIDTuning lowTempLidPIDTuning = {50,1.0,0.0,0.0};
const struct SPIDTuning highTempLidPIDTuning = {100,1.0,0.0,0.0};
const vector<SPIDTuning> lidPIDConstants = {lowTempLidPIDTuning,highTempLidPIDTuning};

// Class QPCRFactory
vector<shared_ptr<IControl> > QPCRFactory::constructMachine() {
    vector<shared_ptr<IControl>> controls;
    vector<shared_ptr<ADCConsumer>> consumers;

    //shared_ptr<SPIPort> spiPort0(new SPIPort(kSPI0DevicePath));
    shared_ptr<SPIPort> spiPort1(new SPIPort(kSPI1DevicePath));

    consumers.push_back(nullptr); //Not refactored yet

    controls.push_back(QPCRFactory::constructOptics(spiPort1));
    controls.push_back(QPCRFactory::constructHeatBlock(consumers));

    //Not refactored yet
    auto lid = LidInstance::createInstance(lidPIDConstants);
    controls.push_back(static_pointer_cast<IControl>(lid));

    consumers.push_back(lid->thermistor());
    controls.push_back(static_pointer_cast<IControl>(ADCControllerInstance::createInstance(consumers,
                                                                    kLTC2444CSPinNumber, std::move(SPIPort(kSPI0DevicePath)), kSPI0DataInSensePinNumber
                                                                    )));

    //construct SPI devices
    /*SPIPort spiPort0 = SPIPort(kSPI0DevicePath);
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

    auto lid = LidInstance::createInstance(lidPIDConstants);
    controls.push_back(static_pointer_cast<IControl>(lid));


    //ADC Controller
    vector<shared_ptr<ADCConsumer>> consumers = {nullptr, heatBlock->zone1Thermistor(), heatBlock->zone2Thermistor(), lid->thermistor()};
    controls.push_back(static_pointer_cast<IControl>(ADCControllerInstance::createInstance(consumers,
                                                                    kLTC2444CSPinNumber, std::move(spiPort0), kSPI0DataInSensePinNumber
                                                                    )));*/

    return controls;
}

shared_ptr<IControl> QPCRFactory::constructOptics(shared_ptr<SPIPort> ledSPIPort)
{
    shared_ptr<LEDController> ledControl(new LEDController(kLEDGrayscaleClockPWMPath, ledSPIPort,
                                                           kLEDDigiPotCSPinNumber, kLEDControlXLATPinNumber,
                                                           kLEDBlankPWMPath, 50));

    vector<GPIO> photoDiodeMux;
    photoDiodeMux.emplace_back(kMuxControlPin1, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin2, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin3, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin4, GPIO::kOutput);

    return OpticsInstance::createInstance(kLidSensePinNumber, ledControl, MUX(move(photoDiodeMux)));
}

std::shared_ptr<IControl> QPCRFactory::constructHeatBlock(vector<shared_ptr<ADCConsumer>> &consumers)
{
    shared_ptr<SteinhartHartThermistor> zone1Thermistor(new SteinhartHartThermistor(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                                                    kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                                                    kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient));

    CPIDController *zone1CPIDController = new CPIDController({}, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax);

    HeatBlockZoneController *zone1 = new HeatBlockZoneController(zone1Thermistor, zone1CPIDController, kPIDInterval, kHeatBlockZone1PWMPath,
                                                                 kHeatBlockZone1PWMPeriod, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin);

    shared_ptr<SteinhartHartThermistor> zone2Thermistor(new SteinhartHartThermistor(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                                                    kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                                                    kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient));

    CPIDController *zone2CPIDController = new CPIDController({}, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax);

    HeatBlockZoneController *zone2 = new HeatBlockZoneController(zone2Thermistor, zone2CPIDController, kPIDInterval, kHeatBlockZone2PWMPath,
                                                                 kHeatBlockZone2PWMPeriod, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin);

    consumers.push_back(zone1Thermistor);
    consumers.push_back(zone2Thermistor);

    return HeatBlockInstance::createInstance(zone1, zone2);
}
