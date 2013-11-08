#include "pcrincludes.h"
#include "heatblock.h"

#include "heatblockzone.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
HeatBlock::HeatBlock() throw():
	zoneController_(nullptr) {
	
	zoneController_ = new HeatBlockZoneController(kHeatBlockADCTherm1CSPin);
}

HeatBlock::~HeatBlock() {
	delete zoneController_;
}

void HeatBlock::process() throw() {
	zoneController_->process();
}
