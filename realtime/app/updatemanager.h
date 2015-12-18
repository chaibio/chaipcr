#ifndef UPDATEMANAGER_H
#define UPDATEMANAGER_H

#include <memory>
#include <atomic>
#include <thread>
#include <mutex>
#include <atomic>

//Can't use here std::condition_variable because wait_for/wait_until requires newer gcc
#include <Poco/Condition.h>

namespace Poco { class Timer; namespace Net { class HTTPClientSession; } }

class DBControl;

class UpdateManager
{
public:
    enum UpdateState
    {
        Unknown,
        Unavailable,
        Available,
        Downloading,
        Updating
    };

    UpdateManager(std::shared_ptr<DBControl> dbControl);
    ~UpdateManager();

    inline UpdateState updateState() const { return _updateState; }

    void start();

    bool checkUpdates();

    void stopDownload();

private:
    void checkUpdates(Poco::Timer &timer);

    void downlaod(std::string imageUrl, std::string checksum);
    bool downlaod(const std::string &imageUrl);

    bool checkFileChecksum(const std::string &checksum);

private:
    std::shared_ptr<DBControl> _dbControl;

    Poco::Timer *_updateTimer;
    Poco::Net::HTTPClientSession *_httpClient;

    std::atomic<UpdateState> _updateState;

    Poco::Condition _updateCheckCondition;

    std::recursive_mutex _downloadMutex;
    std::thread _downloadThread;
    int _downloadEventFd;
};

#endif // UPDATEMANAGER_H
