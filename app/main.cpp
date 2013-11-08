#include "pcrincludes.h"
#include "qpcrcycler.h"

#include <iostream>

using namespace std;

int main(int argc, char** argv) {
	chaistatus_t res;
	
	QPCRCycler* qpcrCycler = QPCRCycler::instance();
	
	while (qpcrCycler->loop()) {}
	
	return 0;
}
	
