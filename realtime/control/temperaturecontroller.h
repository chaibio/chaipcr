#ifndef TEMPERATURECONTROLLER_H
#define TEMPERATURECONTROLLER_H

#include "icontrol.h"
#include "pid.h"
#include "thermistor.h"

template <class Output>
class TemperatureController : public IControl, public PIDControl, public Output
{
public:
    template <typename ...OutputArgs>
    TemperatureController(std::shared_ptr<Thermistor> thermistor, CPIDController *pidController, long pidTimerInterval, OutputArgs... args)
        :PIDControl(pidController, pidTimerInterval),
         Output(args...)
    {
        _thermistor = thermistor;

        _targetValue = std::bind(&TemperatureController::targetTemperature, this);
        _currentValue = std::bind(&TemperatureController::currentTemperature, this);

        setTargetTemperature(30);
    }

    ~TemperatureController()
    {
    }

    inline double targetTemperature() const { return _targetTemperature.load(); }
    inline void setTargetTemperature(double temperature) { _targetTemperature.store(temperature); }

    inline double currentTemperature() const { return _thermistor->temperature(); }

    void pidCallback(double pidResult)
    {
        Output::setValue(pidResult);
    }

    void process()
    {
        Output::process(_pidResult.load());
    }

protected:
    std::shared_ptr<Thermistor> _thermistor;
    std::atomic<double> _targetTemperature;
};

#endif // TEMPERATURECONTROLLER_H
