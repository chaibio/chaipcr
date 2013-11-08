#include "pcrincludes.h"
#include "qpcrcycler.h"

#include <iostream>

using namespace std;

int main(int argc, char** argv) {
	chaistatus_t res;
	
	QPCRCycler* qpcrCycler = QPCRCycler::instance();
	res = qpcrCycler->init();
	if (res != kSuccess) {
		cout << "Unable to initialize QPCR Cycler, failed with error code " << res << ", aborting" << endl;
		return 1;
	}
	
	
	while (qpcrCycler->loop()) {}
	
	cerr << "Main loop terminated with error code " << res << endl;
	return 1;
}
