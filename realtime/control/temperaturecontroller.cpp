#include <sstream>

#include "exceptions.h"
#include "thermistor.h"
#include "pid.h"
#include "temperaturecontroller.h"

TemperatureController::TemperatureController(Settings settings)
{
    _enableMode = false;

    _thermistor = settings.thermistor;
    _pidController = settings.pidController;
    _pidResult = 0;
    _minTargetTemp = settings.minTargetTemp;
    _maxTargetTemp = settings.maxTargetTemp;
    _minTempThreshold = settings.minTempThreshold;
    _maxTempThreshold = settings.maxTempThreshold;
    _targetTemperature = _minTargetTemp - 1;

    _thermistor->temperatureChanged.connect(boost::bind(&TemperatureController::computePid, this, _1));
}

TemperatureController::~TemperatureController()
{
    delete _pidController;
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
        string << "TemperatureController::setTargetTemperature - target temperature should be in range from " << _minTargetTemp << " to " << _maxTargetTemp;

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
    if (currentTemperature < _minTempThreshold || currentTemperature > _maxTempThreshold)
    {
        std::stringstream stream;
        stream << "TemperatureController::computePid - current temperature (" << currentTemperature << ") exceeds limits (" << _minTempThreshold << '/' << _maxTempThreshold << ')';

        throw TemperatureLimitError(stream.str());
    }

    if (_targetTemperature < _minTargetTemp)
        _targetTemperature = currentTemperature;

    std::lock_guard<std::mutex> lock(_pidMutex);

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
