#include "pcrincludes.h"
#include "optics.h"

#include "ledcontroller.h"

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics() :
	lidOpen_ {false},
	lidSensePin_(kLidSensePinNumber, GPIO::kInput) {

	ledController_ = new LEDController(50);
}

Optics::~Optics() {
	delete ledController_;
}

void Optics::process() {
	//read lid state
	lidOpen_ = lidSensePin_.value();
}
