#include "pcrincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"
#include "qpcrfactory.h"

using namespace std;

// Class QPCRFactory
void QPCRFactory::constructMachine(std::vector<std::shared_ptr<IControl> > &controls, std::vector<std::shared_ptr<IThreadControl> > &threadControls) {
    ADCController::ConsumersList adcConsumers;

    //shared_ptr<SPIPort> spiPort0(new SPIPort(kSPI0DevicePath));
    shared_ptr<SPIPort> spiPort1(new SPIPort(kSPI1DevicePath));

    controls.push_back(QPCRFactory::constructOptics(spiPort1, adcConsumers));
    controls.push_back(QPCRFactory::constructHeatBlock(adcConsumers));
    controls.push_back(QPCRFactory::constructLid(adcConsumers));
    controls.push_back(QPCRFactory::constructHeatSink());

    threadControls.push_back(ADCControllerInstance::createInstance(std::move(adcConsumers), kLTC2444CSPinNumber, std::move(SPIPort(kSPI0DevicePath)), kSPI0DataInSensePinNumber));

    setupMachine();
}

shared_ptr<IControl> QPCRFactory::constructOptics(shared_ptr<SPIPort> ledSPIPort, ADCController::ConsumersList &consumers) {
    shared_ptr<LEDController> ledControl(new LEDController(ledSPIPort, kLEDDigiPotCSPinNumber, kLEDControlXLATPinNumber,
                                                           kLEDBlankPWMPath, 50));

    vector<GPIO> photoDiodeMux;
    photoDiodeMux.emplace_back(kMuxControlPin1, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin2, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin3, GPIO::kOutput);
    photoDiodeMux.emplace_back(kMuxControlPin4, GPIO::kOutput);

    std::shared_ptr<Optics> optics = OpticsInstance::createInstance(kLidSensePinNumber, ledControl, MUX(move(photoDiodeMux)));
    consumers[ADCController::EReadLIA] = optics;

    return optics;
}

shared_ptr<IControl> QPCRFactory::constructHeatBlock(ADCController::ConsumersList &consumers) {
    static const std::vector<SPIDTuning> heatBlockPIDSchedule = {{150, 0.0374, 2.54, 0.381}};
    double cutoffFrequency = Filters::CutoffFrequencyForTimeConstant(heatBlockPIDSchedule.at(0).kDerivativeTimeS * kADCRepeatFrequency / kPIDDerivativeGainLimiter);

    TemperatureController::Settings settings;

    settings.minTargetTemp = kHeatBlockZonesMinTargetTemp;
    settings.maxTargetTemp = kHeatBlockZonesMaxTargetTemp;
    settings.minTempThreshold = kHeatBlockLowTempShutdownThreshold;
    settings.maxTempThreshold = kHeatBlockHighTempShutdownThreshold;

    settings.pidController = new PIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax, SinglePoleRecursiveFilter(cutoffFrequency));
    settings.thermistor.reset(new SteinhartHartThermistor(kHeatBlockThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                          kUSSensorJThermistorACoefficient, kUSSensorJThermistorBCoefficient,
                                                          kUSSensorJThermistorCCoefficient, kUSSensorJThermistorDCoefficient));

    HeatBlockZoneController *zone1 = new HeatBlockZoneController(settings, kHeatBlockZone1PWMPath, kHeatBlockZone1PWMPeriodNs, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin);
    consumers[ADCController::EReadZone1Singular] = settings.thermistor;

    settings.pidController = new PIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax, SinglePoleRecursiveFilter(cutoffFrequency));
    settings.thermistor.reset(new SteinhartHartThermistor(kHeatBlockThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                          kUSSensorJThermistorACoefficient, kUSSensorJThermistorBCoefficient,
                                                          kUSSensorJThermistorCCoefficient, kUSSensorJThermistorDCoefficient));

    HeatBlockZoneController *zone2 = new HeatBlockZoneController(settings, kHeatBlockZone2PWMPath, kHeatBlockZone2PWMPeriodNs, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin);
    consumers[ADCController::EReadZone2Singular] = settings.thermistor;

    return HeatBlockInstance::createInstance(zone1, zone2, kPCRBeginStepTemperatureThreshold, kMaxHeatBlockRampSpeed);
}

shared_ptr<IControl> QPCRFactory::constructLid(ADCController::ConsumersList &consumer) {
    TemperatureController::Settings settings;

    settings.thermistor.reset(new BetaThermistor(kLidThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits, kLidThermistorBetaCoefficient, kLidThermistorT0Resistance, kLidThermistorT0));
    settings.minTargetTemp = kLidMinTargetTemp;
    settings.maxTargetTemp = kLidMaxTargetTemp;
    settings.minTempThreshold = kLidLowTempShutdownThreshold;
    settings.maxTempThreshold = kLidHighTempShutdownThreshold;
    settings.pidController = new PIDController({{100, 1.0, 10000, 0}}, kLidPIDMin, kLidPIDMax, SinglePoleRecursiveFilter(5));

    consumer[ADCController::EReadLid] = settings.thermistor;

    return LidInstance::createInstance(settings, kLidControlPWMPath, kLidPWMPeriodNs, kProgramStartLidTempThreshold);
}

shared_ptr<IControl> QPCRFactory::constructHeatSink() {
    TemperatureController::Settings settings;

    settings.thermistor.reset(new SteinhartHartThermistor(kHeatSinkThermistorVoltageDividerResistanceOhms, kBeagleboneADCBits,
                                                          kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                          kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient));

    settings.minTargetTemp = kHeatSinkMinTargetTemp;
    settings.maxTargetTemp = kHeatSinkMaxTargetTemp;
    settings.minTempThreshold = kHeatSinkLowTempShutdownThreshold;
    settings.maxTempThreshold = kHeatSinkHighTempShutdownThreshold;
    settings.pidController = new PIDController({{100,0.05,10000,0.0}}, kHeatSinkPIDMin, kHeatSinkPIDMax, SinglePoleRecursiveFilter(5));

    return HeatSinkInstance::createInstance(settings, kHeatSinkFanControlPWMPath, kFanPWMPeriodNs, ADCPin(kADCPinPath, kHeatSinkThermistorADCPinChannel));
}

void QPCRFactory::setupMachine() {
    shared_ptr<HeatSink> heatSink = HeatSinkInstance::getInstance();
    shared_ptr<ADCController> adcController = ADCControllerInstance::getInstance();
    shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();

    if (heatSink) {
        heatSink->setTargetTemperature(kHeatSinkTargetTemperature);
        heatSink->setEnableMode(true);
    }

    if (adcController && heatBlock)
        adcController->loopStarted.connect(ADCController::LoopSignalType::slot_type(&HeatBlock::calculateTemperature, heatBlock.get()).track_foreign(heatBlock));
}
