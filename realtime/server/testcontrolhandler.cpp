#include "testcontrolhandler.h"

#include "icontrol.h"
#include "maincontrollers.h"
#include "ledcontroller.h"

using namespace Poco::Net;
using namespace boost::property_tree;
using namespace std;

void TestControlHandler::createData(const ptree &requestPt, ptree &)
{
    double ledIntensity = requestPt.get<double>("ledIntensity", -1);
    double fanRPM = requestPt.get<double>("fanRPM", -1);

    if (ledIntensity != -1)
    {
        OpticsInstance::getInstance()->getLedController()->setIntensity(50);
    }

    if (fanRPM != -1)
    {
        HeatSinkInstace::getInstance()->getFan()->setTargetRPM(fanRPM);
    }
}
