#include "pcrincludes.h"
#include "heatsink.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatSink
HeatSink::HeatSink() throw() {
}

HeatSink::~HeatSink() {
}

void HeatSink::process() throw() {
	fan_.process();
}
