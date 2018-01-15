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

#ifndef DBCONTROL_H
#define DBCONTROL_H

#include "icontrol.h"
#include "experiment.h"
#include "optics.h"

#include <vector>
#include <mutex>
#include <condition_variable>
#include <atomic>

namespace soci
{
class session;
class statement;
}

namespace Poco { class Timer; }

class Protocol;
class Stage;
class StageComponent;
class Step;
class Ramp;
class TemperatureLog;
class DebugTemperatureLog;
class Settings;
class Upgrade;

class DBControl : private IThreadControl
{
public:
    DBControl();
    ~DBControl();

    Experiment getExperiment(int id);
    void startExperiment(const Experiment &experiment);
    void completeExperiment(const Experiment &experiment);

    void addTemperatureLog(const std::vector<TemperatureLog> &logs);
    void addFluorescenceData(const Experiment &experiment, const std::vector<Optics::FluorescenceData> &fluorescenceData, bool isRamp = false);
    void addMeltCurveData(const Experiment &experiment, const std::vector<Optics::MeltCurveData> &meltCurveData);

    Settings getSettings();
    void updateSettings(const Settings &settings);

    void getCurrentUpgrade(std::string &version, bool &downloaded);
    void updateUpgrade(const Upgrade &upgrade);
    void setUpgradeDownloaded(bool state);

    int getUserId(const std::string &token);

#ifdef TEST_BUILD
    std::vector<int> getEperimentIdList();
#endif

private:
    void process();
    void stop();

    void ping(Poco::Timer &timer);

    bool getExperimentDefination(Experiment &experiment);
    Protocol* getProtocol(int experimentId);
    std::vector<Stage> getStages(int protocolId);
    std::vector<StageComponent> getStageComponents(int stageId);
    std::vector<Step> getSteps(int stageId);
    Ramp* getRamp(int stepId);

    void addWriteQueries(std::vector<std::string> &queries);

    void write(std::vector<soci::statement> &statements);

private:
    soci::session *_readSession;
    soci::session *_writeSession;

    std::mutex _readMutex;
    std::mutex _writeMutex;
    std::mutex _writeQueueMutex;

    std::atomic<bool> _writeThreadState;
    std::vector<std::string> _writeQueriesQueue;
    std::condition_variable _writeCondition;

    Poco::Timer *_pingTimer;
};

#endif // DBCONTROL_H
