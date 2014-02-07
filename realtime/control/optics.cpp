#include "pcrincludes.h"
#include "utilincludes.h"

#include "ledcontroller.h"
#include "optics.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics()
{
    _lidOpen.store(false);
    _lidSensePin = make_shared<GPIO>(kLidSensePinNumber, GPIO::kInput);
    _ledController = make_shared<LEDController>(50);
}

Optics::~Optics()
{
}

void Optics::process()
{
	//read lid state
    _lidOpen.store(_lidSensePin->value());
}
