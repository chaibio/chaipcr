#include "pcrincludes.h"
#include "pocoincludes.h"

#include "dbincludes.h"

using namespace Poco;
using namespace Poco::Data;

#define DATABASE_FILE "db.db"

DBControl::DBControl()
{
    SQLite::Connector::registerConnector();

    _session = new Session("SQLite", DATABASE_FILE);
}

DBControl::~DBControl()
{
    delete _session;

    SQLite::Connector::unregisterConnector();
}

Experiment* DBControl::getExperiment(int id)
{
    Statement statement(*_session);
    statement << "SELECT * FROM experiments WHERE id=:id", use(id), now;

    RecordSet records(statement);
    if (records.rowCount() == 0)
        return nullptr;

    Experiment *experiment = new Experiment;
    experiment->setName(std::move(records["name"].extract<std::string>()));
    experiment->setQpcr(records["qpcr"].extract<bool>());
    experiment->setRunAt(records["run_at"].extract<Int64>());
    experiment->setProtocol(getProtocol(id));

    return experiment;
}

Protocol *DBControl::getProtocol(int experimentId)
{
    Statement statement(*_session);
    statement << "SELECT * FROM protocols WHERE experiment_id=:experimentId", use(experimentId), now;

    RecordSet records(statement);
    if (records.rowCount() == 0)
        return nullptr;

    Protocol *protocol = new Protocol;
    protocol->setLidTemperature(records["lid_temperature"].extract<double>());
    protocol->setStages(std::move(getStages(records["id"].extract<int>())));

    return protocol;
}

std::vector<Stage> DBControl::getStages(int protocolId)
{
    Statement statement(*_session);
    statement << "SELECT * FROM stages WHERE protocol_id=:protocolId ORDER BY order_number", use(protocolId), now;

    RecordSet records(statement);
    std::vector<Stage> stages;

    if (records.rowCount() > 0)
    {
        Stage stage;
        std::string stageType;
        while (records.moveNext())
        {
            stage.setName(move(records["name"].extract<std::string>()));
            stage.setNumCycles(records["num_cycles"].extract<int>());
            stage.setOrderNumber(records["order_number"].extract<int>());
            stageType = records["stage_type"].extract<std::string>();

            if (stageType == "holding")
                stage.setType(Stage::Holding);
            else if (stageType == "cycling")
                stage.setType(Stage::Cycling);
            else if (stageType == "meltcurve")
                stage.setType(Stage::Meltcurve);

            stage.setComponents(std::move(getStageComponents(records["id"].extract<int>())));

            stages.push_back(std::move(stage));
        }
    }

    return stages;
}

std::vector<StageComponent> DBControl::getStageComponents(int stageId)
{
    std::vector<StageComponent> components;
    std::vector<Step> steps(std::move(getSteps(stageId)));

    for (const Step &step: steps)
    {

    }

    return components;
}

std::vector<Step> DBControl::getSteps(int stageId)
{
    Statement statement(*_session);
    statement << "SELECT * FROM steps WHERE stage_id=:stageId ORDER BY order_number", use(stageId), now;

    RecordSet records(statement);
    std::vector<Step> steps;

    if (records.rowCount() > 0)
    {
        Step step;
        while (records.moveNext())
        {
            step.setName(std::move(records["name"].extract<std::string>()));
            step.setTemperature(records["temperature"].extract<double>());
            step.setHoldTime(records["hold_time"].extract<Int64>());
            step.setOrderNumber(records["order_number"].extract<int>());

            steps.push_back(std::move(step));
        }
    }

    return steps;
}

Ramp* DBControl::getRamp(int stepId)
{
    Statement statement(*_session);
    statement << "SELECT * FROM ramps WHERE next_step_id=:stepId", use(stepId), now;

    RecordSet records(statement);
    if (records.rowCount() == 0)
        return nullptr;

    Ramp *ramp = new Ramp;
    ramp->setRate(records["rate"].extract<double>());

    return ramp;
}
