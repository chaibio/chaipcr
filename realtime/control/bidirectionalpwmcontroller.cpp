#include "pcrincludes.h"
#include "utilincludes.h"

#include "bidirectionalpwmcontroller.h"

BidirectionalPWMController::BidirectionalPWMController(TEMPERATURE_CONTROLLER_ARGS, const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin)
    :TEMPERATURE_CONTROLLER_INIT,
     PWMControl(pwmPath, pwmPeriod),
     _heatIO(heatIOPin, GPIO::kOutput), _coolIO(coolIOPin, GPIO::kOutput)
{
    resetOutput();
}

void BidirectionalPWMController::setOutput(double value)
{
    setPWMDutyCycle(value >= 0 ? value : (value * -1));

    if (value >= 0)
    {
        _coolIO.setValue(GPIO::kLow, true);
        _heatIO.setValue(GPIO::kHigh, true);
    }
    else
    {
        _heatIO.setValue(GPIO::kLow, true);
        _coolIO.setValue(GPIO::kHigh, true);
    }
}

void BidirectionalPWMController::resetOutput()
{
    setPWMDutyCycle(0);

    _heatIO.setValue(GPIO::kLow, true);
    _coolIO.setValue(GPIO::kLow, true);
}

bool BidirectionalPWMController::outputDirection() const
{
    return _heatIO.value() == GPIO::kHigh ? true : false;
}

void BidirectionalPWMController::processOutput()
{
    processPWM();
}
