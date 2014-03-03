#ifndef DBCONTROL_H
#define DBCONTROL_H

namespace Poco
{
namespace Data
{
class Session;
class Statement;
}
}

class Experiment;
class Protocol;
class Stage;
class Step;
class Ramp;

class DBControl
{
public:
    DBControl();
    ~DBControl();

    Experiment* getExperiment(int id);

private:
    Protocol* getProtocol(Poco::Data::Statement &statement, int experimentId);
    std::vector<Stage> getStages(Poco::Data::Statement &statement, int protocolId);
    std::vector<Step> getSteps(Poco::Data::Statement &statement, int stageId);
    Ramp* getRamp(Poco::Data::Statement &statement, int stepId);

    Poco::Data::Session *session;
};

#endif // DBCONTROL_H
