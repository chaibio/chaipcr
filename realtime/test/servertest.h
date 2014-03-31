#ifdef TEST_BUILD

#ifndef SERVERTEST_H
#define SERVERTEST_H

#include <gtest/gtest.h>

namespace Poco
{
namespace Net
{
class HTTPClientSession;
}
}

class ServerTest : public testing::Test
{
protected:
    ServerTest();
    ~ServerTest();

    void testStatus();

private:
    QPCRApplication _app;
    std::thread _appThread;

    Poco::Net::HTTPClientSession *_clientSession;

};

#endif // SERVERTEST_H
#endif // TEST_BUILD
