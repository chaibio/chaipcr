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

#ifndef _QPCRSERVER_H_
#define _QPCRSERVER_H_

#include "watchdog.h"

#include <Poco/Util/ServerApplication.h>

#include <signal.h>
#include <atomic>
#include <memory>
#include <exception>

class IControl;
class IThreadControl;
class DBControl;
class ExperimentController;
class WirelessManager;
class TimeChecker;
class UpdateManager;

// Class QPCRApplication
class QPCRApplication: public Poco::Util::ServerApplication, public Watchdog::Watchable
{
public:
    class MachineSettings
    {
    public:
        class Device
        {
        public:
            Device() { opticsChannels = 1; fanChange = false; }

        public:
            std::size_t opticsChannels;

            std::string serialNumber;
            std::string modelNumber;

            bool fanChange;
        }device;

        class Configuration
        {
        public:
            Configuration(): heatBlockMinTemp(0), heatBlockMaxTemp(0), dataSpaceSoftLimit(0), dataSpaceHardLimit(0) {}

        public:
            std::string version;
            std::string platform;

            float heatBlockMinTemp;
            float heatBlockMaxTemp;

            unsigned long dataSpaceSoftLimit;
            unsigned long dataSpaceHardLimit;
        }configuration;
    };

    QPCRApplication();

    inline static QPCRApplication& getInstance() { return static_cast<QPCRApplication&>(instance()); }

    inline bool isWorking() const { return _workState.load(); }
    inline void close() { _workState = false; }

    inline const MachineSettings& settings() const { return _settings; }

    inline std::shared_ptr<WirelessManager> wirelessManager() const { return _wirelessManager; }
    inline std::shared_ptr<UpdateManager> updateManager() const { return _updateManager; }

    inline void setException(std::exception_ptr exception) { _exception = exception; }

    void stopExperiment(const std::string &message);

    bool isMachinePaused() const;
    int getUserId(const std::string &token) const;

protected:
	//from ServerApplication
    void defineOptions(Poco::Util::OptionSet &options);
    void handleOption(const std::string &name, const std::string &value);

    void initialize(Poco::Util::Application &self);
    int main(const std::vector<std::string> &args);

private:
    void waitFlag();
    void readDeviceFile();
    void readConfigurationFile();

    void initSignals();
    bool waitSignal() const;

private:
    sigset_t _signalsSet;

    std::atomic<bool> _workState;

    MachineSettings _settings;

    std::vector<std::shared_ptr<IControl>> _controlUnits;
    std::vector<std::shared_ptr<IThreadControl>> _threadControlUnits;
    std::shared_ptr<DBControl> _dbControl;
    std::shared_ptr<ExperimentController> _experimentController;
    std::shared_ptr<WirelessManager> _wirelessManager;
    std::shared_ptr<TimeChecker> _timeChecker;
    std::shared_ptr<UpdateManager> _updateManager;

    std::exception_ptr _exception;
};

#define qpcrApp QPCRApplication::getInstance()

#endif
