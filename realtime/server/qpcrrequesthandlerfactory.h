/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef _REQUEST_HANDLER_FACTORY_H_
#define _REQUEST_HANDLER_FACTORY_H_

#include <Poco/Net/HTTPRequestHandlerFactory.h>
#include <map>
#include <boost/chrono.hpp>

////////////////////////////////////////////////////////////////////////////////
// Class QPCRRequestHandlerFactory
class QPCRRequestHandlerFactory: public Poco::Net::HTTPRequestHandlerFactory
{
public:
    virtual Poco::Net::HTTPRequestHandler* createRequestHandler(const Poco::Net::HTTPServerRequest &request);

private:
    bool checkUserAuthorization(const Poco::Net::HTTPServerRequest &request);
    bool checkUserAuthorization(std::string token);

    int getCachedUserId(const std::string &token);
    void addCachedUser(const std::string &token, int id);

private:
    struct CachedUser
    {
        CachedUser(int id)
        {
            this->id = id;
            cacheTime = boost::chrono::steady_clock::now();
        }

        int id;
        boost::chrono::steady_clock::time_point cacheTime;
    };

    std::map<std::string, CachedUser> _cachedUsers;
};

#endif
