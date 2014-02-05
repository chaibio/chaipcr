#include "pcrincludes.h"
#include "heatblock.h"

#include "heatblockzone.h"

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
HeatBlock::HeatBlock()
{
    zoneController_ = boost::make_shared<HeatBlockZoneController>();
}

HeatBlock::~HeatBlock()
{
}

void HeatBlock::process()
{
	zoneController_->process();
}
