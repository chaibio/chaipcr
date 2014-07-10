#ifdef TEST_BUILD

#include "pcrincludes.h"

#include "apptest.h"

AppTest::AppTest()
{
    _appThread = std::thread( [this](){ this->_app.run({"realtime"});} );

    while (!_app.isWorking());
}

AppTest::~AppTest()
{
    _app.close();
    _appThread.join();
}

#endif // TEST_BUILD
