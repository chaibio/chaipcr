#include "dbincludes.h"
#include "sociincludes.h"
#include "qpcrapplication.h"

#define DATABASE_ADDRESS "host=localhost db=chaipcr user=root"
#define DATABASE_LOCKED_TRY_COUNT 3
#define ROUND(x) ((int)(x * 100.0 + 0.5) / 100.0)

DBControl::DBControl()
{
    _readSession = new soci::session(soci::mysql, DATABASE_ADDRESS);
    _writeSession = new soci::session(soci::mysql, DATABASE_ADDRESS);

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
                std::lock_guard<std::mutex> lock(_writeMutex);

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

    std::unique_lock<std::mutex> lock(_readMutex);
    {
        *_readSession << "SELECT * FROM experiments WHERE id = " << id, soci::into(result);
        gotData = _readSession->got_data();
    }
    lock.unlock();

    if (!gotData || result.get_indicator("id") == soci::i_null || result.get_indicator("experiment_definition_id") == soci::i_null)
        return Experiment();

    Experiment experiment(id, result.get<int>("experiment_definition_id"));

    if (getExperimentDefination(experiment))
    {
        experiment.setProtocol(getProtocol(experiment.definationId()));

        return experiment;
    }
    else
        return Experiment();
}

bool DBControl::getExperimentDefination(Experiment &experiment)
{
    if (experiment.definationId() != -1)
    {
        bool gotData = false;
        soci::row result;

        std::unique_lock<std::mutex> lock(_readMutex);
        {
            *_readSession << "SELECT * FROM experiment_definitions WHERE id = " << experiment.definationId(), soci::into(result);
            gotData = _readSession->got_data();
        }
        lock.unlock();

        if (!gotData || result.get_indicator("id") == soci::i_null)
        {
            std::cout << "DBControl::getExperimentDefination - unable to find experiment with definationId " << experiment.definationId() << '\n';

            experiment.setDefinationId(-1);

            return false;
        }

        if (result.get_indicator("name") != soci::i_null)
            experiment.setName(result.get<std::string>("name"));

        return true;
    }

    return false;
}

Protocol* DBControl::getProtocol(int experimentId)
{
    bool gotData = false;
    soci::row result;

    std::unique_lock<std::mutex> lock(_readMutex);
    {
        *_readSession << "SELECT * FROM protocols WHERE experiment_definition_id = " << experimentId, soci::into(result);
        gotData = _readSession->got_data();
    }
    lock.unlock();

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
    std::unique_lock<std::mutex> lock(_readMutex);

    soci::rowset<soci::row> result((_readSession->prepare << "SELECT * FROM stages WHERE protocol_id = " << protocolId << " ORDER BY order_number"));

    lock.unlock();

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

        if (it->get_indicator("auto_delta") != soci::i_null)
            stage.setAutoDelta(it->get<int>("auto_delta"));

        if (it->get_indicator("auto_delta_start_cycle") != soci::i_null)
            stage.setAutoDeltaStartCycle(it->get<int>("auto_delta_start_cycle"));

        if (stage.name().empty())
        {
            std::stringstream stream;
            stream << "Stage " << (stage.orderNumber() + 1);

            stage.setName(stream.str());
        }

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
    std::unique_lock<std::mutex> lock(_readMutex);

    soci::rowset<soci::row> result((_readSession->prepare << "SELECT * FROM steps WHERE stage_id = " << stageId << " ORDER BY order_number"));

    lock.unlock();

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

        if (it->get_indicator("delta_temperature") != soci::i_null)
        {
            if (it->get_properties("delta_temperature").get_data_type() == soci::dt_double)
                step.setDeltaTemperature(it->get<double>("delta_temperature"));
            else
                step.setDeltaTemperature(it->get<int>("delta_temperature"));
        }

        if (it->get_indicator("delta_duration_s") != soci::i_null)
            step.setDeltaDuration(it->get<int>("delta_duration_s"));

        if (it->get_indicator("pause") != soci::i_null)
            step.setPauseState(it->get<int>("pause"));

        if (step.name().empty())
        {
            std::stringstream stream;
            stream << "Step " << (step.orderNumber() + 1);

            step.setName(stream.str());
        }

        steps.push_back(std::move(step));
    }

    return steps;
}

Ramp* DBControl::getRamp(int stepId)
{
    bool gotData = false;
    soci::row result;

    std::unique_lock<std::mutex> lock(_readMutex);
    {
        *_readSession << "SELECT * FROM ramps WHERE next_step_id = " << stepId, soci::into(result);
        gotData = _readSession->got_data();
    }
    lock.unlock();

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
        stream << "INSERT INTO fluorescence_data(experiment_id, step_id, ramp_id, fluorescence_value, well_num, cycle_num) VALUES(" << experiment.id() << ", ";

        if (!isRamp)
            stream << experiment.protocol()->currentStep()->id() << ", ";
        else
            stream << "NULL, ";

        if (isRamp)
            stream << experiment.protocol()->currentRamp()->id() << ", ";
        else
            stream << "NULL, ";

        stream << fluorescenceData.at(i) << ", " << i << ", " << experiment.protocol()->currentStage()->currentCycle() << ")";

        queries.emplace_back(std::move(stream.str()));
        stream.str("");
    }

    addWriteQueries(queries);
}

void DBControl::addMeltCurveData(const Experiment &experiment, const std::vector<Optics::MeltCurveData> &meltCurveData)
{
    std::vector<std::string> queries;
    std::stringstream stream;

    for (const Optics::MeltCurveData &data: meltCurveData)
    {
        stream << "INSERT INTO melt_curve_data(stage_id, well_num, temperature, fluorescence_value) VALUES(" <<
                  experiment.protocol()->currentStage()->id() << ", " << data.wellId << ", " << data.temperature << ", " << data.fluorescenceValue << ")";

        queries.emplace_back(std::move(stream.str()));
        stream.str("");
    }

    addWriteQueries(queries);
}

Settings* DBControl::getSettings()
{
    soci::row result;
    std::unique_lock<std::mutex> lock(_readMutex);

    *_readSession << "SELECT * FROM settings", soci::into(result);

    lock.unlock();

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
    std::unique_lock<std::mutex> lock(_readMutex);

    *_readSession << "SELECT id FROM experiment_definition", soci::into(idList);

    lock.unlock();

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
        //int tryCount = 0;

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
                /*int error = sqlite_api::sqlite3_errcode(static_cast<soci::sqlite3_session_backend*>(_writeSession->get_backend())->conn_);

                if (error == SQLITE_BUSY || error == SQLITE_LOCKED)
                {
                    ++tryCount;

                    if (tryCount > DATABASE_LOCKED_TRY_COUNT)
                        throw;
                }
                else
                    throw;*/

                throw;
            }
        }
    }
}
