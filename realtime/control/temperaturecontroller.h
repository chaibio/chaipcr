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
    template <typename ...OutputArgs>
    TemperatureController(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, CPIDController *pidController, long pidTimerInterval, OutputArgs... args)
        :PIDControl(pidController, pidTimerInterval),
         Output(args...)
    {
        _thermistor = thermistor;
        _minTargetTemp = minTargetTemp;
        _maxTargetTemp = maxTargetTemp;

        _targetValue = std::bind(&TemperatureController::targetTemperature, this);
        _currentValue = std::bind(&TemperatureController::currentTemperature, this);

        setTargetTemperature(30);
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

private:
    std::atomic<double> _targetTemperature;
    double _minTargetTemp;
    double _maxTargetTemp;
};

/*-----------------------------------------Outputs--------------------------------------*/
class BidirectionalPWMControllerOutput : public PWMControl
{
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
