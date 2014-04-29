#include "pcrincludes.h"

#include "thermistor.h"
#include "temperaturecontroller.h"

TemperatureController::TemperatureController(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp,
                                             CPIDController *pidController, long pidTimerInterval, double pidRangeControlThreshold)
    :PIDControl(pidController, pidTimerInterval)
{
    _controlMode = None;
    _mode = true;

    _thermistor = thermistor;
    _minTargetTemp = minTargetTemp;
    _maxTargetTemp = maxTargetTemp;

    _pidRangeControlThreshold = pidRangeControlThreshold;

    _targetValue = std::bind(&TemperatureController::targetTemperature, this);
    _currentValue = std::bind(&TemperatureController::currentTemperature, this);

    setTargetTemperature(30);
}

void TemperatureController::setMode(bool mode)
{
    if (mode != _mode)
    {
        _mode = mode;

        if (_mode)
            checkControlMode();
        else
        {
            stopPid();
            resetOutput();

            _controlMode = None;
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
    if (_mode)
    {
        checkControlMode();
        processOutput();
    }
}

void TemperatureController::pidCallback(double pidResult)
{
    setOutput(pidResult);
}

void TemperatureController::checkControlMode()
{
    if ((currentTemperature() - targetTemperature()) <= _pidRangeControlThreshold)
    {
        if (_controlMode != PIDMode)
        {
            _controlMode = PIDMode;

            _pidController->setIntegrator(outputDirection() ? _pidController->getMaxOutput() : _pidController->getMinOutput());
            _pidController->setPreviousError(0);

            startPid();
        }
    }
    else
    {
        if (_controlMode != BangBangMode)
        {
            _controlMode = BangBangMode;

            stopPid();
            setOutput(_pidController->getMaxOutput());
        }
    }
}
