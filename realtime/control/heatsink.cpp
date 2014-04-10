#include "pcrincludes.h"
#include "utilincludes.h"
#include "pocoincludes.h"

#include "fan.h"
#include "heatsink.h"

using namespace std;
using namespace Poco;

////////////////////////////////////////////////////////////////////////////////
// Class HeatSink
HeatSink::HeatSink()
    :TemperatureControl(std::make_shared<SteinhartHartThermistor>(kThermistorVoltageDividerResistanceOhms,
                                                                  kLTC2444ADCBits, kQTICurveZThermistorACoefficient,
                                                                  kQTICurveZThermistorBCoefficient, kQTICurveZThermistorCCoefficient,
                                                                  kQTICurveZThermistorDCoefficient))
{
    _pidController = 0;
    _fan = new Fan();

    setTargetTemperature(30);
    initPID();
}

HeatSink::~HeatSink()
{
    delete _pidTimer;
    delete _pidController;
    delete _fan;
}

void HeatSink::initPID()
{
    vector<SPIDTuning> pidTuningList; //TODO: Josh, please change it as you want

    _pidController = new CPIDController(pidTuningList, 0, 0);

    _pidTimer = new Timer(0, kPIDInterval);
    _pidTimer->start(TimerCallback<HeatSink>(*this, &HeatSink::pidCallback));
}

void HeatSink::pidCallback(Timer &)
{
    _fan->setPWMDutyCycle(_pidController->compute(targetTemperature(), currentTemperature()));
}

void HeatSink::process()
{
    _fan->process();
}
