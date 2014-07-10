#ifdef TEST_BUILD

#include "pcrincludes.h"
#include "boostincludes.h"
#include "pocoincludes.h"

#include "servertest.h"

using namespace boost::property_tree;
using namespace Poco;
using namespace Poco::Net;

ServerTest::ServerTest()
{
    _clientSession = new HTTPClientSession("localhost", kHttpServerPort);
}

ServerTest::~ServerTest()
{
    delete _clientSession;
}

void ServerTest::testStatus()
{
    HTTPRequest request(HTTPRequest::HTTP_GET, "/status");
    _clientSession->sendRequest(request);

    HTTPResponse response;
    std::istream &responseStream = _clientSession->receiveResponse(response);

    ASSERT_TRUE(response.getStatus() == HTTPResponse::HTTP_OK);

    try
    {
        ptree responsePt;
        read_json(responseStream, responsePt);

        if (!responsePt.get<bool>("status.status"))
            throw std::logic_error(responsePt.get<std::string>("status.error"));
    }
    catch (json_parser_error &ex)
    {
        FAIL() << "JSON error - " << ex.what() << '\n';
    }
    catch (std::exception &ex)
    {
        FAIL() << "Server error - " << ex.what() << '\n';
    }
}

TEST_F(ServerTest, status_service)
{
    testStatus();
}

#endif // TEST_BUILD
