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
    spiPort0_ = new SPIPort(kSPI0DevicePath);
    spiPort0DataInSensePin_ = new GPIO(kSPI0DataInSensePinNumber, GPIO::kInput);

    controlUnits.push_back(static_pointer_cast<IControl>(ADCControllerInstance::createInstance(
                                                                    kLTC2444CSPinNumber, this->spiPort0(), kSPI0DataInSensePinNumber
                                                                    )));
    controlUnits.push_back(static_pointer_cast<IControl>(HeatBlockInstance::createInstance()));
    controlUnits.push_back(static_pointer_cast<IControl>(HeatSinkInstace::createInstance()));
    controlUnits.push_back(static_pointer_cast<IControl>(OpticsInstance::createInstance()));
}

int QPCRApplication::main(const vector<string>&)
{
	HTTPServer server(new QPCRRequestHandlerFactory, ServerSocket(kHttpServerPort), new HTTPServerParams);

	server.start();

    while (true)  // true will be changed with "status" variable
    {
        for(auto controlUnit : controlUnits )
            controlUnit->process();
    }

    delete spiPort0_;
    delete spiPort0DataInSensePin_;

	server.stop();

	return Application::EXIT_OK;
}
