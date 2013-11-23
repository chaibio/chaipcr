#include "pcrincludes.h"
#include "qpcrserver.h"

using namespace Poco::Util;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRServer
int QPCRServer::main(const vector<string>& args) {
	waitForTerminationRequest();

	return Application::EXIT_OK;
}
/*
 * 	QPCRCycler* qpcrCycler = QPCRCycler::instance();
	qpcrCycler->init();

	while (qpcrCycler->loop()) {}
 */
