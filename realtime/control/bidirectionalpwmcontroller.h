#ifndef BIDIRECTIONALPWMCONTROLLER_H
#define BIDIRECTIONALPWMCONTROLLER_H

#include "temperaturecontroller.h"
#include "pwm.h"

#include "gpio.h"

class BidirectionalPWMController : public TemperatureController, public PWMControl
{
public:
    BidirectionalPWMController(Settings settings, const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin);
    ~BidirectionalPWMController();

    Direction outputDirection() const;
    void setOutput(double value);

protected:
    void resetOutput();
    void processOutput();

private:
    GPIO _heatIO;
    GPIO _coolIO;
};

#endif // BIDIRECTIONALPWMCONTROLLER_H
