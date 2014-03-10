#include "pcrincludes.h"
#include "qpcrapplication.h"

#ifdef TEST_BUILD
#include "servertest.h"
#endif

int main(int argc, char** argv) {
#ifndef TEST_BUILD
    QPCRApplication server;
	return server.run(argc, argv);
#else
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
#endif
}
