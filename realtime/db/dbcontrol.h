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

class DBControl : private IThreadControl
{
public:
    DBControl();
    ~DBControl();

    Experiment getExperiment(int id);
    void startExperiment(const Experiment &experiment);
    void completeExperiment(const Experiment &experiment);

    void addTemperatureLog(const std::vector<TemperatureLog> &logs);
    void addFluorescenceData(const Experiment &experiment, const std::vector<int> &fluorescenceData, bool isRamp = false);
    void addMeltCurveData(const Experiment &experiment, const std::vector<Optics::MeltCurveData> &meltCurveData);

    Settings* getSettings();
    void updateSettings(const Settings &settings);

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
