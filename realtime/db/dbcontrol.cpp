#include "pcrincludes.h"
#include "boostincludes.h"

#include "dbincludes.h"
#include "sociincludes.h"

#define DATABASE_FILE "./db.sqlite"

DBControl::DBControl()
{
    _session = new soci::session(soci::sqlite3, DATABASE_FILE);
}

DBControl::~DBControl()
{
    delete _session;
}

Experiment* DBControl::getExperiment(int id)
{
    soci::row result;
    *_session << "SELECT * FROM experiments WHERE id = " << id, soci::into(result);

    if (result.get_indicator("id") == soci::i_null)
        return nullptr;

    Experiment *experiment = new Experiment;

    if (result.get_indicator("name") != soci::i_null)
        experiment->setName(result.get<std::string>("name"));
    if (result.get_indicator("qpcr") != soci::i_null)
        experiment->setQpcr(result.get<int>("qpcr"));
    if (result.get_indicator("run_at") != soci::i_null)
        experiment->setRunAt(result.get<boost::posix_time::ptime>("run_at"));

    experiment->setProtocol(getProtocol(result.get<int>("id")));

    return experiment;
}

Protocol* DBControl::getProtocol(int experimentId)
{
    soci::row result;
    *_session << "SELECT * FROM protocols WHERE experiment_id = " << experimentId, soci::into(result);

    if (result.get_indicator("id") == soci::i_null)
        return nullptr;

    Protocol *protocol = new Protocol;

    if (result.get_indicator("lid_temperature") != soci::i_null)
    {
        if (result.get_properties("lid_temperature").get_data_type() == soci::dt_double)
            protocol->setLidTemperature(result.get<double>("lid_temperature"));
        else
            protocol->setLidTemperature(result.get<int>("lid_temperature"));
    }

    protocol->setStages(getStages(result.get<int>("id")));

    return protocol;
}

std::vector<Stage> DBControl::getStages(int protocolId)
{
    std::vector<Stage> stages;
    soci::rowset<soci::row> result((_session->prepare << "SELECT * FROM stages WHERE protocol_id = " << protocolId << " ORDER BY order_number"));

    Stage stage;
    for (soci::rowset<soci::row>::const_iterator it = result.begin(); it != result.end(); ++it)
    {
        if (it->get_indicator("name") != soci::i_null)
            stage.setName(it->get<std::string>("name"));

        if (it->get_indicator("num_cycles") != soci::i_null)
            stage.setNumCycles(it->get<int>("num_cycles"));

        if (it->get_indicator("order_number") != soci::i_null)
            stage.setOrderNumber(it->get<int>("order_number"));

        if (it->get_indicator("stage_type") != soci::i_null)
            stage.setType(it->get<Stage::Type>("stage_type"));

        stage.setComponents(getStageComponents(it->get<int>("id")));

        stages.push_back(std::move(stage));
    }

    return stages;
}

std::vector<StageComponent> DBControl::getStageComponents(int stageId)
{
    std::vector<StageComponent> components;
    std::map<int, Step> steps = getSteps(stageId);

    StageComponent component;
    for (std::map<int, Step>::iterator it = steps.begin(); it != steps.end(); ++it)
    {
        component.setStep(std::move(it->second));
        component.setRamp(getRamp(it->first));

        components.push_back(std::move(component));
    }

    return components;
}

std::map<int, Step> DBControl::getSteps(int stageId)
{
    std::map<int, Step> steps;
    soci::rowset<soci::row> result((_session->prepare << "SELECT * FROM steps WHERE stage_id = " << stageId << " ORDER BY order_number"));

    Step step;
    for (soci::rowset<soci::row>::const_iterator it = result.begin(); it != result.end(); ++it)
    {
        if (it->get_indicator("name") != soci::i_null)
            step.setName(it->get<std::string>("name"));

        if (it->get_indicator("temperature") != soci::i_null)
        {
            if (it->get_properties("temperature").get_data_type() == soci::dt_double)
                step.setTemperature(it->get<double>("temperature"));
            else
                step.setTemperature(it->get<int>("temperature"));
        }

        if (it->get_indicator("order_number") != soci::i_null)
            step.setOrderNumber(it->get<int>("order_number"));

        if (it->get_indicator("hold_time") != soci::i_null)
            step.setHoldTime(it->get<int>("hold_time"));

        steps[it->get<int>("id")] = std::move(step);
    }

    return steps;
}

Ramp* DBControl::getRamp(int stepId)
{
    soci::row result;
    *_session << "SELECT * FROM ramps WHERE next_step_id = " << stepId, soci::into(result);

    if (result.get_indicator("id") == soci::i_null)
        return nullptr;

    Ramp *ramp = new Ramp;

    if (result.get_indicator("rate") != soci::i_null)
    {
        if (result.get_properties("rate").get_data_type() == soci::dt_double)
            ramp->setRate(result.get<double>("rate"));
        else
            ramp->setRate(result.get<int>("rate"));
    }

    return ramp;
}

#ifdef TEST_BUILD
std::vector<int> DBControl::getEperimentIdList()
{
    std::vector<int> idList(100);
    *_session << "SELECT id FROM experiments", soci::into(idList);

    return idList;
}
#endif
