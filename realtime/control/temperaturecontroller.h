#ifndef TEMPERATURECONTROLLER_H
#define TEMPERATURECONTROLLER_H

#include "icontrol.h"
#include "pid.h"

class Thermistor;

class TemperatureController : public IControl, public PIDControl
{
public:
    TemperatureController(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp,
                          PIDController *pidController, long pidTimerInterval);

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

protected:
    std::shared_ptr<Thermistor> _thermistor;

private:
    std::atomic<bool> _enableMode;

    std::atomic<double> _targetTemperature;
    double _minTargetTemp;
    double _maxTargetTemp;
};

#endif // TEMPERATURECONTROLLER_H
