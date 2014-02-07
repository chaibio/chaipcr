#include "pcrincludes.h"
#include "utilincludes.h"

#include "ltc2444.h"
#include "adccontroller.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class ADCController
ADCController::ADCController(unsigned int csPinNumber, SPIPort& spiPort, unsigned int busyPinNumber)
{
    _ltc2444 = make_shared<LTC2444>(csPinNumber, spiPort, busyPinNumber);
}

ADCController::~ADCController()
{
}

void ADCController::process()
{
	//read channel 1 as test
    _ltc2444->setup(0x6, false);
    _ltc2444->readADC(1, true);
    while (_ltc2444->busy()) {
        cout << "Waiting - busy" << endl;
	}
    uint32_t value = _ltc2444->readADC(1, true);
    cout << "Read value " << value << endl;
}
