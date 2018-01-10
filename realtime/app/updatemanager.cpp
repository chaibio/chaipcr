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

#include "updatemanager.h"
#include "constants.h"
#include "dbcontrol.h"
#include "upgrade.h"
#include "qpcrapplication.h"
#include "util.h"
#include "logger.h"
#include "exceptions.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <functional>

#include <sys/eventfd.h>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include <Poco/File.h>
#include <Poco/URI.h>
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

class EventSetter
{
public:
    EventSetter(Poco::Event &event): event(event) { event.reset(); }
    ~EventSetter() { event.set(); }

private:
    Poco::Event &event;
};

UpdateManager::UpdateManager(std::shared_ptr<DBControl> dbControl):
    _updateEvent(false), _uploadEvent(false)
{
    _downloadEventFd = eventfd(0, EFD_NONBLOCK);

    if (_downloadEventFd == -1)
        throw std::system_error(errno, std::generic_category(), "Software update manager: unable to create event fd -");

    _dbControl = dbControl;
    _httpClient = new Poco::Net::HTTPClientSession(kUpdateHost);
    _updateTimer = new Poco::Util::Timer();
    _updateState = Unknown;
}

UpdateManager::~UpdateManager()
{
    stopDownload();
    stopChecking();

    delete _updateTimer;
    delete _httpClient;

    close(_downloadEventFd);
}

void UpdateManager::startChecking()
{
    stopChecking();

    _updateTimer->schedule(Poco::Util::TimerTask::Ptr(new CheckTimerTask(std::bind(&UpdateManager::checkUpdateCallback, this, true), _updateEvent)), 3 * 60 * 1000, kUpdateInterval);
}

void UpdateManager::stopChecking(bool wait)
{
    _updateTimer->cancel(wait);
}

bool UpdateManager::checkUpdate()
{
    if (_updateState == Available)
        return true;

    Poco::Util::TimerTask::Ptr task(new CheckTimerTask(std::bind(&UpdateManager::checkUpdateCallback, this, false), _updateEvent));

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
        std::string errorMessage;

        try
        {
            Poco::File dir(kUpdateFolder + "/scripts");
            if (dir.exists())
                dir.remove(true);

            LoggerStreams streams;

            if (!Util::watchProcess("tar xf " + kUpdateFilePath + " --directory " + kUpdateFolder + " scripts", _downloadEventFd,
                                    [&streams](const char *buffer, std::size_t size){ streams.stream("UpdateManager::update - tar (stdout)").write(buffer, size); },
                                    [&streams, &errorMessage](const char *buffer, std::size_t size){ streams.stream("UpdateManager::update - tar (stderr)").write(buffer, size);
                                                                                                     errorMessage.append(buffer, buffer + size); }))
            {
                return false; //This will happen only if the app is getting closed
            }
        }
        catch (...)
        {
            if (errorMessage.find("This does not look like a tar archive") != std::string::npos)
                setLastErrorAndThrow(ErrorInfo(ErrorInfo::InvalidImage, "Invalid upgrade image"));
            else
                setLastErrorAndThrow(ErrorInfo(ErrorInfo::UnknownError, "Unable to extract image"));
        }

        try
        {
            Poco::File file(kUpdateScriptOutputPath);
            if (file.exists())
                file.remove();

            if (system((kUpdateScriptPath + ' ' + kUpdateScriptOutputPath).c_str()) != 0)
                throw std::runtime_error("perform_upgrade error");
        }
        catch (...)
        {
            std::string message;
            std::ifstream file(kUpdateScriptOutputPath);

            if (file.is_open())
            {
                std::getline(file, message);

                if (message == "Incompatable upgrade image: No checksum file found!" || message == "Checksum error!")
                    setLastErrorAndThrow(ErrorInfo(ErrorInfo::InvalidImage, "Invalid upgrade image"));
                else
                    setLastErrorAndThrow(ErrorInfo(ErrorInfo::UnknownError, message));
            }
            else
                setLastErrorAndThrow(ErrorInfo(ErrorInfo::UnknownError, "Unknown upgrade error"));
        }

        return true;
    }

    return false;
}

void UpdateManager::upload(std::istream &dataStream)
{
    std::unique_lock<std::recursive_mutex> lock(_downloadMutex);

    stopDownload();

    UpdateState state = _updateState.exchange(ManualDownloading);

    if (state != Updating && state != ManualDownloading)
    {
        try
        {
            EventSetter eventSetter(_uploadEvent);

            lock.unlock();

            try
            {
                int result = checkMountPoint();

                if (result == -1)
                {
                    setLastErrorAndThrow(ErrorInfo(ErrorInfo::UnknownError, "Unknown error (" + std::to_string(kUpdateMoundPointError) + ")"));
                    return;
                }
                else if (result == 0)
                {
                    clearLastError(true);
                    return;
                }
            }
            catch (const std::exception &ex)
            {
                APP_LOGGER << "UpdateManager::upload - checkMountPoint: " << ex.what() << std::endl;

                setLastErrorAndThrow(ErrorInfo(ErrorInfo::UnknownError, "Unknown error (" + std::to_string(kUpdateMoundPointError) + ")"));

                return;
            }

            try
            {
                if (!checkSdcard())
                {
                    clearLastError(true);
                    return;
                }
            }
            catch (const std::exception &ex)
            {
                APP_LOGGER << "UpdateManager::upload - checkSdcard: " << ex.what() << std::endl;

                setLastErrorAndThrow(ErrorInfo(ErrorInfo::UnknownError, "Unknown error (" + std::to_string(kUpdateSdcardError) + ")"));

                return;
            }

            _dbControl->setUpgradeDownloaded(false);

            uint64_t i = 0;
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

                    read(_downloadEventFd, &i, sizeof(i));
                    if (i > 0)
                        break;
                }

                if (dataStream.eof())
                    _updateState = Available;
                else
                {
                    _updateState = Unknown;

                    if (!dataStream.good() || !file.good())
                    {
                        APP_LOGGER << "UpdateManager::upload - stream error" << std::endl;

                        setLastErrorAndThrow(ErrorInfo(ErrorInfo::UplodFaild, "Upload failed"), false);
                    }
                }
            }
            else
            {
                APP_LOGGER << "UpdateManager::upload - unable to open file " << kUpdateFilePath << ": " << std::strerror(errno) << std::endl;

                setLastErrorAndThrow(ErrorInfo(ErrorInfo::UnknownError, "Error opening image (" + std::to_string(errno) + ")"));
            }
        }
        catch (const std::exception &ex)
        {
            APP_LOGGER << "UpdateManager::upload - exception: " << ex.what() << std::endl;

            setLastErrorAndThrow(ErrorInfo(ErrorInfo::UnknownError, "Unknown upload error"));
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
    else if (_updateState == ManualDownloading)
    {
        uint64_t i = 1;
        write(_downloadEventFd, &i, sizeof(i));

        _uploadEvent.wait();

        //Clear event fd
        read(_downloadEventFd, &i, sizeof(i));

        UpdateState state = ManualDownloading;
        _updateState.compare_exchange_strong(state, Unknown); //In case the uploading thread has set the state
    }

    clearLastError();
}

UpdateManager::ErrorInfo UpdateManager::lastError() const
{
    Poco::RWLock::ScopedReadLock lock(_errorMutex);
    return _lastError;
}

void UpdateManager::checkUpdateCallback(bool checkHash)
{
    Upgrade upgrade;
    UpdateState state = _updateState;

    if (state == ManualDownloading || state == Updating)
        return;

    Poco::Net::HTTPResponse response;
    std::istream *responseStream = nullptr;

    try
    {
        Poco::URI uri(kUpdatesUrl);
        uri.setQueryParameters({ {"v", "1"}, {"model_number", qpcrApp.settings().device.modelNumber}, {"software_version", qpcrApp.settings().configuration.version},
                                 {"software_platform", qpcrApp.settings().configuration.platform}, {"serial_number", qpcrApp.settings().device.serialNumber} });

        Poco::Net::HTTPRequest request("GET", uri.toString());

        _httpClient->sendRequest(request);

        responseStream = &_httpClient->receiveResponse(response);
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "UpdateManager::checkUpdateCallback - request: " << ex.what() << std::endl;

        _httpClient->reset();

        if (state != Downloading)
            setLastError(ErrorInfo(ErrorInfo::NetworkError, "Unable to fetch update information"));

        return;
    }

    if (response.getStatus() != Poco::Net::HTTPResponse::HTTP_OK)
    {
        APP_LOGGER << "UpdateManager::checkUpdateCallback - response error: " << response.getStatus() << std::endl;

        _httpClient->reset();

        if (state != Downloading)
            setLastError(ErrorInfo(ErrorInfo::NetworkError, "Unable to fetch update information"));

        return;
    }

    try
    {
        boost::property_tree::ptree ptree;
        boost::property_tree::read_json(*responseStream, ptree);

        upgrade.setVersion(ptree.get<std::string>("software_version"));
        upgrade.setChecksum(ptree.get<std::string>("software_checksum"));
        upgrade.setBriedDescription(ptree.get<std::string>("brief_description"));
        upgrade.setFullDescription(ptree.get<std::string>("full_description"));
        upgrade.setReleaseDate(Util::parseIsoTime(ptree.get<std::string>("release_date")));
        upgrade.setPassword(ptree.get<std::string>("password"));
        upgrade.setImageUrl(ptree.get<std::string>("image_rsync_url"));

        std::string currentVersion;
        bool downloaded = false;

        _dbControl->getCurrentUpgrade(currentVersion, downloaded);
        _dbControl->updateUpgrade(upgrade);

        if (Util::isVersionGreater(qpcrApp.settings().configuration.version, upgrade.version()) <= 0)
        {
            if (state == Downloading)
            {
                APP_LOGGER << "UpdateManager::checkUpdateCallback - the server has returned a lower version number (" << upgrade.version() << ") while another version ("
                           << currentVersion << ") is being downloaded. Canceling the download" << std::endl;

                stopDownload();
            }

            _updateState.compare_exchange_strong(state, Unavailable);

            return;
        }

        if (Util::isVersionGreater(currentVersion, upgrade.version()) == 0)
        {
            if (downloaded)
            {
                std::string sum;

                if (!checkHash || (Util::getFileChecksum(kUpdateFilePath, _downloadEventFd, sum) && sum == upgrade.checksum()))
                {
                    _updateState.compare_exchange_strong(state, Available);
                    return;
                }
                else if (_updateState.compare_exchange_strong(state, Unknown))
                {
                    state = Unknown;

                    clearLastError();

                    _dbControl->setUpgradeDownloaded(false);
                }
            }
            else if (state == Downloading)
                return;
        }
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "UpdateManager::checkUpdateCallback - json/db: " << ex.what() << std::endl;

        if (state != Downloading)
            setLastError(ErrorInfo(ErrorInfo::UnknownError, "Unable to process update information"));

        return;
    }

    std::lock_guard<std::recursive_mutex> lock(_downloadMutex);

    stopDownload();

    state = _updateState;
    if (state == ManualDownloading || state == Updating)
        return;

    if (_updateState.compare_exchange_strong(state, Downloading))
        _downloadThread = std::thread(static_cast<void(UpdateManager::*)(Upgrade)>(&UpdateManager::downlaod), this, upgrade);
}

void UpdateManager::downlaod(Upgrade upgrade)
{
    _updateState = Downloading;

    try
    {
        int result = checkMountPoint();

        if (result == -1)
        {
            setLastError(ErrorInfo(ErrorInfo::UnknownError, "Unknown error (" + std::to_string(kUpdateMoundPointError) + ")"));
            return;
        }
        else if (result == 0)
        {
            clearLastError(true);
            return;
        }
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "UpdateManager::downlaod - checkMountPoint: " << ex.what() << std::endl;

        setLastError(ErrorInfo(ErrorInfo::UnknownError, "Unknown error (" + std::to_string(kUpdateMoundPointError) + ")"));

        return;
    }

    try
    {
        if (!checkSdcard())
        {
            clearLastError(true);
            return;
        }
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "UpdateManager::downlaod - checkSdcard: " << ex.what() << std::endl;

        setLastError(ErrorInfo(ErrorInfo::UnknownError, "Unknown error (" + std::to_string(kUpdateSdcardError) + ")"));

        return;
    }

    try
    {
        if (!downlaod(upgrade.imageUrl(), upgrade.password()))
        {
            clearLastError(true);
            return;
        }
    }
    catch (const ProcessError &ex)
    {
        APP_LOGGER << "UpdateManager::downlaod - rsync: " << ex.what() << std::endl;

        if (ex.code() == 10)
            setLastError(ErrorInfo(ErrorInfo::NetworkError, "Unable to download image"));
        else
            setLastError(ErrorInfo(ErrorInfo::UnknownError, "Unable to download image (" + std::to_string(ex.code()) + ")"));

        return;
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "UpdateManager::downlaod - downlaod: " << ex.what() << std::endl;

        setLastError(ErrorInfo(ErrorInfo::UnknownError, "Unknown error (" + std::to_string(kUpdateDownloadError) + ")"));

        return;
    }

    try
    {
        std::string sum;

        if (Util::getFileChecksum(kUpdateFilePath, _downloadEventFd, sum))
        {
            if (sum == upgrade.checksum())
            {
                _updateState = Available;
                _dbControl->setUpgradeDownloaded(true);
            }
            else
                setLastError(ErrorInfo(ErrorInfo::InvalidImage, "Invalid image checksum"));
        }
        else
            clearLastError(true);
    }
    catch (const std::exception &ex)
    {
        APP_LOGGER << "UpdateManager::downlaod - " << ex.what() << std::endl;

        setLastError(ErrorInfo(ErrorInfo::UnknownError, "Unknown error (23)"));
    }
}

bool UpdateManager::downlaod(const std::string &imageUrl, const std::string &apiPassword)
{
    LoggerStreams streams;

    std::stringstream stream;
    stream << "sshpass -p \'" << apiPassword << "\' rsync -a --checksum --no-whole-file --timeout=180 --inplace " << imageUrl << " " << kUpdateFilePath;

    return Util::watchProcess(stream.str(), _downloadEventFd,
                              [&streams](const char *buffer, std::size_t size){ streams.stream("UpdateManager::downlaod - rsync (stdout)").write(buffer, size); },
                              [&streams](const char *buffer, std::size_t size){ streams.stream("UpdateManager::downlaod - rsync (stderr)").write(buffer, size); });
}

int UpdateManager::checkMountPoint()
{
    std::string output;

    if (Util::watchProcess("cat /etc/mtab | grep " + kUpdateMountPoint, _downloadEventFd, [&output](const char *buffer, std::size_t size){ output.assign(buffer, size); }))
        return output.find(kUpdateMountPoint) != std::string::npos ? 1 : -1;
    else
        return 0;
}

bool UpdateManager::checkSdcard()
{
    LoggerStreams streams;

    return Util::watchProcess(kCheckSdcardPath, _downloadEventFd, [&streams](const char *buffer, std::size_t size){ streams.stream("UpdateManager::checkSdcard - check_sdcard (stdout)").write(buffer, size); },
                                                                  [&streams](const char *buffer, std::size_t size){ streams.stream("UpdateManager::checkSdcard - check_sdcard (stderr)").write(buffer, size); });
}

void UpdateManager::setLastErrorAndThrow(const ErrorInfo &error, bool setUnknownState)
{
    setLastError(error, setUnknownState);

    throw UpdateException(error);
}

void UpdateManager::setLastError(const ErrorInfo &error, bool setUnknownState)
{
    if (setUnknownState)
        _updateState = Unknown;

    Poco::RWLock::ScopedWriteLock lock(_errorMutex);
    _lastError = error;
}
