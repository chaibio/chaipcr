#include "pcrincludes.h"
#include "qpcrserver.h"

////////////////////////////////////////////////////////////////////////////////
// Class QPCRServer
int QPCRServer::main(const vector<string>& args) {
	waitForTerminationRequest();

	return Application::EXIT_OK;
}
