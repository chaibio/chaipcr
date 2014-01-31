#include "pcrincludes.h"
#include "optics.h"

#include "ledcontroller.h"

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics() throw():
	lidOpen_ {false},
	lidSensePin_(kLidSensePinNumber, GPIO::kInput) {

	ledController_ = new LEDController(50);
}

Optics::~Optics() {
	delete ledController_;
}

void Optics::process() throw() {
	//read lid state
	lidOpen_ = lidSensePin_.value();
}
