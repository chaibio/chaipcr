#include "pcrincludes.h"
#include "controlincludes.h"

#include "testcontrolhandler.h"

using namespace std;
using namespace boost::property_tree;
using namespace Poco::Net;

void TestControlHandler::processData(Poco::Net::HTTPServerRequest &, Poco::Net::HTTPServerResponse &, const ptree &requestPt, ptree &)
{
    processOptics(requestPt);
    processLid(requestPt);
    processHeatSink(requestPt);
    processHeatBlock(requestPt);
}

void TestControlHandler::processOptics(const ptree &requestPt)
{
    shared_ptr<Optics> optics = OpticsInstance::getInstance();

    if (optics)
    {
        ptree::const_assoc_iterator ledIntensity = requestPt.find("ledIntensity");
        ptree::const_assoc_iterator activateLED = requestPt.find("activateLED");
        ptree::const_assoc_iterator disableLEDs = requestPt.find("disableLEDs");
        ptree::const_assoc_iterator photodiodeMuxChannel = requestPt.find("photodiodeMuxChannel");

        if (ledIntensity != requestPt.not_found())
            optics->getLedController()->setIntensity(ledIntensity->second.get_value<double>());

        if (activateLED != requestPt.not_found())
            optics->getLedController()->activateLED(kWellList.at(activateLED->second.get_value<int>()));

        if (disableLEDs != requestPt.not_found())
            optics->getLedController()->disableLEDs();

        if (photodiodeMuxChannel != requestPt.not_found())
            optics->getPhotodiodeMux().setChannel(photodiodeMuxChannel->second.get_value<int>());
    }
}

void TestControlHandler::processLid(const ptree &requestPt)
{
    shared_ptr<Lid> lid = LidInstance::getInstance();

    if (lid)
    {
        ptree::const_assoc_iterator lidTargetTemp = requestPt.find("lidTargetTemp");
        ptree::const_assoc_iterator lidDrive = requestPt.find("lidDrive");

        if (lidTargetTemp != requestPt.not_found())
        {
            lid->setTargetTemperature(lidTargetTemp->second.get_value<double>());
            lid->setEnableMode(true);
        }

        if (lidDrive != requestPt.not_found())
            lid->setOutput(lidDrive->second.get_value<double>());
    }
}

void TestControlHandler::processHeatSink(const ptree &requestPt)
{
    shared_ptr<HeatSink> heatSink = HeatSinkInstance::getInstance();

    if (heatSink)
    {
        ptree::const_assoc_iterator heatSinkTargetTemp = requestPt.find("heatSinkTargetTemp");

        if (heatSinkTargetTemp != requestPt.not_found())
            heatSink->setTargetTemperature(heatSinkTargetTemp->second.get_value<double>());
    }
}

void TestControlHandler::processHeatBlock(const ptree &requestPt)
{
    shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();

    if (heatBlock)
    {
        ptree::const_assoc_iterator heatBlockTargetTemp = requestPt.find("heatBlockTargetTemp");
        ptree::const_assoc_iterator heatBlockDrive = requestPt.find("heatBlockDrive");

        if (heatBlockTargetTemp != requestPt.not_found())
        {
            heatBlock->setTargetTemperature(heatBlockTargetTemp->second.get_value<double>());
            heatBlock->setEnableMode(true);
        }

        if (heatBlockDrive != requestPt.not_found())
            heatBlock->setDrive(heatBlockDrive->second.get_value<double>());
    }
}
