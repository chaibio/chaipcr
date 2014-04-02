#include "pcrincludes.h"
#include "utilincludes.h"
#include "pocoincludes.h"
#include "controlincludes.h"

#include "qpcrrequesthandlerfactory.h"
#include "qpcrapplication.h"

using namespace std;
using namespace Poco::Net;
using namespace Poco::Util;

// Class QPCRApplication
void QPCRApplication::initialize(Application&)
{
    controlUnits.push_back(static_pointer_cast<IControl>(OpticsInstance::createInstance(move(SPIPort(kSPI1DevicePath)))));

    auto heatBlock = HeatBlockInstance::createInstance();
    controlUnits.push_back(static_pointer_cast<IControl>(heatBlock));

    //ADC Controller
    vector<shared_ptr<ADCConsumer>> consumers = {nullptr, heatBlock->zone1Thermistor(), heatBlock->zone2Thermistor(), nullptr};
    controlUnits.push_back(static_pointer_cast<IControl>(ADCControllerInstance::createInstance(consumers,
                                                                    kLTC2444CSPinNumber, std::move(SPIPort(kSPI0DevicePath)), kSPI0DataInSensePinNumber
                                                                    )));
}

int QPCRApplication::main(const vector<string>&)
{
	HTTPServer server(new QPCRRequestHandlerFactory, ServerSocket(kHttpServerPort), new HTTPServerParams);

    server.start();

    workState = true;
    while (workState)
    {
        for(auto controlUnit : controlUnits)
            controlUnit->process();
    }

	server.stop();

	return Application::EXIT_OK;
}
