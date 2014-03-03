#include "pcrincludes.h"
#include "pocoincludes.h"

#include "experiment.h"
#include "dbcontrol.h"

using namespace std;
using namespace Poco;
using namespace Poco::Data;

#define DATABASE_FILE "db.db"

DBControl::DBControl()
{
    SQLite::Connector::registerConnector();

    session = new Session("SQLite", DATABASE_FILE);
}

DBControl::~DBControl()
{
    delete session;

    SQLite::Connector::unregisterConnector();
}

Experiment* DBControl::getExperiment(int id)
{
    Statement statement(*session);
    statement << "SELECT * FROM experiments WHERE id=:id", use(id), now;

    RecordSet records(statement);
    if (records.rowCount() == 0)
        return 0;

    Experiment *experiment = new Experiment;
    experiment->name = records["name"].extract<string>();
    experiment->qpcr = records["qpcr"].extract<bool>();
    experiment->run_at = records["run_at"].extract<Int64>();
    experiment->protocol = getProtocol(statement, id);

    return experiment;
}

Protocol* DBControl::getProtocol(Statement &statement, int experimentId)
{
    statement << "SELECT * FROM protocols WHERE experiment_id=:experimentId", use(experimentId), now;

    RecordSet records(statement);
    if (records.rowCount() == 0)
        return 0;

    Protocol *protocol = new Protocol;
    protocol->lid_temperature = records["lid_temperature"].extract<double>();
    protocol->stages = getStages(statement, records["id"].extract<int>());

    return protocol;
}

vector<Stage> DBControl::getStages(Statement &statement, int protocolId)
{
    statement << "SELECT * FROM stages WHERE protocol_id=:protocolId ORDER BY order_number", use(protocolId), now;

    RecordSet records(statement);
    vector<Stage> stages;

    if (records.rowCount() > 0)
    {
        Stage stage;
        string stageType;
        while (records.moveNext())
        {
            stage.name = records["name"].extract<string>();
            stage.num_cycles = records["num_cycles"].extract<int>();
            stage.order_number = records["order_number"].extract<int>();
            stageType = records["stage_type"].extract<string>();

            if (stageType == "holding")
                stage.stage_type = Stage::Holding;
            else if (stageType == "cycling")
                stage.stage_type = Stage::Cycling;
            else if (stageType == "meltcurve")
                stage.stage_type = Stage::Meltcurve;

            stage.steps = getSteps(statement, records["id"].extract<int>());

            stages.push_back(move(stage));
        }
    }

    return stages;
}

vector<Step> DBControl::getSteps(Statement &statement, int stageId)
{
    statement << "SELECT * FROM steps WHERE stage_id=:stageId ORDER BY order_number", use(stageId), now;

    RecordSet records(statement);
    vector<Step> steps;

    if (records.rowCount() > 0)
    {
        Step step;
        while (records.moveNext())
        {
            step.name = records["name"].extract<string>();
            step.temperature = records["temperature"].extract<double>();
            step.hold_time = records["hold_time"].extract<Int64>();
            step.order_number = records["order_number"].extract<int>();
            step.ramp = getRamp(statement, records["id"].extract<int>());

            steps.push_back(move(step));
        }
    }

    return steps;
}

Ramp* DBControl::getRamp(Statement &statement, int stepId)
{
    statement << "SELECT * FROM ramps WHERE next_step_id=:stepId", use(stepId), now;

    RecordSet records(statement);
    if (records.rowCount() == 0)
        return 0;

    Ramp *ramp = new Ramp;
    ramp->rate = records["rate"].extract<double>();

    return ramp;
}
