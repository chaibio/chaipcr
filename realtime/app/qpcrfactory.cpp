//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include "pcrincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"
#include "qpcrfactory.h"
#include "qpcrapplication.h"

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
    static const std::vector<SPIDTuning> heatBlockPIDSchedule = {{10, 0.25, 32.0, 0.20},{20, 0.2, 32.0, 0.20},{60, 0.14, 32.0, 0.20},{150, 0.25, 32.0, 0.20}};
    double cutoffFrequency = Filters::CutoffFrequencyForTimeConstant(heatBlockPIDSchedule.at(0).kDerivativeTimeS * kADCRepeatFrequency / kPIDDerivativeGainLimiter);

    TemperatureController::Settings settings;

    settings.minTargetTemp = qpcrApp.settings().configuration.heatBlockMinTemp;
    settings.maxTargetTemp = qpcrApp.settings().configuration.heatBlockMaxTemp;
    settings.minTempThreshold = kHeatBlockLowTempShutdownThreshold;
    settings.maxTempThreshold = kHeatBlockHighTempShutdownThreshold;

    settings.name = "heat block 1";
    settings.pidController = new PIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax, SinglePoleRecursiveFilter(cutoffFrequency));
    settings.thermistor.reset(new SteinhartHartThermistorC0135(kHeatBlockThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                          kUSSensorJThermistorC0Coefficient, kUSSensorJThermistorC1Coefficient,
                                                          kUSSensorJThermistorC3Coefficient, kUSSensorJThermistorC5Coefficient));

    HeatBlockZoneController *zone1 = new HeatBlockZoneController(settings, kHeatBlockZone1PWMPath, kHeatBlockZone1PWMPeriodNs, kHeadBlockZone1HeatPin, kHeadBlockZone1CoolPin);
    consumers[ADCController::EReadZone1Singular] = settings.thermistor;

    settings.name = "heat block 2";
    settings.pidController = new PIDController(heatBlockPIDSchedule, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax, SinglePoleRecursiveFilter(cutoffFrequency));
    settings.thermistor.reset(new SteinhartHartThermistorC0135(kHeatBlockThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                                          kUSSensorJThermistorC0Coefficient, kUSSensorJThermistorC1Coefficient,
                                                          kUSSensorJThermistorC3Coefficient, kUSSensorJThermistorC5Coefficient));

    HeatBlockZoneController *zone2 = new HeatBlockZoneController(settings, kHeatBlockZone2PWMPath, kHeatBlockZone2PWMPeriodNs, kHeadBlockZone2HeatPin, kHeadBlockZone2CoolPin);
    consumers[ADCController::EReadZone2Singular] = settings.thermistor;

    return HeatBlockInstance::createInstance(zone1, zone2, kPCRBeginStepTemperatureThreshold, kMaxHeatBlockRampSpeed);
}

shared_ptr<IControl> QPCRFactory::constructLid(ADCController::ConsumersList &consumers) {
    TemperatureController::Settings settings;

    settings.name = "lid";
    settings.thermistor.reset(new BetaThermistor(kLidThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits, kLidThermistorBetaCoefficient, kLidThermistorT0Resistance, kLidThermistorT0));
    settings.minTargetTemp = kLidMinTargetTemp;
    settings.maxTargetTemp = qpcrApp.settings().configuration.lidMaxTemp;
    settings.minTempThreshold = kLidLowTempShutdownThreshold;
    settings.maxTempThreshold = kLidHighTempShutdownThreshold;
    settings.pidController = new PIDController({{150, 0.35, 100, 0}}, kLidPIDMin, kLidPIDMax, SinglePoleRecursiveFilter(0.01));//was 150, 0.2, 100, 0 ///0.3 works for gain

    consumers[ADCController::EReadLid] = settings.thermistor;

    return LidInstance::createInstance(settings, kLidControlPWMPath, kLidPWMPeriodNs, kProgramStartLidTempThreshold);
}

shared_ptr<IControl> QPCRFactory::constructHeatSink() {
    TemperatureController::Settings settings;

    settings.thermistor.reset(new SteinhartHartThermistorC0123(kHeatSinkThermistorVoltageDividerResistanceOhms, kBeagleboneADCBits,
                                                          kQTICurveZThermistorC0Coefficient, kQTICurveZThermistorC1Coefficient,
                                                          kQTICurveZThermistorC2Coefficient, kQTICurveZThermistorC3Coefficient));

    settings.name = "heat sink";
    settings.minTargetTemp = kHeatSinkMinTargetTemp;
    settings.maxTargetTemp = kHeatSinkMaxTargetTemp;
    settings.minTempThreshold = kHeatSinkLowTempShutdownThreshold;
    settings.maxTempThreshold = kHeatSinkHighTempShutdownThreshold;
    settings.pidController = new PIDController({{100,0.05,100,0.0}}, kHeatSinkPIDMin, kHeatSinkPIDMax, SinglePoleRecursiveFilter(5));

    return HeatSinkInstance::createInstance(settings, kHeatSinkFanControlPWMPath, kFanPWMPeriodNs, ADCPin(kADCPinPath, kHeatSinkThermistorADCPinChannel));
}

void QPCRFactory::setupMachine() {
    shared_ptr<HeatSink> heatSink = HeatSinkInstance::getInstance();
    shared_ptr<ADCController> adcController = ADCControllerInstance::getInstance();
    shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();

    if (heatSink) {
        heatSink->setTargetTemperature(kHeatSinkTargetTemperature);
        //heatSink->setEnableMode(true);
    }

    if (adcController && heatBlock)
        adcController->loopStarted.connect(boost::signals2::lockfree_signal<void()>::slot_type(&HeatBlock::calculateTemperature, heatBlock.get()).track_foreign(heatBlock));
}
