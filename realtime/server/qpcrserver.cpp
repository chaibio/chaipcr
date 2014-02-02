#include "pcrincludes.h"
#include "qpcrserver.h"

#include <Poco/Thread.h>
#include <Poco/Net/HTTPServer.h>
#include "RequestHandlerFactory.h"
#include "qpcrcycler.h"

using namespace Poco::Net;
using namespace Poco::Util;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRServer
void QPCRServer::initialize(Application&) {
	QPCRCycler* qpcrCycler = QPCRCycler::instance();
	qpcrCycler->init();
}

int QPCRServer::main(const vector<string>&) {
	//start cycler
	Poco::Thread cyclerThread;
	cyclerThread.start(*QPCRCycler::instance());

	HTTPServer server(new QPCRRequestHandlerFactory, ServerSocket(kHttpServerPort), new HTTPServerParams);

	server.start();
	waitForTerminationRequest();
	server.stop();

	return Application::EXIT_OK;
}
