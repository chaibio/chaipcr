#include "pcrincludes.h"
#include "boostincludes.h"
#include "pocoincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

#include "statushandler.h"

void StatusHandler::createData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt) {
    std::shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();
    std::shared_ptr<Optics> optics = OpticsInstance::getInstance();
    std::shared_ptr<Lid> lid = LidInstance::getInstance();

    if (heatBlock) {
        responsePt.put("heatblock.zone1.temperature", heatBlock->zone1Temperature());
        responsePt.put("heatblock.zone2.temperature", heatBlock->zone2Temperature());
    }

    if(lid) {
        responsePt.put("lid.temperature", lid->currentTemperature());
    }

    if (optics) {
        responsePt.put("optics.intensity", optics->getLedController()->intensity());
        responsePt.put("optics.collectData", optics->collectData());
        responsePt.put("optics.lidOpen", optics->lidOpen());
    }

    JSONHandler::createData(requestPt, responsePt);
}
