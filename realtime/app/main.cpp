#include "pcrincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

#include "qpcrapplication.h"

int main(int argc, char** argv) {
    QPCRApplication server;
	return server.run(argc, argv);
}
