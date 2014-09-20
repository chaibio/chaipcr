#include <sstream>

#include "thermistor.h"
#include "pid.h"
#include "temperaturecontroller.h"

TemperatureController::TemperatureController(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController)
{
    _enableMode = false;

    _thermistor = thermistor;
    _pidController = pidController;
    _pidResult = 0;
    _minTargetTemp = minTargetTemp;
    _maxTargetTemp = maxTargetTemp;

    _thermistor->temperatureChanged.connect(boost::bind(&TemperatureController::computePid, this, _1));
}

void TemperatureController::setEnableMode(bool enableMode)
{
    if (enableMode != _enableMode)
    {
        _enableMode = enableMode;

        if (_enableMode)
        {
            _pidController->reset();

            _pidMutex.lock();
            _pidState = true;
            _pidMutex.unlock();
        }
        else
        {
            _pidMutex.lock();
            _pidState = false;
            _pidMutex.unlock();

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

void TemperatureController::computePid(double currentTemperature)
{
    _pidMutex.lock();
    {
        if (_pidState)
        {
            double result = _pidController->compute(targetTemperature(), currentTemperature);

            if (_enableMode && result != _pidResult)
            {
                _pidResult = result;
                setOutput(result);
            }
        }
    }
    _pidMutex.unlock();
}
