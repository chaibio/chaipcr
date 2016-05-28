//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#ifdef TEST_BUILD

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <Poco/Net/HTTPRequest.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Net/HTTPClientSession.h>

#include "pcrincludes.h"
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
