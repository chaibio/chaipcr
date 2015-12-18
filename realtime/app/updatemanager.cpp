#include "updatemanager.h"
#include "constants.h"
#include "dbcontrol.h"
#include "upgrade.h"
#include "qpcrapplication.h"
#include "util.h"

#include <iostream>
#include <sstream>

#include <sys/eventfd.h>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include <Poco/File.h>
#include <Poco/Timer.h>
#include <Poco/Net/HTTPRequest.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Net/HTTPClientSession.h>

UpdateManager::UpdateManager(std::shared_ptr<DBControl> dbControl)
{
    _dbControl = dbControl;
    _updateTimer = new Poco::Timer();
    _httpClient = new Poco::Net::HTTPClientSession(kUpdagesHost);
    _updateState = Unknown;
    _downloadEventFd = eventfd(0, EFD_NONBLOCK);

    if (_downloadEventFd == -1)
        throw std::system_error(errno, std::generic_category(), "UpdateManager::UpdateManager - unable to create event fd:");
}

UpdateManager::~UpdateManager()
{
    stopDownload();

    delete _updateTimer;
    delete _httpClient;

    close(_downloadEventFd);
}

void UpdateManager::start()
{
    _updateTimer->setPeriodicInterval(kAppUpdageInterva);
    _updateTimer->start(Poco::TimerCallback<UpdateManager>(*this, &UpdateManager::checkUpdates));
}

bool UpdateManager::checkUpdates()
{
    UpdateState state = _updateState;

    if (state != Downloading && state != Updating)
    {
        _updateTimer->stop();

        start();

        try
        {
            Poco::FastMutex tmpMutex;

            _updateCheckCondition.wait(tmpMutex, 15 * 1000);

            return true;
        }
        catch (const Poco::TimeoutException &/*ex*/)
        {
            return false;
        }
    }

    return true;
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

        _updateState = Unknown;
    }
}

void UpdateManager::checkUpdates(Poco::Timer &/*timer*/)
{
    try
    {
        Poco::Net::HTTPRequest request("GET", kChecUpdatesUri);
        _httpClient->sendRequest(request);

        Poco::Net::HTTPResponse response;
        boost::property_tree::ptree ptree;

        boost::property_tree::read_json(_httpClient->receiveResponse(response), ptree);

        Upgrade upgrade;
        upgrade.setVersion(ptree.get<std::string>("software_version"));
        upgrade.setChecksum(ptree.get<std::string>("software_checksum"));
        upgrade.setBriedDescription(ptree.get<std::string>("brief_description"));
        upgrade.setFullDescription(ptree.get<std::string>("full_description"));
        upgrade.setReleaseDate(Util::parseIsoTime(ptree.get<std::string>("release_date")));

        if (qpcrApp.settings().configuration.version != upgrade.version())
        {
            _dbControl->updateUpgrade(upgrade);

            {
                std::lock_guard<std::recursive_mutex> lock(_downloadMutex);

                if (_updateState != Updating)
                {
                    stopDownload();

                    _updateState = Downloading;
                    _downloadThread = std::thread(static_cast<void(UpdateManager::*)(std::string,std::string)>(&UpdateManager::downlaod), this, ptree.get<std::string>("image_url"), upgrade.checksum());
                }
            }
        }
        else
            _updateState = Unavailable;
    }
    catch (const std::exception &ex)
    {
        std::cout << "UpdateManager::checkUpdates - " << ex.what() << '\n';

        _httpClient->reset();
        _updateState = Unknown;
    }

    _updateCheckCondition.broadcast();
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
    stream << "sshpass -p \'" << kUpdateApiPassword << "\' rsync --inplace " << imageUrl << " " << kUpdateFilePath;

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
