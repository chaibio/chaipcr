#include "pcrincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"
#include "qpcrfactory.h"

using namespace std;

// Class QPCRFactory
void QPCRFactory::constructMachine(std::vector<std::shared_ptr<IControl> > &controls, std::vector<std::shared_ptr<IThreadControl> > &threadControls) {
    vector<shared_ptr<ADCConsumer>> zoneConsumers;
    shared_ptr<ADCConsumer> lidADCConsumer, heatSinkADCConsumer;

    //shared_ptr<SPIPort> spiPort0(new SPIPort(kSPI0DevicePath));
    shared_ptr<SPIPort> spiPort1(new SPIPort(kSPI1DevicePath));

    controls.push_back(QPCRFactory::constructOptics(spiPort1));
    controls.push_back(QPCRFactory::constructHeatBlock(zoneConsumers));
    controls.push_back(QPCRFactory::constructLid(lidADCConsumer));
    controls.push_back(QPCRFactory::constructHeatSink(heatSinkADCConsumer));

    threadControls.push_back(ADCControllerInstance::createInstance(zoneConsumers, OpticsInstance::getInstance(), lidADCConsumer, heatSinkADCConsumer, kLTC2444CSPinNumber, std::move(SPIPort(kSPI0DevicePath)), kSPI0DataInSensePinNumber, ADCPin(kADCPinPath, kADCPinChannel))); //Not refactored yet

    shared_ptr<HeatSink> heatSink = HeatSinkInstance::getInstance();
    heatSink->setTargetTemperature(30);
    heatSink->setEnableMode(true);
}

shared_ptr<IControl> QPCRFactory::constructOptics(shared_ptr<SPIPort> ledSPIPort) {
    shared_ptr<LEDController> ledControl(new LEDController(kLEDGrayscaleClockPWMPath, ledSPIPort,
                                                           kLEDDigiPotCSPinNumber, kLEDControlXLATPinNumber,
                                                           kLEDBlankPWMPath, 50));

    vector<GPIO> photoDiodeMux;
    photoDiodeMux.emplace_back(kMuxControlPin1, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin2, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin3, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin4, GPIO::kOutput);

    std::shared_ptr<Optics> optics = OpticsInstance::createInstance(kLidSensePinNumber, ledControl, MUX(move(photoDiodeMux)));

    return optics;
}

shared_ptr<IControl> QPCRFactory::constructHeatBlock(vector<shared_ptr<ADCConsumer>> &consumers) {
    shared_ptr<SteinhartHartThermistor> zone1Thermistor(new SteinhartHartThermistor(0 /* dummy */, kLTC2444ADCBits, kPrecisionADCReferenceVoltage,
                                                                                    kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                                                    kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient));

    std::vector<SPIDTuning> heatBlockPIDSchedule = {{150, 0.15, 8, 0.0}}; //, {100, 0.0, 0.00, 0.0}};
    SinglePoleRecursiveFilter processValueFilter(5);
    PIDController *zone1CPIDController = new PIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax, processValueFilter);

    HeatBlockZoneController *zone1 = new HeatBlockZoneController(zone1Thermistor, kHeatBlockZonesMinTargetTemp, kHeatBlockZonesMaxTargetTemp, zone1CPIDController,
                                                                 kHeatBlockZone1PWMPath, kHeatBlockZone1PWMPeriodNs, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin);

    shared_ptr<SteinhartHartThermistor> zone2Thermistor(new SteinhartHartThermistor(0 /* dummy */, kLTC2444ADCBits, kPrecisionADCReferenceVoltage,
                                                                                    kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                                                    kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient));

    PIDController *zone2CPIDController = new PIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax, processValueFilter);

    HeatBlockZoneController *zone2 = new HeatBlockZoneController(zone2Thermistor, kHeatBlockZonesMinTargetTemp, kHeatBlockZonesMaxTargetTemp, zone2CPIDController,
                                                                 kHeatBlockZone2PWMPath, kHeatBlockZone2PWMPeriodNs, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin);

    consumers.push_back(zone1Thermistor);
    consumers.push_back(zone2Thermistor);

    return HeatBlockInstance::createInstance(zone1, zone2, kPCRBeginStepTemperatureThreshold);
}

shared_ptr<IControl> QPCRFactory::constructLid(shared_ptr<ADCConsumer> &consumer) {
    shared_ptr<BetaThermistor> thermistor(new BetaThermistor(kLidThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits, kPrecisionADCReferenceVoltage,
                                                             kLidThermistorBetaCoefficient, kLidThermistorT0Resistance, kLidThermistorT0));

    SinglePoleRecursiveFilter processValueFilter(5);
    PIDController *pidController = new PIDController({{100, 1.0, 10000, 0}}, kLidPIDMin, kLidPIDMax, processValueFilter);

    consumer = thermistor;

    return LidInstance::createInstance(thermistor, kLidMinTargetTemp, kLidMaxTargetTemp, pidController,
                                       kLidControlPWMPath, kLidPWMPeriodNs, kProgramStartLidTempThreshold);
}

shared_ptr<IControl> QPCRFactory::constructHeatSink(std::shared_ptr<ADCConsumer> &consumer) {
    shared_ptr<BetaThermistor> thermistor(new BetaThermistor(kHeatSinkThermistorVoltageDividerResistanceOhms, kBeagleboneADCBits, kBeagleboneADCReverenceVoltage,
                                                             kHeatSinkThermistorBetaCoefficient, kHeatSinkThermistorT0Resistance, kHeatSinkThermistorT0));

    SinglePoleRecursiveFilter processValueFilter(5);
    PIDController *pidController = new PIDController({{100,1.0,10000,0.0}}, kHeatSinkPIDMin, kHeatSinkPIDMax, processValueFilter);

    consumer = thermistor;

    return HeatSinkInstance::createInstance(thermistor, kHeatSinkMinTargetTemp, kHeatSinkMaxTargetTemp, pidController, kHeatSinkFanControlPWMPath, kFanPWMPeriodNs);
}
