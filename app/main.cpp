#include "pcrincludes.h"
#include "qpcrcycler.h"

#include <iostream>

int main(int argc, char** argv) {
	chaistatus_t res;
	
	QPCRCycler* qpcrCycler = QPCRCycler::qpcrCycler();
	res = qpcrCycler->init();
	if (res != kSuccess) {
		cerr << "Unable to initialize QPCR Cycler, failed with error code " << res << ", aborting") << endl;
		return 1;
	}
	
	
	while (qpcrCycler->loop() == kSuccess) {}
	
	cerr << "Main loop terminated with error code " << res << endl;
	return 1;
}