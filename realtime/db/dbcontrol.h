#ifndef DBCONTROL_H
#define DBCONTROL_H

namespace Poco
{
namespace Data
{
class Session;
}
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

private:
    Protocol* getProtocol(int experimentId);
    std::vector<Stage> getStages(int protocolId);
    std::vector<StageComponent> getStageComponents(int stageId);
    std::vector<Step> getSteps(int stageId);
    Ramp* getRamp(int stepId);

    Poco::Data::Session *_session;
};

#endif // DBCONTROL_H
