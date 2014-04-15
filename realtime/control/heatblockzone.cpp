#include "pcrincludes.h"
#include "pocoincludes.h"
#include "utilincludes.h"

#include "heatblockzone.h"

using namespace std;
using namespace Poco;

// Class HeatBlockZoneController
HeatBlockZoneController::HeatBlockZoneController(const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin)
    :PWMControl(pwmPath, pwmPeriod),
     TemperatureControl(std::make_shared<SteinhartHartThermistor>(kThermistorVoltageDividerResistanceOhms,
                                                                  kLTC2444ADCBits, kQTICurveZThermistorACoefficient,
                                                                  kQTICurveZThermistorBCoefficient, kQTICurveZThermistorCCoefficient,
                                                                  kQTICurveZThermistorDCoefficient)),
     heatIO(GPIO(heatIOPin, GPIO::kOutput)), coolIO(GPIO(coolIOPin, GPIO::kOutput))
{
    _pidController = 0;
    _pidResult.store(0);

    setTargetTemperature(30);
    //initPID();
}

HeatBlockZoneController::~HeatBlockZoneController()
{
    delete _pidTimer;
    delete _pidController;
}

std::shared_ptr<Thermistor> HeatBlockZoneController::thermistor() const
{
    return _thermistor;
}

void HeatBlockZoneController::initPID()
{
    vector<SPIDTuning> pidTuningList; //TODO: Josh, please change it as you want

    _pidController = new CPIDController(pidTuningList, kHeatBlockZonesPIDMin, kHeatBlockZonesPIDMax);

    _pidTimer = new Timer(0, kPIDInterval);
    _pidTimer->start(TimerCallback<HeatBlockZoneController>(*this, &HeatBlockZoneController::pidCallback));
}

void HeatBlockZoneController::pidCallback(Timer &)
{
    double pidResult = _pidController->compute(targetTemperature(), currentTemperature());

    if (pidResult != _pidResult.load())
    {
        setPWMDutyCycle(pidResult >= 0 ? pidResult : (pidResult * -1));

        _pidResult = pidResult;
    }
}

void HeatBlockZoneController::process()
{
    processPWM();

    if (_pidResult.load() >= 0)
    {
        coolIO.setValue(GPIO::kLow, true);
        heatIO.setValue(GPIO::kHigh, true);
    }
    else
    {
        heatIO.setValue(GPIO::kLow, true);
        coolIO.setValue(GPIO::kHigh, true);
    }
}
