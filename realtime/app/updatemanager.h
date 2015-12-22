#ifndef UPDATEMANAGER_H
#define UPDATEMANAGER_H

#include <memory>
#include <atomic>
#include <thread>
#include <mutex>
#include <atomic>

#include <Poco/Event.h>

namespace Poco { namespace Util { class Timer; } namespace Net { class HTTPClientSession; } }

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
        ManualDownloading,
        Updating
    };

    UpdateManager(std::shared_ptr<DBControl> dbControl);
    ~UpdateManager();

    inline UpdateState updateState() const { return _updateState; }

    void startChecking();
    void stopChecking(bool wait = true);

    bool checkUpdate();

    bool update();

    void download(std::istream &dataStream);
    void stopDownload();

private:
    void checkUpdateCallback();

    void downlaod(std::string imageUrl, std::string checksum);
    bool downlaod(const std::string &imageUrl);

    bool checkFileChecksum(const std::string &checksum);

private:
    std::shared_ptr<DBControl> _dbControl;
    Poco::Net::HTTPClientSession *_httpClient;

    Poco::Util::Timer *_updateTimer;
    Poco::Event _updateEvent;

    std::atomic<UpdateState> _updateState;

    std::recursive_mutex _downalodMutex;
    std::thread _downloadThread;
    int _downloadEventFd;
};

#endif // UPDATEMANAGER_H
