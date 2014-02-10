#include "pcrincludes.h"
#include "utilincludes.h"
#include "pocoincludes.h"

#include "fan.h"
#include "thermistor.h"
#include "heatsink.h"

using namespace std;
using namespace Poco;

////////////////////////////////////////////////////////////////////////////////
// Class HeatSink
HeatSink::HeatSink()
{
    _fan = new Fan();
    _thermistor = new Thermistor(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient);
    _targetTemperature.store(30);

    initPID();
}

HeatSink::~HeatSink()
{
    delete _pidTimer;
    delete _pidController.exchange(0);
    delete _thermistor;
    delete _fan;
}

void HeatSink::initPID()
{
    vector<SPIDTuning> pidTuningList; //TODO: Josh, please change it as you want

    _pidController.store(new CPIDController(pidTuningList, 0, 0));

    _pidTimer = new Timer(0, kHeatSinkPIDInterval);
    _pidTimer->start(TimerCallback<HeatSink>(*this, &HeatSink::pidCallback));
}

void HeatSink::pidCallback(Timer &)
{
    _fan->setPWMDutyCycle(_pidController.load()->compute(targetTemperature(), _thermistor->temperature()));
}

void HeatSink::process()
{
    _fan->process();
}
