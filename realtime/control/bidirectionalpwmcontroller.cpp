#include "bidirectionalpwmcontroller.h"

BidirectionalPWMController::BidirectionalPWMController(Settings settings, const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin)
    :TemperatureController(settings), PWMControl(pwmPath, pwmPeriod), _heatIO(heatIOPin, GPIO::kOutput), _coolIO(coolIOPin, GPIO::kOutput)
{
    resetOutput();
}

BidirectionalPWMController::~BidirectionalPWMController()
{
    resetOutput();
}

BidirectionalPWMController::Direction BidirectionalPWMController::outputDirection() const
{
    return _heatIO.value() == GPIO::kHigh ? EHeat : ECool;
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
    setPWMDutyCycle(0.0);

    _heatIO.setValue(GPIO::kLow, true);
    _coolIO.setValue(GPIO::kLow, true);
}

void BidirectionalPWMController::processOutput()
{

}
