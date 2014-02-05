#include "pcrincludes.h"
#include "optics.h"

#include "ledcontroller.h"

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics()
{
    _lidOpen.store(false);
    _lidSensePin = boost::make_shared<GPIO>(kLidSensePinNumber, GPIO::kInput);
    _ledController = boost::make_shared<LEDController>(50);
}

Optics::~Optics()
{
}

void Optics::process()
{
	//read lid state
    _lidOpen.store(_lidSensePin->value());
}
