#include "pcrincludes.h"
#include "boostincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

#include "qpcrfactory.h"

using namespace std;

// Class QPCRFactory
vector<shared_ptr<IControl> > QPCRFactory::constructMachine() {
    vector<shared_ptr<IControl>> controls;
    vector<shared_ptr<ADCConsumer>> consumers;

    //shared_ptr<SPIPort> spiPort0(new SPIPort(kSPI0DevicePath));
    shared_ptr<SPIPort> spiPort1(new SPIPort(kSPI1DevicePath));

    consumers.push_back(nullptr); //Not refactored yet

    controls.push_back(QPCRFactory::constructOptics(spiPort1));
    controls.push_back(QPCRFactory::constructHeatBlock(consumers));
    controls.push_back(QPCRFactory::constructLid(consumers));
    //controls.push_back(QPCRFactory::constructHeatSink(consumers));

    controls.push_back(ADCControllerInstance::createInstance(consumers, kLTC2444CSPinNumber, std::move(SPIPort(kSPI0DevicePath)), kSPI0DataInSensePinNumber)); //Not refactored yet

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

shared_ptr<IControl> QPCRFactory::constructHeatBlock(vector<shared_ptr<ADCConsumer>> &consumers)
{
    shared_ptr<SteinhartHartThermistor> zone1Thermistor(new SteinhartHartThermistor(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                                                    kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                                                    kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient));

    std::vector<SPIDTuning> heatBlockPIDSchedule = {{50, 0.2, 0.01, 0.0}, {100, 0.2, 0.01, 0.0}};
    CPIDController *zone1CPIDController = new CPIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax);

    HeatBlockZoneController *zone1 = new HeatBlockZoneController(zone1Thermistor, kHeatBlockZonesMinTargetTemp, kHeatBlockZonesMaxTargetTemp,
                                                                 zone1CPIDController, kPIDIntervalMs, kHeatBlockZone1PIDThreshold, kHeatBlockZone1PWMPath,
                                                                 kHeatBlockZone1PWMPeriodNs, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin);

    shared_ptr<SteinhartHartThermistor> zone2Thermistor(new SteinhartHartThermistor(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                                                    kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                                                                    kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient));

    CPIDController *zone2CPIDController = new CPIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax);

    HeatBlockZoneController *zone2 = new HeatBlockZoneController(zone2Thermistor, kHeatBlockZonesMinTargetTemp, kHeatBlockZonesMaxTargetTemp,
                                                                 zone2CPIDController, kPIDIntervalMs, kHeatBlockZone2PIDThreshold, kHeatBlockZone2PWMPath,
                                                                 kHeatBlockZone2PWMPeriodNs, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin);

    consumers.push_back(zone1Thermistor);
    consumers.push_back(zone2Thermistor);

    return HeatBlockInstance::createInstance(zone1, zone2, kPCRBeginStepTemperatureThreshold );
}

shared_ptr<IControl> QPCRFactory::constructLid(vector<shared_ptr<ADCConsumer>> &consumers)
{
    shared_ptr<BetaThermistor> thermistor(new BetaThermistor(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                             kLidThermistorBetaCoefficient, kLidThermistorT0Resistance, kLidThermistorT0));

    CPIDController *pidController = new CPIDController({{50,1.0,0.0,0.0}, {100,1.0,0.0,0.0}}, kLidPIDMin, kLidPIDMax);

    consumers.push_back(thermistor);

    return LidInstance::createInstance(thermistor, kLidMinTargetTemp, kLidMaxTargetTemp, pidController, kPIDIntervalMs, kLidPIDThreshold,
                                       kLidControlPWMPath, kLidPWMPeriodNs, kProgramStartLidTempThreshold);
}

shared_ptr<IControl> QPCRFactory::constructHeatSink(vector<shared_ptr<ADCConsumer>> &consumers)
{
    shared_ptr<BetaThermistor> thermistor(new BetaThermistor(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                             kHeatSinkThermistorBetaCoefficient, kHeatSinkThermistorT0Resistance, kHeatSinkThermistorT0));

    CPIDController *pidController = new CPIDController({{50,1.0,0.0,0.0}, {100,1.0,0.0,0.0}}, kHeatSinkPIDMin, kHeatSinkPIDMax);

    consumers.push_back(thermistor);

    return HeatSinkInstance::createInstance(thermistor, kHeatSinkMinTargetTemp, kHeatSinkMaxTargetTemp, pidController, kPIDIntervalMs, kHeatSinkPIDThreshold);
}
