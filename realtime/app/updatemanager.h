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

#ifndef UPDATEMANAGER_H
#define UPDATEMANAGER_H

#include "upgrade.h"

#include <memory>
#include <atomic>
#include <thread>
#include <mutex>
#include <stdexcept>

#include <Poco/Event.h>
#include <Poco/RWLock.h>

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

    class ErrorInfo
    {
    public:
        enum ErrorCode
        {
            NoError,
            UnknownError,
            InvalidImage,
            UplodFaild,
            NetworkError
        };

        ErrorInfo(): code(NoError) {}
        ErrorInfo(ErrorCode code, const std::string &message): code(code), message(message) {}

    public:
        ErrorCode code;
        std::string message;
    };

    class UpdateException : public std::runtime_error
    {
    public:
        UpdateException(const ErrorInfo &error): std::runtime_error(error.message), error(error) {}

        const char* what() const _GLIBCXX_USE_NOEXCEPT { return error.message.c_str(); }

    public:
        ErrorInfo error;
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

    ErrorInfo lastError() const;

private:
    void checkUpdateCallback(bool checkHash);

    void downlaod(Upgrade upgrade);
    bool downlaod(const std::string &imageUrl, const std::string &apiPassword);

    int checkMountPoint();
    bool checkSdcard();

    void setLastErrorAndThrow(const ErrorInfo &error, bool setUnknownState = true);
    void setLastError(const ErrorInfo &error, bool setUnknownState = true);
    inline void clearLastError(bool setUnknownState = false) { setLastError(ErrorInfo(), setUnknownState); }

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

    mutable Poco::RWLock _errorMutex;
    ErrorInfo _lastError;
};

#endif // UPDATEMANAGER_H
