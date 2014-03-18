#include "pcrincludes.h"
#include "boostincludes.h"
#include "pocoincludes.h"

#include "qpcrapplication.h"
#include "servertest.h"

using namespace boost::property_tree;
using namespace Poco;
using namespace Poco::Net;

ServerTest::ServerTest()
{
    _appThread = std::thread( [this](){ this->_app.run(std::vector<std::string>({"realtime"}));} );

    while (!_app.isWorking());

    _clientSession = new HTTPClientSession("localhost", kHttpServerPort);
}

ServerTest::~ServerTest()
{
    delete _clientSession;

    _app.close();
    _appThread.join();
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
        //std::cout << "JSON error - " << ex.what() << '\n';
        //ASSERT_TRUE(false);

        FAIL() << "JSON error - " << ex.what() << '\n';
    }
    catch (std::exception &ex)
    {
        //std::cout << "Server error - " << ex.what() << '\n';
        //ASSERT_TRUE(false);

        FAIL() << "Server error - " << ex.what() << '\n';
    }
}

TEST_F(ServerTest, status_service)
{
    testStatus();
}
