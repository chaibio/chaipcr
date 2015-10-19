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

    int getCachedUserId(const std::string &token);
    void addCachedUser(const std::string &token, int id);

private:
    struct CachedUser
    {
        CachedUser(int id)
        {
            this->id = id;
            cacheTime = boost::chrono::system_clock::now();
        }

        int id;
        boost::chrono::system_clock::time_point cacheTime;
    };

    std::map<std::string, CachedUser> _cachedUsers;
};

#endif
