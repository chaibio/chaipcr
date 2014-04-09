#include "pcrincludes.h"
#include "utilincludes.h"
#include "pocoincludes.h"
#include "controlincludes.h"

#include "qpcrrequesthandlerfactory.h"
#include "qpcrapplication.h"
#include "qpcrfactory.h"

using namespace std;
using namespace Poco::Net;
using namespace Poco::Util;

// Class QPCRApplication
void QPCRApplication::initialize(Application&) {
    QPCRFactory::constructMachine(controlUnits);
}

int QPCRApplication::main(const vector<string>&) {
	HTTPServer server(new QPCRRequestHandlerFactory, ServerSocket(kHttpServerPort), new HTTPServerParams);
    server.start();

    workState = true;
    while (workState) {
        for(auto controlUnit: controlUnits)
            controlUnit->process();
    }

	server.stop();

	return Application::EXIT_OK;
}
