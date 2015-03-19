#include "dbincludes.h"
#include "sociincludes.h"
#include "qpcrapplication.h"

#define DATABASE_FILE "/root/chaipcr/web/db/development.sqlite3"
#define DATABASE_LOCKED_TRY_COUNT 3
#define ROUND(x) ((int)(x * 100.0 + 0.5) / 100.0)

DBControl::DBControl()
{
    sqlite_api::sqlite3_enable_shared_cache(1);

    _readSession = new soci::session(soci::sqlite3, DATABASE_FILE);
    _writeSession = new soci::session(soci::sqlite3, DATABASE_FILE);

    *_readSession << "PRAGMA temp_store = MEMORY";
    *_readSession << "PRAGMA synchronous = NORMAL";
    *_writeSession << "PRAGMA temp_store = MEMORY";
    *_writeSession << "PRAGMA synchronous = NORMAL";

    start();
}

DBControl::~DBControl()
{
    stop();

    if (joinable())
        join();

    delete _readSession;
    delete _writeSession;
}

void DBControl::process()
{
    std::vector<std::string> queries;

    _writeThreadState = true;
    while (_writeThreadState)
    {
        try
        {
            {
                std::unique_lock<std::mutex> lock(_writeQueueMutex);
                _writeCondition.wait(lock);

                queries = std::move(_writeQueriesQueue);
            }

            if (!queries.empty())
            {
                std::vector<soci::statement> statements;
                std::unique_lock<std::mutex> lock(_writeMutex);

                for (const std::string &query: queries)
                    statements.emplace_back((_writeSession->prepare << query));

                write(statements);
            }
        }
        catch (...)
        {
            qpcrApp.setException(std::current_exception());
        }
    }
}

void DBControl::stop()
{
    _writeThreadState = false;
    _writeCondition.notify_all();
}

Experiment DBControl::getExperiment(int id)
{
    bool gotData = false;
    soci::row result;

    _readMutex.lock();
    {
        *_readSession << "SELECT * FROM experiments WHERE id = " << id, soci::into(result);
        gotData = _readSession->got_data();
    }
    _readMutex.unlock();

    if (!gotData || result.get_indicator("id") == soci::i_null)
        return Experiment();

    Experiment experiment(id);

    if (result.get_indicator("name") != soci::i_null)
        experiment.setName(result.get<std::string>("name"));
    if (result.get_indicator("qpcr") != soci::i_null)
        experiment.setQpcr(result.get<int>("qpcr"));
    if (result.get_indicator("started_at") != soci::i_null)
        experiment.setStartedAt(result.get<boost::posix_time::ptime>("started_at"));
    if (result.get_indicator("completed_at") != soci::i_null)
        experiment.setCompletedAt(result.get<boost::posix_time::ptime>("completed_at"));
    if (result.get_indicator("completion_status") != soci::i_null)
        experiment.setCompletionStatus(result.get<Experiment::CompletionStatus>("completion_status"));

    experiment.setProtocol(getProtocol(result.get<int>("id")));

    return experiment;
}

Protocol* DBControl::getProtocol(int experimentId)
{
    bool gotData = false;
    soci::row result;

    _readMutex.lock();
    {
        *_readSession << "SELECT * FROM protocols WHERE experiment_id = " << experimentId, soci::into(result);
        gotData = _readSession->got_data();
    }
    _readMutex.unlock();

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

    _readMutex.lock();
    soci::rowset<soci::row> result((_readSession->prepare << "SELECT * FROM stages WHERE protocol_id = " << protocolId << " ORDER BY order_number"));
    _readMutex.unlock();

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

    _readMutex.lock();
    soci::rowset<soci::row> result((_readSession->prepare << "SELECT * FROM steps WHERE stage_id = " << stageId << " ORDER BY order_number"));
    _readMutex.unlock();

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

        if (it->get_indicator("collect_data") != soci::i_null)
            step.setCollectData(it->get<int>("collect_data"));

        steps.push_back(std::move(step));
    }

    return steps;
}

Ramp* DBControl::getRamp(int stepId)
{
    bool gotData = false;
    soci::row result;

    _readMutex.lock();
    {
        *_readSession << "SELECT * FROM ramps WHERE next_step_id = " << stepId, soci::into(result);
        gotData = _readSession->got_data();
    }
    _readMutex.unlock();

    if (!gotData || result.get_indicator("id") == soci::i_null)
        return nullptr;

    Ramp *ramp = new Ramp(result.get<int>("id"));

    if (result.get_indicator("rate") != soci::i_null)
    {
        if (result.get_properties("rate").get_data_type() == soci::dt_double)
            ramp->setRate(result.get<double>("rate"));
        else
            ramp->setRate(result.get<int>("rate"));
    }

    if (result.get_indicator("collect_data") != soci::i_null)
        ramp->setCollectData(result.get<int>("collect_data"));

    return ramp;
}

void DBControl::startExperiment(const Experiment &experiment)
{
    std::vector<soci::statement> statements;
    std::unique_lock<std::mutex> lock(_writeMutex);

    statements.emplace_back((_writeSession->prepare << "UPDATE experiments SET started_at = :started_at WHERE id = " << experiment.id(), soci::use(experiment.startedAt())));

    write(statements);
}

void DBControl::completeExperiment(const Experiment &experiment)
{
    std::vector<soci::statement> statements;
    std::unique_lock<std::mutex> lock(_writeMutex);

    statements.emplace_back((_writeSession->prepare << "UPDATE experiments SET completed_at = :completed_at, completion_status = :completion_status, completion_message = :completion_message WHERE id = "
                             << experiment.id(), soci::use(experiment.completedAt()), soci::use(experiment.completionStatus()), soci::use(experiment.completionMessage())));

    write(statements);
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
                      << log.experimentId() << ", " << log.elapsedTime() << ", " << ROUND(log.lidTemperature()) << ", "
                      << ROUND(log.heatBlockZone1Temperature()) << ", " << ROUND(log.heatBlockZone2Temperature()) << ")";

            queries.emplace_back(std::move(stream.str()));
            stream.str("");
        }

        if (log.hasDebugInfo())
        {
            stream << "INSERT INTO temperature_debug_logs(experiment_id, elapsed_time, lid_drive, heat_block_zone_1_drive, heat_block_zone_2_drive) VALUES("
                   << log.experimentId() << ", " << log.elapsedTime() << ", " << ROUND(log.lidTemperature()) << ", "
                   << ROUND(log.heatBlockZone1Drive()) << ", " << ROUND(log.heatBlockZone2Drive()) << ")";

            queries.emplace_back(std::move(stream.str()));
            stream.str("");
        }
    }

    addWriteQueries(queries);
}

void DBControl::addFluorescenceData(const Experiment &experiment, const std::vector<int> &fluorescenceData, bool isRamp)
{
    std::vector<std::string> queries;
    std::stringstream stream;

    for (size_t i = 0; i < fluorescenceData.size(); ++i)
    {
        stream << "INSERT INTO fluorescence_data(experiment_id, step_id, ramp_id, fluorescence_value, well_num, cycle_num) VALUES(" << experiment.id() << ", "
               << (!isRamp ? experiment.protocol()->currentStep()->id() : -1) << ", " << (isRamp ? experiment.protocol()->currentRamp()->id() : -1) << ", "
               << fluorescenceData.at(i) << ", " << i << ", " << experiment.protocol()->currentStage()->currentCycle() << ")";

        queries.emplace_back(std::move(stream.str()));
        stream.str("");
    }

    addWriteQueries(queries);
}

Settings* DBControl::getSettings()
{
    soci::row result;

    _readMutex.lock();
    *_readSession << "SELECT * FROM settings", soci::into(result);
    _readMutex.unlock();

    Settings *settings = new Settings();

    if (result.get_indicator("debug") != soci::i_null)
        settings->setDebugMode(result.get<int>("debug"));

    return settings;
}

void DBControl::updateSettings(const Settings &settings)
{
    std::vector<soci::statement> statements;
    std::unique_lock<std::mutex> lock(_writeMutex);

    statements.emplace_back((_writeSession->prepare << "UPDATE settings SET debug = :debug", soci::use(settings.debugMode() ? 1 : 0)));

    write(statements);
}

#ifdef TEST_BUILD
std::vector<int> DBControl::getEperimentIdList()
{
    std::vector<int> idList(100);

    _readMutex.lock();
    *_readSession << "SELECT id FROM experiments", soci::into(idList);
    _readMutex.unlock();

    return idList;
}
#endif

void DBControl::addWriteQueries(std::vector<std::string> &queries)
{
    if (!queries.empty())
    {
        _writeQueueMutex.lock();
        _writeQueriesQueue.insert(_writeQueriesQueue.end(), std::make_move_iterator(queries.begin()), std::make_move_iterator(queries.end()));
        _writeQueueMutex.unlock();

        _writeCondition.notify_all();
    }
}

void DBControl::write(std::vector<soci::statement> &statements)
{
    if (!statements.empty())
    {
        bool success = false;
        int tryCount = 0;

        while (!success)
        {
            try
            {
                soci::transaction transaction(*_writeSession);

                for (soci::statement &statement: statements)
                    statement.execute(true);

                transaction.commit();

                success = true;
            }
            catch (const soci::soci_error&)
            {
                int error = sqlite_api::sqlite3_errcode(static_cast<soci::sqlite3_session_backend*>(_writeSession->get_backend())->conn_);

                if (error == SQLITE_BUSY || error == SQLITE_LOCKED)
                {
                    ++tryCount;

                    if (tryCount > DATABASE_LOCKED_TRY_COUNT)
                        throw;
                }
                else
                    throw;
            }
        }
    }
}
