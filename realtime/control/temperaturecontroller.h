#ifndef TEMPERATURECONTROLLER_H
#define TEMPERATURECONTROLLER_H

#include "icontrol.h"

#include <memory>
#include <atomic>
#include <mutex>

class Thermistor;
class PIDController;

class TemperatureController : public IControl
{
public:
    enum Direction
    {
        EHeat,
        ECool
    };

    TemperatureController(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController);

    inline bool enableMode() const { return _enableMode; }
    void setEnableMode(bool enableMode);

    void setTargetTemperature(double temperature);
    inline double targetTemperature() const { return _targetTemperature.load(); }
    double currentTemperature() const;

    virtual Direction outputDirection() const = 0;

    void process() final;

protected:
    virtual void setOutput(double value) = 0;
    virtual void resetOutput() = 0;
    virtual void processOutput() = 0;

private:
    void computePid();

protected:
    std::shared_ptr<Thermistor> _thermistor;

private:
    PIDController *_pidController;
    bool _pidState;
    double _pidResult;
    std::mutex _pidMutex;

    std::atomic<bool> _enableMode;

    std::atomic<double> _targetTemperature;
    double _minTargetTemp;
    double _maxTargetTemp;
};

#endif // TEMPERATURECONTROLLER_H
