#include "pcrincludes.h"
#include "optics.h"

#include <iostream>

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics() throw():
	lidOpen_ {false},
	lidSensePin_(kLidSensePinNumber, GPIO::kInput) {
}

Optics::~Optics() {
}

void Optics::process() throw() {
	//read lid state
	lidOpen_ = lidSensePin_.value();
}
