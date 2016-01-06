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

    void upload(std::istream &dataStream);
    void stopDownload();

private:
    void checkUpdateCallback();

    void downlaod(std::string imageUrl, std::string checksum, std::string apiPassword);
    bool downlaod(const std::string &imageUrl, const std::string &apiPassword);

    bool checkFileChecksum(const std::string &checksum);

    bool checkMountPoint();
    bool checkSdcard();

private:
    std::shared_ptr<DBControl> _dbControl;
    Poco::Net::HTTPClientSession *_httpClient;

    Poco::Util::Timer *_updateTimer;

    std::atomic<UpdateState> _updateState;

    std::recursive_mutex _downloadMutex;
    std::thread _downloadThread;
    int _downloadEventFd;

    Poco::Event _updateEvent;
    Poco::Event _uploadEvent;
};

#endif // UPDATEMANAGER_H
