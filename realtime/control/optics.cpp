#include "pcrincludes.h"
#include "utilincludes.h"

#include "ledcontroller.h"
#include "optics.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics(SPIPort ledSPIPort)
    :_photoDiodeMux{GPIO(kMuxControlPin1, GPIO::kOutput), GPIO(kMuxControlPin2, GPIO::kOutput), GPIO(kMuxControlPin3, GPIO::kOutput), GPIO(kMuxControlPin4, GPIO::kOutput)}
{
    _lidOpen.store(false);
    _lidSensePin = make_shared<GPIO>(kLidSensePinNumber, GPIO::kInput);
    _ledController = make_shared<LEDController>(move(ledSPIPort), 50);
}

Optics::~Optics()
{
}

void Optics::process()
{
	//read lid state
    _lidOpen.store(_lidSensePin->value());
    _photoDiodeMux.setChannel(11);
}
