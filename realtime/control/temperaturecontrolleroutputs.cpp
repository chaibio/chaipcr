#include "pcrincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

using namespace std;

/*---------------------------------------BidirectionalPWMControllerOutput---------------------------------------*/
BidirectionalPWMControllerOutput::BidirectionalPWMControllerOutput(const string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin)
    :PWMControl(pwmPath, pwmPeriod),
    _heatIO(heatIOPin, GPIO::kOutput), _coolIO(coolIOPin, GPIO::kOutput)
{
}

void BidirectionalPWMControllerOutput::setValue(double pidResult)
{
    setPWMDutyCycle(pidResult >= 0 ? pidResult : (pidResult * -1));
}

void BidirectionalPWMControllerOutput::process(double pidResult)
{
    processPWM();

    if (pidResult >= 0)
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

/*------------------------------------------------------------------------------*/

/*---------------------------------------LidOutput---------------------------------------*/
LidOutput::LidOutput(const string &pwmPath, unsigned long pwmPeriod)
    :PWMControl(pwmPath, pwmPeriod)
{

}

void LidOutput::setValue(double pidResult)
{
    setPWMDutyCycle(pidResult);
}

void LidOutput::process(double)
{
    processPWM();
}

/*------------------------------------------------------------------------------*/

/*---------------------------------------HeatSinkOutput---------------------------------------*/
HeatSinkOutput::HeatSinkOutput()
{
    _fan = new Fan;
}

HeatSinkOutput::~HeatSinkOutput()
{
    delete _fan;
}

void HeatSinkOutput::setValue(double pidResult)
{
    _fan->setPWMDutyCycle(pidResult);
}

void HeatSinkOutput::process(double)
{
    _fan->process();
}

int HeatSinkOutput::targetRPM() const
{
    return _fan->targetRPM();
}

void HeatSinkOutput::setTargetRPM(int targetRPM)
{
    _fan->setTargetRPM(targetRPM);
}

/*------------------------------------------------------------------------------*/
