#include "pcrincludes.h"
#include "boostincludes.h"
#include "pocoincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

#include "testcontrolhandler.h"

using namespace std;
using namespace boost::property_tree;
using namespace Poco::Net;

void TestControlHandler::createData(const ptree &requestPt, ptree &)
{
    double ledIntensity = requestPt.get<double>("ledIntensity", -1);
    double fanRPM = requestPt.get<double>("fanRPM", -1);

    if (ledIntensity != -1)
    {
        shared_ptr<Optics> instance = OpticsInstance::getInstance();
        if (instance)
            instance->getLedController()->setIntensity(50);
    }

    if (fanRPM != -1)
    {
        shared_ptr<HeatSink> instance = HeatSinkInstace::getInstance();
        if (instance)
            instance->getFan()->setTargetRPM(fanRPM);
    }
}
