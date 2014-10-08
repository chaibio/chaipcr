#include "dbincludes.h"
#include "sociincludes.h"
#include "qpcrapplication.h"

#define DATABASE_FILE "/root/chaipcr/web/db/development.sqlite3"

DBControl::DBControl()
{
    sqlite_api::sqlite3_enable_shared_cache(1);

    _session = new soci::session(soci::sqlite3, DATABASE_FILE);
    *_session << "PRAGMA temp_store = MEMORY";
    *_session << "PRAGMA synchronous = NORMAL";

    start();
}

DBControl::~DBControl()
{
    stop();

    if (joinable())
        join();

    delete _session;
}

void DBControl::process()
{
    soci::session session(soci::sqlite3, DATABASE_FILE);
    session << "PRAGMA temp_store = MEMORY";
    session << "PRAGMA synchronous = NORMAL";

    std::vector<std::string> queries;

    _writeThreadState = true;
    while (_writeThreadState)
    {
        try
        {
            {
                std::unique_lock<std::mutex> lock(_writeMutex);
                _writeCondition.wait(lock);

                queries = std::move(_writeQueriesQueue);
            }

            session.begin();
            {
                for (const std::string &query: queries)
                    session << query;
            }
            session.commit();

            queries.clear();
        }
        catch (...)
        {
            queries.clear();
            qpcrApp.setException(std::current_exception());
        }
    }
}

void DBControl::stop()
{
    _writeThreadState = false;
    _writeCondition.notify_all();
}

Experiment* DBControl::getExperiment(int id)
{
    bool gotData = false;
    soci::row result;

    _dbMutex.lock();
    {
        *_session << "SELECT * FROM experiments WHERE id = " << id, soci::into(result);
        gotData = _session->got_data();
    }
    _dbMutex.unlock();

    if (!gotData || result.get_indicator("id") == soci::i_null)
        return nullptr;

    Experiment *experiment = new Experiment(id);

    if (result.get_indicator("name") != soci::i_null)
        experiment->setName(result.get<std::string>("name"));
    if (result.get_indicator("qpcr") != soci::i_null)
        experiment->setQpcr(result.get<int>("qpcr"));
    if (result.get_indicator("started_at") != soci::i_null)
        experiment->setStartedAt(result.get<boost::posix_time::ptime>("started_at"));
    if (result.get_indicator("completed_at") != soci::i_null)
        experiment->setCompletedAt(result.get<boost::posix_time::ptime>("completed_at"));
    if (result.get_indicator("completion_status") != soci::i_null)
        experiment->setCompletionStatus(result.get<Experiment::CompletionStatus>("completion_status"));

    experiment->setProtocol(getProtocol(result.get<int>("id")));

    return experiment;
}

Protocol* DBControl::getProtocol(int experimentId)
{
    bool gotData = false;
    soci::row result;

    _dbMutex.lock();
    {
        *_session << "SELECT * FROM protocols WHERE experiment_id = " << experimentId, soci::into(result);
        gotData = _session->got_data();
    }
    _dbMutex.unlock();

    if (!gotData || result.get_indicator("id") == soci::i_null)
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

    _dbMutex.lock();
    soci::rowset<soci::row> result((_session->prepare << "SELECT * FROM stages WHERE protocol_id = " << protocolId << " ORDER BY order_number"));
    _dbMutex.unlock();

    for (soci::rowset<soci::row>::const_iterator it = result.begin(); it != result.end(); ++it)
    {
        Stage stage(it->get<int>("id"));

        if (it->get_indicator("name") != soci::i_null)
            stage.setName(it->get<std::string>("name"));

        if (it->get_indicator("num_cycles") != soci::i_null)
            stage.setNumCycles(it->get<int>("num_cycles"));

        if (it->get_indicator("order_number") != soci::i_null)
            stage.setOrderNumber(it->get<int>("order_number"));

        if (it->get_indicator("stage_type") != soci::i_null)
            stage.setType(it->get<Stage::Type>("stage_type"));

        stage.setComponents(getStageComponents(stage.id()));

        stages.push_back(std::move(stage));
    }

    return stages;
}

std::vector<StageComponent> DBControl::getStageComponents(int stageId)
{
    std::vector<StageComponent> components;
    std::vector<Step> steps = getSteps(stageId);

    StageComponent component;
    for (Step &step: steps)
    {
        component.setRamp(getRamp(step.id()));
        component.setStep(std::move(step));

        components.push_back(std::move(component));
    }

    return components;
}

std::vector<Step> DBControl::getSteps(int stageId)
{
    std::vector<Step> steps;

    _dbMutex.lock();
    soci::rowset<soci::row> result((_session->prepare << "SELECT * FROM steps WHERE stage_id = " << stageId << " ORDER BY order_number"));
    _dbMutex.unlock();

    for (soci::rowset<soci::row>::const_iterator it = result.begin(); it != result.end(); ++it)
    {
        Step step(it->get<int>("id"));

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

        steps.push_back(std::move(step));
    }

    return steps;
}

Ramp* DBControl::getRamp(int stepId)
{
    bool gotData = false;
    soci::row result;

    _dbMutex.lock();
    {
        *_session << "SELECT * FROM ramps WHERE next_step_id = " << stepId, soci::into(result);
        gotData = _session->got_data();
    }
    _dbMutex.unlock();

    if (!gotData || result.get_indicator("id") == soci::i_null)
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

void DBControl::startExperiment(Experiment *experiment)
{
    _dbMutex.lock();
    *_session << "UPDATE experiments SET started_at = :started_at WHERE id = " << experiment->id(), soci::use(experiment->startedAt());
    _dbMutex.unlock();
}

void DBControl::completeExperiment(Experiment *experiment)
{
    _dbMutex.lock();
    {
        *_session << "UPDATE experiments SET completed_at = :completed_at, completion_status = :completion_status, completion_message = :completion_message WHERE id = " << experiment->id(),
                soci::use(experiment->completedAt()), soci::use(experiment->completionStatus()), soci::use(experiment->completionMessage());
    }
    _dbMutex.unlock();
}

void DBControl::addTemperatureLog(const std::vector<TemperatureLog> &logs)
{
    std::vector<std::string> queries;
    std::stringstream stream;

    for (const TemperatureLog &log: logs)
    {
        if (log.hasTemperatureInfo())
        {
            stream << "INSERT INTO temperature_logs(experiment_id, elapsed_time, lid_temp, heat_block_zone_1_temp, heat_block_zone_2_temp) VALUES("
                      << log.experimentId() << ", " << log.elapsedTime() << ", " << (std::round(log.lidTemperature() * 100.0) / 100.0) << ", "
                      << (std::round(log.heatBlockZone1Temperature() * 100.0) / 100.0) << ", " << (std::round(log.heatBlockZone2Temperature() * 100.0) / 100.0) << ")";

            queries.emplace_back(std::move(stream.str()));
            stream.str("");
        }

        if (log.hasDebugInfo())
        {
            stream << "INSERT INTO temperature_debug_logs(experiment_id, elapsed_time, lid_drive, heat_block_zone_1_drive, heat_block_zone_2_drive) VALUES("
                   << log.experimentId() << ", " << log.elapsedTime() << ", " << (std::round(log.lidTemperature() * 100.0) / 100.0) << ", "
                   << (std::round(log.heatBlockZone1Drive() * 100.0) / 100.0) << ", " << (std::round(log.heatBlockZone2Drive() * 100.0) / 100.0) << ")";

            queries.emplace_back(std::move(stream.str()));
            stream.str("");
        }
    }

    addWriteQueries(queries);
}

void DBControl::addFluorescenceData(const Experiment *experiment, const std::vector<int> &fluorescenceData)
{
    std::vector<std::string> queries;
    std::stringstream stream;


    for (size_t i = 0; i < fluorescenceData.size(); ++i)
    {
        stream << "INSERT INTO fluorescence_data(experiment_id, step_id, fluorescence_value, well_num, cycle_num) VALUES(" << experiment->id() << ", "
               << experiment->protocol()->currentStep()->id() << ", " << fluorescenceData.at(i) << ", " << i << ", " << experiment->protocol()->currentStage()->currentCycle() << ")";

        queries.emplace_back(std::move(stream.str()));
        stream.str("");
    }

    addWriteQueries(queries);
}

Settings* DBControl::getSettings()
{
    soci::row result;

    _dbMutex.lock();
    *_session << "SELECT * FROM settings", soci::into(result);
    _dbMutex.unlock();

    Settings *settings = new Settings();

    if (result.get_indicator("debug") != soci::i_null)
        settings->setDebugMode(result.get<int>("debug"));

    return settings;
}

void DBControl::updateSettings(const Settings &settings)
{
    _dbMutex.lock();
    *_session << "UPDATE settings SET debug = :debug", soci::use(settings.debugMode() ? 1 : 0);
    _dbMutex.unlock();
}

#ifdef TEST_BUILD
std::vector<int> DBControl::getEperimentIdList()
{
    std::vector<int> idList(100);

    _dbMutex.lock();
    *_session << "SELECT id FROM experiments", soci::into(idList);
    _dbMutex.unlock();

    return idList;
}
#endif

void DBControl::addWriteQueries(std::vector<std::string> &queries)
{
    if (!queries.empty())
    {
        _writeMutex.lock();
        _writeQueriesQueue.insert(_writeQueriesQueue.end(), std::make_move_iterator(queries.begin()), std::make_move_iterator(queries.end()));
        _writeMutex.unlock();

        _writeCondition.notify_all();
    }
}
