#ifndef DBCONTROL_H
#define DBCONTROL_H

#include <vector>
#include <mutex>

namespace soci
{
class session;
}

class Experiment;
class Protocol;
class Stage;
class StageComponent;
class Step;
class Ramp;
class TemperatureLog;
class DebugTemperatureLog;
class Settings;

class DBControl
{
public:
    DBControl();
    ~DBControl();

    Experiment* getExperiment(int id);
    void startExperiment(Experiment *experiment);
    void completeExperiment(Experiment *experiment);

    void addTemperatureLog(const TemperatureLog &log);
    void addTemperatureLog(const std::vector<TemperatureLog> &logs);

    void addFluorescenceData(const Experiment *experiment, const std::vector<int> &fluorescenceData);

    Settings* getSettings();
    void updateSettings(const Settings &settings);

#ifdef TEST_BUILD
    std::vector<int> getEperimentIdList();
#endif

private:
    Protocol* getProtocol(int experimentId);
    std::vector<Stage> getStages(int protocolId);
    std::vector<StageComponent> getStageComponents(int stageId);
    std::vector<Step> getSteps(int stageId);
    Ramp* getRamp(int stepId);

    soci::session *_session;

    std::mutex _dbMutex;
};

#endif // DBCONTROL_H
