#include "pcrincludes.h"
#include "qpcrcycler.h"

#include <iostream>

using namespace std;

int main() {
	QPCRCycler* qpcrCycler = QPCRCycler::instance();
	
	while (qpcrCycler->loop()) {}
}
	
