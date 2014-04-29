#ifndef DBCONTROL_H
#define DBCONTROL_H

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

class DBControl
{
public:
    DBControl();
    ~DBControl();

    Experiment* getExperiment(int id);
    void startExperiment(Experiment *experiment);
    void completeExperiment(Experiment *experiment);

#ifdef TEST_BUILD
    std::vector<int> getEperimentIdList();
#endif

private:
    Protocol* getProtocol(int experimentId);
    std::vector<Stage> getStages(int protocolId);
    std::vector<StageComponent> getStageComponents(int stageId);
    std::map<int, Step> getSteps(int stageId);
    Ramp* getRamp(int stepId);

    soci::session *_session;
};

#endif // DBCONTROL_H
