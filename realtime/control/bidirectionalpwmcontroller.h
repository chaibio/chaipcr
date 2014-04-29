#ifndef BIDIRECTIONALPWMCONTROLLER_H
#define BIDIRECTIONALPWMCONTROLLER_H

#include "temperaturecontroller.h"
#include "pwm.h"

class BidirectionalPWMController : public TemperatureController, public PWMControl
{
public:
    BidirectionalPWMController(TEMPERATURE_CONTROLLER_ARGS, const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin);

protected:
    void setOutput(double value);
    void resetOutput();
    bool outputDirection() const;
    void processOutput();

private:
    GPIO _heatIO;
    GPIO _coolIO;
};

#endif // BIDIRECTIONALPWMCONTROLLER_H
