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
    shared_ptr<SteinhartHartThermistor> zone1Thermistor(new SteinhartHartThermistor(kHeatBlockThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                                                    kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                                                    kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient));

    std::vector<SPIDTuning> heatBlockPIDSchedule = {{150, 0.0374, 2.54, 0.381}};
    double derivativeFilterTimeConstant = heatBlockPIDSchedule.at(0).kDerivativeTimeS * kADCRepeatFrequency / kPIDDerivativeGainLimiter;
    SinglePoleRecursiveFilter processValueFilter(Filters::CutoffFrequencyForTimeConstant(derivativeFilterTimeConstant));
    PIDController *zone1CPIDController = new PIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax, processValueFilter);

    HeatBlockZoneController *zone1 = new HeatBlockZoneController(zone1Thermistor, kHeatBlockZonesMinTargetTemp, kHeatBlockZonesMaxTargetTemp, zone1CPIDController,
                                                                 kHeatBlockZone1PWMPath, kHeatBlockZone1PWMPeriodNs, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin);

    shared_ptr<SteinhartHartThermistor> zone2Thermistor(new SteinhartHartThermistor(kHeatBlockThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                                                    kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                                                    kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient));

    PIDController *zone2CPIDController = new PIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax, processValueFilter);

    HeatBlockZoneController *zone2 = new HeatBlockZoneController(zone2Thermistor, kHeatBlockZonesMinTargetTemp, kHeatBlockZonesMaxTargetTemp, zone2CPIDController,
                                                                 kHeatBlockZone2PWMPath, kHeatBlockZone2PWMPeriodNs, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin);

    consumers[ADCController::EReadZone1Singular] = zone1Thermistor;
    consumers[ADCController::EReadZone2Singular] = zone2Thermistor;

    return HeatBlockInstance::createInstance(zone1, zone2, kPCRBeginStepTemperatureThreshold, kMaxHeatBlockRampSpeed);
}

shared_ptr<IControl> QPCRFactory::constructLid(ADCController::ConsumersList &consumer) {
    shared_ptr<BetaThermistor> thermistor(new BetaThermistor(kLidThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                             kLidThermistorBetaCoefficient, kLidThermistorT0Resistance, kLidThermistorT0));

    SinglePoleRecursiveFilter processValueFilter(5);
    PIDController *pidController = new PIDController({{100, 1.0, 10000, 0}}, kLidPIDMin, kLidPIDMax, processValueFilter);

    consumer[ADCController::EReadLid] = thermistor;

    return LidInstance::createInstance(thermistor, kLidMinTargetTemp, kLidMaxTargetTemp, pidController,
                                       kLidControlPWMPath, kLidPWMPeriodNs, kProgramStartLidTempThreshold);
}

shared_ptr<IControl> QPCRFactory::constructHeatSink() {
    shared_ptr<BetaThermistor> thermistor(new BetaThermistor(kHeatSinkThermistorVoltageDividerResistanceOhms, kBeagleboneADCBits,
                                                             kHeatSinkThermistorBetaCoefficient, kHeatSinkThermistorT0Resistance, kHeatSinkThermistorT0));

    SinglePoleRecursiveFilter processValueFilter(5);
    PIDController *pidController = new PIDController({{100,0.05,10000,0.0}}, kHeatSinkPIDMin, kHeatSinkPIDMax, processValueFilter);

    return HeatSinkInstance::createInstance(thermistor, kHeatSinkMinTargetTemp, kHeatSinkMaxTargetTemp, pidController, kHeatSinkFanControlPWMPath, kFanPWMPeriodNs, ADCPin(kADCPinPath, kHeatSinkThermistorADCPinChannel));
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
