#include "pcrincludes.h"
#include "pocoincludes.h"
#include "utilincludes.h"

#include "thermistor.h"
#include "lid.h"

using namespace std;
using namespace Poco;

Lid::Lid()
    :PWMControl(kLidControlPWMPath, kLidPWMPeriodNs)
{
    _thermistor = new Thermistor(kThermistorVoltageDividerResistanceOhms, kLTC2444ADCBits,
                                kQTICurveZThermistorACoefficient, kQTICurveZThermistorBCoefficient,
                                kQTICurveZThermistorCCoefficient, kQTICurveZThermistorDCoefficient);

    setTargetTemperature(30);
    initPID();
}

Lid::~Lid()
{
    delete _pidTimer;
    delete _pidController.exchange(0);
    delete _thermistor;
}

void Lid::initPID()
{
    vector<SPIDTuning> pidTuningList; //TODO: Josh, please change it as you want

    _pidController.store(new CPIDController(pidTuningList, 0, 0));

    _pidTimer = new Timer(0, kPIDInterval);
    _pidTimer->start(TimerCallback<Lid>(*this, &Lid::pidCallback));
}

void Lid::pidCallback(Timer &)
{
    setPWMDutyCycle(_pidController.load()->compute(_targetTemperature.load(), _thermistor->temperature()));
}

void Lid::process()
{
    processPWM();
}
