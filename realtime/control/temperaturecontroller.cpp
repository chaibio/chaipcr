#include <sstream>
#include <cctype>

#include "exceptions.h"
#include "thermistor.h"
#include "pid.h"
#include "temperaturecontroller.h"

TemperatureController::TemperatureController(Settings settings)
{
    _enableMode = false;

    _name = settings.name;
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
        string << "Requested " << _name << " temperature outside limits of " << _minTargetTemp << '-' << _maxTargetTemp << " C";

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
    if (currentTemperature < _minTempThreshold)
    {
        std::string name = _name;
        name.at(0) = std::toupper(name.at(0));

        std::stringstream stream;
        stream << name << " temperature of " << currentTemperature << " C below limit of " << _minTempThreshold << " C";

        throw TemperatureLimitError(stream.str());
    }
    else if (currentTemperature > _maxTempThreshold)
    {
        std::string name = _name;
        name.at(0) = std::toupper(name.at(0));

        std::stringstream stream;
        stream << name << " temperature of " << currentTemperature << " C above limit of " << _minTempThreshold << " C";

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
