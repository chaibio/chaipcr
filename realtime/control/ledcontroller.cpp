#include "pcrincludes.h"
#include "utilincludes.h"

#include "ledcontroller.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class LEDController
LEDController::LEDController(std::shared_ptr<SPIPort> spiPort, float dutyCyclePercentage):
    _spiPort {spiPort},
    _potCSPin(kLEDDigiPotCSPinNumber, GPIO::kOutput)
{
    _dutyCyclePercentage.store(dutyCyclePercentage);
    _grayscaleClock = make_shared<PWMPin>(kLEDGrayscaleClockPWMPath);
	setIntensity(kMinLEDCurrent);
    _grayscaleClock->setPWM(kGrayscaleClockPwmDutyNs, kGrayscaleClockPwmPeriodNs, 0);

    _potCSPin.setValue(GPIO::kHigh);
}

LEDController::~LEDController()
{
	
}
	
void LEDController::setIntensity(double onCurrentMilliamps)
{
	//verify current
    if (onCurrentMilliamps < kMinLEDCurrent)
		throw InvalidArgument("onCurrent too low");
    double avgCurrentMilliamps = onCurrentMilliamps * _dutyCyclePercentage / 100;
    if (avgCurrentMilliamps > 30 || onCurrentMilliamps > 100)
		throw InvalidArgument("onCurrent too high");
	
	//calculate 
    double rIref = 1.24 / (onCurrentMilliamps / 1000) * 31.5; //reference resistance for TLC5940
    int rN = (rIref - 75) * 256 / 5000;
    char txBuf[] = {0, static_cast<uint8_t>(rN)};
    cout << "onCurrent = " << onCurrentMilliamps << ", rIref " << rIref << ", rN = " << rN << endl;

    //send resistance
    _potCSPin.setValue(GPIO::kLow);
    _spiPort->setMode(0);
    _spiPort->readBytes(NULL, txBuf, sizeof(txBuf), 1000000);
    _potCSPin.setValue(GPIO::kHigh);

    _intensity = onCurrentMilliamps;
}

void LEDController::activateLED(unsigned int)
{
	
}

void LEDController::disableLEDs()
{
	
}
	
// --- private member functions ------------------------------------------------
