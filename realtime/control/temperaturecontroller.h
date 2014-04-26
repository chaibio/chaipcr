#ifndef TEMPERATURECONTROLLER_H
#define TEMPERATURECONTROLLER_H

#include "pcrincludes.h"
#include "utilincludes.h"

#include "icontrol.h"
#include "thermistor.h"

template <class Output>
class TemperatureController : public IControl, public PIDControl, public Output
{
public:
    enum ControlMode
    {
        None,
        PIDMode,
        BangBangMode
    };

    template <typename ...OutputArgs>
    TemperatureController(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp,
                          CPIDController *pidController, long pidTimerInterval, double pidRangeControlThreshold,
                          OutputArgs... args)
        :PIDControl(pidController, pidTimerInterval),
         Output(args...)
    {
        _mode = None;

        _thermistor = thermistor;
        _minTargetTemp = minTargetTemp;
        _maxTargetTemp = maxTargetTemp;

        _pidRangeControlThreshold = pidRangeControlThreshold;

        _targetValue = std::bind(&TemperatureController::targetTemperature, this);
        _currentValue = std::bind(&TemperatureController::currentTemperature, this);

        setTargetTemperature(30);
        checkControlMode();
    }

    void setTargetTemperature(double temperature)
    {
        if (temperature < _minTargetTemp || temperature > _maxTargetTemp)
        {
            std::stringstream string;
            string << "Target temperature should be in range from " << _minTargetTemp << " to " << _maxTargetTemp;

            throw std::out_of_range(string.str());
        }

        _targetTemperature.store(temperature);
    }

    inline double targetTemperature() const { return _targetTemperature.load(); }
    inline double currentTemperature() const { return _thermistor->temperature(); }

    inline ControlMode mode() const { return _mode; }

    void pidCallback(double pidResult)
    {
        Output::setValue(pidResult);
    }

    void process()
    {
        checkControlMode();
        Output::process(_pidResult.load());
    }

private:
    void checkControlMode()
    {
        if ((currentTemperature() - targetTemperature()) <= _pidRangeControlThreshold)
        {
            if (_mode != PIDMode)
            {
                _mode = PIDMode;

                _pidController->setIntegrator(Output::direction() ? _pidController->getMaxOutput() : _pidController->getMinOutput());
                _pidController->setPreviousError(0);

                startPid();
            }
        }
        else
        {
            if (_mode != BangBangMode)
            {
                _mode = BangBangMode;

                stopPid();
                Output::setValue(_pidController->getMaxOutput());
            }
        }
    }

protected:
    std::shared_ptr<Thermistor> _thermistor;

private:
    ControlMode _mode;

    std::atomic<double> _targetTemperature;
    double _minTargetTemp;
    double _maxTargetTemp;

    double _pidRangeControlThreshold;
};

/*-----------------------------------------Outputs--------------------------------------*/
class BidirectionalPWMControllerOutput : public PWMControl
{
public:
    bool direction() const;

protected:
    BidirectionalPWMControllerOutput(const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin);

    void setValue(double pidResult);
    void process(double pidResult);

private:
    GPIO _heatIO;
    GPIO _coolIO;
};

class LidOutput : public PWMControl
{
public:
    inline bool direction() const { return true; }

protected:
    LidOutput(const std::string &pwmPath, unsigned long pwmPeriod);

    void setValue(double pidResult);
    void process(double pidResult);
};

class Fan;

class HeatSinkOutput
{
public:
    virtual ~HeatSinkOutput();

    inline bool direction() const { return false; }

    int targetRPM() const;
    void setTargetRPM(int targetRPM);

protected:
    HeatSinkOutput();

    void setValue(double pidResult);
    void process(double pidResult);

private:
    Fan *_fan;
};

typedef TemperatureController<BidirectionalPWMControllerOutput> HeatBlockZoneController;
typedef TemperatureController<LidOutput> Lid;
typedef TemperatureController<HeatSinkOutput> HeatSink;

#endif // TEMPERATURECONTROLLER_H
