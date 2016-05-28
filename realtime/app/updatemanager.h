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
    void checkUpdateCallback(bool checkHash);

    void downlaod(Upgrade upgrade);
    bool downlaod(const std::string &imageUrl, const std::string &apiPassword);

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
