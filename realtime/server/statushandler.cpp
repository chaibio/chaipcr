#include "pcrincludes.h"
#include "boostincludes.h"
#include "pocoincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

#include "statushandler.h"

void StatusHandler::createData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt)
{
    std::shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();

    if (heatBlock)
    {
        responsePt.put("heatblock.zone1.temperature", heatBlock->zone1Temperature());
        responsePt.put("heatblock.zone2.temperature", heatBlock->zone2Temperature());
    }

    JSONHandler::createData(requestPt, responsePt);
}
