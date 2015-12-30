#include "pcrincludes.h"
#include "spi.h"
#include "ledcontroller.h"

#include <sstream>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class LEDController
LEDController::LEDController(shared_ptr<SPIPort> spiPort,unsigned int potCSPin,
                             unsigned int ledXLATPin, const string &ledBlankPWMPath, float dutyCyclePercentage):
    _spiPort(spiPort),
    _potCSPin(potCSPin, GPIO::kOutput),
    _ledXLATPin(ledXLATPin, GPIO::kOutput),
    _ledGSPin(26, GPIO::kOutput),
    _ledBlankPWM(ledBlankPWMPath) {

    _dutyCyclePercentage.store(dutyCyclePercentage);

    disableLEDs();
    _ledBlankPWM.setPWM(kLedBlankPwmDutyNs, kLedBlankPwmPeriodNs, 0);
    setIntensity(kDefaultLEDCurrent);

    _potCSPin.setValue(GPIO::kHigh);
    _ledXLATPin.setValue(GPIO::kLow);
    _ledGSPin.setValue(GPIO::kLow);
}

LEDController::~LEDController() {
	
}
	
void LEDController::setIntensity(double onCurrentMilliamps) {
    if (_intensity == onCurrentMilliamps)
        return;

    if (onCurrentMilliamps > 0)
    {
        if (onCurrentMilliamps < kMinLEDCurrent)
        {
            std::stringstream stream;
            stream << "Requested LED intensity of " << onCurrentMilliamps << " below limit of " << kMinLEDCurrent;

            throw InvalidArgument(stream.str().c_str());
        }

        double avgCurrentMilliamps = onCurrentMilliamps * _dutyCyclePercentage / 100;

        if (avgCurrentMilliamps > kMaxAverageLEDCurrent || onCurrentMilliamps > kMaxInstantaneousLEDCurrent)
        {
            std::stringstream stream;
            stream << "Requested LED intensity of " << onCurrentMilliamps << " above limit of " << kMaxInstantaneousLEDCurrent;

            throw InvalidArgument(stream.str().c_str());
        }

        //calculate
        double rIref = 1.24 / (onCurrentMilliamps / 1000) * 31.5; //reference resistance for TLC5940
        int rN = (rIref - 75) * 256 / 5000;
        char txBuf[] = {0, static_cast<uint8_t>(rN)};

        //send resistance
        _potCSPin.setValue(GPIO::kLow);
        _spiPort->setMode(0);
        _spiPort->readBytes(NULL, txBuf, sizeof(txBuf), 1000000);
        _potCSPin.setValue(GPIO::kHigh);
    }
    else
        disableLEDs();

    _intensity = onCurrentMilliamps;
}

void LEDController::activateLED(unsigned int ledNumber) {
    uint16_t intensities[16] = {0};
    intensities[15 - (ledNumber - 1)] = 0xFFF;

	uint8_t packedIntensities[24];

	for (int i = 0; i < 16; i += 2) {
		uint16_t val1 = intensities[i];
		uint16_t val2 = intensities[i+1];

		int packIndex = i * 3 / 2;
		packedIntensities[packIndex] = val1 >> 4;
        packedIntensities[packIndex + 1] = (val1 & 0x000F) << 4 | (val2 & 0x0F00) >> 8;
		packedIntensities[packIndex + 2] = val2 & 0x00FF;
	}    
    sendLEDGrayscaleValues(packedIntensities);
}

void LEDController::disableLEDs() {
    uint8_t packedIntensities[24] = {0};
    sendLEDGrayscaleValues(packedIntensities);
}
	
// --- private member functions ------------------------------------------------
void LEDController::sendLEDGrayscaleValues(const uint8_t (&values)[24]) {
    _spiPort->setMode(0);
    _spiPort->readBytes(NULL, (char*)values, sizeof(values), 1000000);
    _ledXLATPin.setValue(GPIO::kHigh);
    _ledXLATPin.setValue(GPIO::kLow);
}
