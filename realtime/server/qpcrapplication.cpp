#include "pcrincludes.h"
#include "qpcrapplication.h"

#include <Poco/Thread.h>
#include <Poco/Net/HTTPServer.h>
#include "qpcrrequesthandlerfactory.h"

#include "maincontrollers.h"

using namespace Poco::Net;
using namespace Poco::Util;

// Class QPCRApplication
void QPCRApplication::initialize(Application&)
{
    spiPort0_ = new SPIPort(kSPI0DevicePath);
    spiPort0DataInSensePin_ = new GPIO(kSPI0DataInSensePinNumber, GPIO::kInput);

    controlUnits.push_back(boost::static_pointer_cast<IControl>(ADCControllerInstance::getInstance(
                                                                    kLTC2444CSPinNumber, this->spiPort0(), kSPI0DataInSensePinNumber
                                                                    )));
    controlUnits.push_back(boost::static_pointer_cast<IControl>(HeatBlockInstance::getInstance()));
    controlUnits.push_back(boost::static_pointer_cast<IControl>(HeatSinkInstace::getInstance()));
    controlUnits.push_back(boost::static_pointer_cast<IControl>(OpticsInstance::getInstance()));
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
