#include "pcrincludes.h"

#include "thermistor.h"
#include "heatblockzone.h"
#include "heatblock.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
HeatBlock::HeatBlock()
{
    zoneController_ = make_shared<HeatBlockZoneController>();
}

HeatBlock::~HeatBlock()
{
}

void HeatBlock::process()
{
	zoneController_->process();
}
