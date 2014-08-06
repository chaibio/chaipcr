#ifndef BIDIRECTIONALPWMCONTROLLER_H
#define BIDIRECTIONALPWMCONTROLLER_H

#include "temperaturecontroller.h"
#include "pwm.h"

#include "gpio.h"

class BidirectionalPWMController : public TemperatureController, public PWMControl
{
public:
    BidirectionalPWMController(std::shared_ptr<Thermistor> thermistor, double minTargetTemp, double maxTargetTemp, PIDController *pidController,
                               const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin);
    ~BidirectionalPWMController();

    bool outputDirection() const;

protected:
    void setOutput(double value);
    void resetOutput();
    void processOutput();

private:
    GPIO _heatIO;
    GPIO _coolIO;
};

#endif // BIDIRECTIONALPWMCONTROLLER_H
