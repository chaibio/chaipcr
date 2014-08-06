#include <Poco/Net/HTTPServer.h>

#include "pcrincludes.h"
#include "icontrol.h"
#include "experimentcontroller.h"
#include "qpcrrequesthandlerfactory.h"
#include "qpcrfactory.h"
#include "qpcrapplication.h"

using namespace std;
using namespace Poco::Net;
using namespace Poco::Util;

// Class QPCRApplication
QPCRApplication* QPCRApplication::_instance = nullptr;

QPCRApplication::~QPCRApplication() {
    _instance = nullptr;
}

void QPCRApplication::initialize(Application&) {
    _instance = this;
    _workState = false;

    _controlUnits = QPCRFactory::constructMachine();
    _experimentController = ExperimentController::createInstance();
}

int QPCRApplication::main(const vector<string>&) {
	HTTPServer server(new QPCRRequestHandlerFactory, ServerSocket(kHttpServerPort), new HTTPServerParams);
    server.start();

    _workState = true;
    while (_workState) {
        for(auto controlUnit: _controlUnits)
            controlUnit->process();
    }

	server.stop();

	return Application::EXIT_OK;
}
