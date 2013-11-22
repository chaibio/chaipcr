#include "pcrincludes.h"
#include "qpcrserver.h"

int main(int argc, char** argv) {
	QPCRServer server;
	return server.run(argc, argv);
	QPCRCycler* qpcrCycler = QPCRCycler::instance();
	qpcrCycler->init();
	
	while (qpcrCycler->loop()) {}
}

