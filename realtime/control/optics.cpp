#include "pcrincludes.h"
#include "utilincludes.h"

#include "ledcontroller.h"
#include "optics.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics(SPIPort ledSPIPort)
    :_lidSensePin(kLidSensePinNumber, GPIO::kInput),
     _photoDiodeMux(initMux())
    //:_photoDiodeMux{GPIO(kMuxControlPin1, GPIO::kOutput), GPIO(kMuxControlPin2, GPIO::kOutput), GPIO(kMuxControlPin3, GPIO::kOutput), GPIO(kMuxControlPin4, GPIO::kOutput)}
{
    _lidOpen.store(false);
    _ledController = make_shared<LEDController>(move(ledSPIPort), 50);
}

Optics::~Optics()
{
}

vector<GPIO> Optics::initMux() const
{
    vector<GPIO> muxGpioList;
    muxGpioList.emplace_back(kMuxControlPin1, GPIO::kOutput);
    muxGpioList.emplace_back(kMuxControlPin2, GPIO::kOutput);
    muxGpioList.emplace_back(kMuxControlPin3, GPIO::kOutput);
    muxGpioList.emplace_back(kMuxControlPin4, GPIO::kOutput);

    return muxGpioList;
}

void Optics::process()
{
	//read lid state
    _lidOpen.store(_lidSensePin.value());
    _photoDiodeMux.setChannel(15);

}
