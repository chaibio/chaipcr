#include "pcrincludes.h"
#include "boostincludes.h"
#include "pocoincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

#include "testcontrolhandler.h"

using namespace std;
using namespace boost::property_tree;
using namespace Poco::Net;

void TestControlHandler::processData(const ptree &requestPt, ptree &responsePt)
{
    processOptics(requestPt, responsePt);
    processLid(requestPt, responsePt);
    processHeatSink(requestPt, responsePt);
    processHeatBlock(requestPt, responsePt);
}

void TestControlHandler::processOptics(const ptree &requestPt, ptree &)
{
    shared_ptr<Optics> optics = OpticsInstance::getInstance();

    if (optics)
    {
        double ledIntensity = requestPt.get<double>("ledIntensity", -1);
        int activateLED = requestPt.get<int>("activateLED", -1);
        bool disableLEDs = requestPt.get<bool>("disableLEDs", false);
        bool collectData = requestPt.get<bool>("collectData", false);

        if (ledIntensity != -1)
            optics->getLedController()->setIntensity(ledIntensity);

        if (activateLED != -1)
            optics->getLedController()->activateLED(activateLED);

        if (disableLEDs)
            optics->getLedController()->disableLEDs();

        optics->setCollectData(collectData);
    }
}

void TestControlHandler::processLid(const ptree &requestPt, ptree &)
{
    shared_ptr<Lid> lid = LidInstance::getInstance();

    if (lid)
    {
        double lidTargetTemp = requestPt.get<double>("lidTargetTemp", -1);

        if (lidTargetTemp != -1)
            lid->setTargetTemperature(lidTargetTemp);
    }
}

void TestControlHandler::processHeatSink(const ptree &requestPt, ptree &)
{
    shared_ptr<HeatSink> heatSink = HeatSinkInstace::getInstance();

    if (heatSink)
    {
        int fanRPM = requestPt.get<int>("fanRPM", -1);
        double heatSinkTargetTemp = requestPt.get<double>("heatSinkTargetTemp", -1);

        if (fanRPM != -1)
            heatSink->setTargetRPM(fanRPM);

        if (heatSinkTargetTemp != -1)
            heatSink->setTargetTemperature(heatSinkTargetTemp);
    }
}

void TestControlHandler::processHeatBlock(const ptree &requestPt, ptree &)
{
    shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();

    if (heatBlock)
    {
        double heatBlockTargetTemp = requestPt.get<double>("heatBlockTargetTemp", -1);

        if (heatBlockTargetTemp != -1)
        {
            heatBlock->setTargetTemperature(heatBlockTargetTemp);
            heatBlock->setEnableMode(true);
        }
    }
}
