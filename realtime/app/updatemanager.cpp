#include "updatemanager.h"
#include "constants.h"
#include "dbcontrol.h"
#include "upgrade.h"
#include "qpcrapplication.h"
#include "util.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <functional>

#include <sys/eventfd.h>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include <Poco/File.h>
#include <Poco/Util/Timer.h>
#include <Poco/Util/TimerTaskAdapter.h>
#include <Poco/Net/HTTPRequest.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Net/HTTPClientSession.h>

#define DOWNLOAD_BUFFER_SIZE 8192

class CheckTimerTask : public Poco::Util::TimerTask
{
public:
    CheckTimerTask(std::function<void()> runFunction, Poco::Event &event): _runFunction(runFunction), _event(event) {}

protected:
    void run()
    {
        _runFunction();
        _event.set();
    }

private:
    std::function<void()> _runFunction;
    Poco::Event &_event;
};

UpdateManager::UpdateManager(std::shared_ptr<DBControl> dbControl):
    _updateEvent(false)
{
    _downloadEventFd = eventfd(0, EFD_NONBLOCK);

    if (_downloadEventFd == -1)
        throw std::system_error(errno, std::generic_category(), "UpdateManager::UpdateManager - unable to create event fd:");

    _dbControl = dbControl;
    _httpClient = new Poco::Net::HTTPClientSession(kUpdateHost);
    _updateTimer = new Poco::Util::Timer();
    _updateState = Unknown;
}

UpdateManager::~UpdateManager()
{
    delete _updateTimer;
    delete _httpClient;

    stopDownload();
    close(_downloadEventFd);
}

void UpdateManager::startChecking()
{
    stopChecking();

    _updateTimer->schedule(Poco::Util::TimerTask::Ptr(new CheckTimerTask(std::bind(&UpdateManager::checkUpdateCallback, this), _updateEvent)), 0, kUpdateInterval);
}

void UpdateManager::stopChecking(bool wait)
{
    _updateTimer->cancel(wait);
}

bool UpdateManager::checkUpdate()
{
    Poco::Util::TimerTask::Ptr task(new CheckTimerTask(std::bind(&UpdateManager::checkUpdateCallback, this), _updateEvent));

    _updateEvent.reset();
    _updateTimer->schedule(task, Poco::Timestamp(0));

    try
    {
        _updateEvent.wait(15 * 1000);
    }
    catch (const Poco::TimeoutException &/*ex*/)
    {
        task->cancel();

        return false;
    }

    return true;
}

bool UpdateManager::update()
{
    UpdateState state = Available;

    if (_updateState.compare_exchange_strong(state, Updating))
    {
        system(kUpdateScriptPath.c_str());

        return true;
    }

    return false;
}

void UpdateManager::download(std::istream &dataStream)
{
    std::unique_lock<std::recursive_mutex> lock(_downloadMutex);

    stopDownload();

    UpdateState state = _updateState.exchange(ManualDownloading);

    if (state != Updating && state != ManualDownloading)
    {
        lock.unlock();

        std::ofstream file(kUpdateFilePath.c_str(), std::ofstream::out | std::ofstream::trunc | std::ofstream::binary);

        if (file.is_open())
        {
            char buffer[DOWNLOAD_BUFFER_SIZE];

            while (dataStream.good() && file.good())
            {
                std::fill(std::begin(buffer), std::end(buffer), 0);

                dataStream.read(buffer, DOWNLOAD_BUFFER_SIZE);

                if (dataStream.gcount() > 0)
                    file.write(buffer, dataStream.gcount());
            }

            if (dataStream.eof())
                _updateState = Available;
            else
                _updateState = Unknown;
        }
        else
        {
            std::cout << "UpdateManager::download - unable to open file " << kUpdateFilePath << ": " << std::strerror(errno) << '\n';

            _updateState = Unknown;
        }
    }
    else if (state != ManualDownloading)
    {
        state = ManualDownloading;

        _updateState.compare_exchange_strong(state, Updating);
    }
}

void UpdateManager::stopDownload()
{
    std::lock_guard<std::recursive_mutex> lock(_downloadMutex);

    if (_downloadThread.joinable())
    {
        uint64_t i = 1;
        write(_downloadEventFd, &i, sizeof(i));

        _downloadThread.join();

        //Clear event fd
        read(_downloadEventFd, &i, sizeof(i));

        UpdateState state = Downloading;
        _updateState.compare_exchange_strong(state, Unknown); //In case the downloading thread has set the state
    }
}

void UpdateManager::checkUpdateCallback()
{
    stopDownload();

    Upgrade upgrade;
    std::string imageUrl;
    UpdateState state = _updateState;

    if (state == ManualDownloading || state == Updating)
        return;

    try
    {
        Poco::Net::HTTPRequest request("GET", kUpdatesUrl);
        Poco::Net::HTTPResponse response;

        _httpClient->sendRequest(request);

        boost::property_tree::ptree ptree;
        boost::property_tree::read_json(_httpClient->receiveResponse(response), ptree);

        upgrade.setVersion(ptree.get<std::string>("software_version"));
        upgrade.setChecksum(ptree.get<std::string>("software_checksum"));
        upgrade.setBriedDescription(ptree.get<std::string>("brief_description"));
        upgrade.setFullDescription(ptree.get<std::string>("full_description"));
        upgrade.setReleaseDate(Util::parseIsoTime(ptree.get<std::string>("release_date")));

        imageUrl = ptree.get<std::string>("image_url");

        _dbControl->updateUpgrade(upgrade);
    }
    catch (const std::exception &ex)
    {
        std::cout << "UpdateManager::checkUpdateCallback - " << ex.what() << '\n';

        _httpClient->reset();
        _updateState.compare_exchange_strong(state, Unknown);

        return;
    }

    if (qpcrApp.settings().configuration.version != upgrade.version())
    {
        std::lock_guard<std::recursive_mutex> lock(_downloadMutex);

        if (_updateState.compare_exchange_strong(state, Downloading))
            _downloadThread = std::thread(static_cast<void(UpdateManager::*)(std::string,std::string)>(&UpdateManager::downlaod), this, imageUrl, upgrade.checksum());
    }
    else
        _updateState.compare_exchange_strong(state, Unavailable);
}

void UpdateManager::downlaod(std::string imageUrl, std::string checksum)
{
    _updateState = Downloading;

    try
    {
        if (downlaod(imageUrl) && checkFileChecksum(checksum))
            _updateState = Available;
        else
            _updateState = Unknown;
    }
    catch (const std::exception &ex)
    {
        std::cout << "UpdateManager::downlaod - " << ex.what() << '\n';

        _updateState = Unknown;
    }
}

bool UpdateManager::downlaod(const std::string &imageUrl)
{
    std::stringstream stream;
    stream << "sshpass -p \'" << kUpdatePassword << "\' rsync -a --checksum --no-whole-file --inplace " << imageUrl << " " << kUpdateFilePath;

    return Util::watchProcess(stream.str(), _downloadEventFd, [](const char buffer[]){ std::cout << "UpdateManager::downlaod - rsync:" << buffer << '\n'; });
}

bool UpdateManager::checkFileChecksum(const std::string &checksum)
{
    std::stringstream stream;
    stream << "sha256sum " << kUpdateFilePath;

    std::string sum;

    if (Util::watchProcess(stream.str(), _downloadEventFd, [&sum](const char buffer[]){ std::stringstream stream; stream << buffer; sum.clear(); stream >> sum; }))
        return checksum == sum;
    else
        return false;
}
