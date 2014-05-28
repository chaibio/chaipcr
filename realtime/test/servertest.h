#ifdef TEST_BUILD

#ifndef SERVERTEST_H
#define SERVERTEST_H

#include "apptest.h"

namespace Poco
{
namespace Net
{
class HTTPClientSession;
}
}

class ServerTest : public AppTest
{
protected:
    ServerTest();
    ~ServerTest();

    void testStatus();

private:
    Poco::Net::HTTPClientSession *_clientSession;

};

#endif // SERVERTEST_H
#endif // TEST_BUILD
