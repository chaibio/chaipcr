#include "pcrincludes.h"

#include "thermistor.h"
#include "temperaturecontroller.h"

TemperatureController::TemperatureController(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp,
                                             PIDController *pidController, long pidTimerInterval)
    :PIDControl(pidController, pidTimerInterval)
{
    _enableMode = false;

    _thermistor = thermistor;
    _minTargetTemp = minTargetTemp;
    _maxTargetTemp = maxTargetTemp;

    _targetValue = std::bind(&TemperatureController::targetTemperature, this);
    _currentValue = std::bind(&TemperatureController::currentTemperature, this);
}

void TemperatureController::setEnableMode(bool enableMode)
{
    if (enableMode != _enableMode)
    {
        _enableMode = enableMode;

        if (_enableMode)
            startPid();
        else
        {
            stopPid();
            resetOutput();
        }
    }
}

void TemperatureController::setTargetTemperature(double temperature)
{
    if (temperature < _minTargetTemp || temperature > _maxTargetTemp)
    {
        std::stringstream string;
        string << "Target temperature should be in range from " << _minTargetTemp << " to " << _maxTargetTemp;

        throw std::out_of_range(string.str());
    }

    _targetTemperature.store(temperature);
}

double TemperatureController::currentTemperature() const
{
    return _thermistor->temperature();
}

void TemperatureController::process()
{
    if (_enableMode)
    {
        processOutput();
    }
}

void TemperatureController::pidCallback(double pidResult)
{
    setOutput(pidResult);
}
