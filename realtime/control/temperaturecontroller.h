#ifndef TEMPERATURECONTROLLER_H
#define TEMPERATURECONTROLLER_H

#include "icontrol.h"
#include "pid.h"

class Thermistor;

class TemperatureController : public IControl, public PIDControl
{
public:
    enum ControlMode
    {
        None,
        PIDMode,
        BangBangMode
    };

    TemperatureController(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp,
                          CPIDController *pidController, long pidTimerInterval, double pidRangeControlThreshold);

    inline ControlMode controlMode() const { return _controlMode; }

    inline bool enableMode() const { return _enableMode; }
    void setEnableMode(bool enableMode);

    void setTargetTemperature(double temperature);
    inline double targetTemperature() const { return _targetTemperature.load(); }

    double currentTemperature() const;

    void process() final;

protected:
    void pidCallback(double pidResult);

    virtual void setOutput(double value) = 0;
    virtual void resetOutput() = 0;
    virtual bool outputDirection() const = 0;
    virtual void processOutput() = 0;

private:
    void checkControlMode();

protected:
    std::shared_ptr<Thermistor> _thermistor;

private:
    std::atomic<ControlMode> _controlMode;
    std::atomic<bool> _enableMode;

    std::atomic<double> _targetTemperature;
    double _minTargetTemp;
    double _maxTargetTemp;

    double _pidRangeControlThreshold;
};

#define TEMPERATURE_CONTROLLER_ARGS std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, CPIDController *pidController, long pidTimerInterval, double pidRangeControlThreshold
#define TEMPERATURE_CONTROLLER_INIT TemperatureController(thermistor, minTargetTemp, maxTargetTemp, pidController, pidTimerInterval, pidRangeControlThreshold)

#endif // TEMPERATURECONTROLLER_H
