#include "testcontrolhandler.h"

using namespace Poco::Net;
using namespace boost::property_tree;
using namespace std;

void TestControlHandler::createData(const ptree &requestPt, ptree &) throw()
{
    double ledIntensity = requestPt.get<double>("ledIntensity", -1);
    double fanRPM = requestPt.get<double>("fanRPM", -1);

    if (ledIntensity != -1)
    {

    }

    if (fanRPM != -1)
    {

    }
}
