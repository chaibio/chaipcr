//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include "dbincludes.h"
#include "sociincludes.h"
#include "qpcrapplication.h"
#include "experimentcontroller.h"
#include "logger.h"

#include <Poco/Timer.h>

#include <errmsg.h>

#define DATABASE_ADDRESS "host=localhost db=chaipcr user=root"
#define DATABASE_LOCKED_TRY_COUNT 3
#define ROUND(x) ((int)(x * 100.0 + 0.5) / 100.0)

#define PING_TIMER_INTERVAL 2 * 1000

#define BEGIN_DB_READ() \
    bool __TRY_AGAIN = false; \
    do \
    { \
        try \
        {

#define END_DB_READ() \
        } \
        catch (const soci::mysql_soci_error &ex) \
        { \
            if (ex.err_num_ == CR_SERVER_LOST || ex.err_num_ == CR_SERVER_GONE_ERROR || \
                    ex.err_num_ == CR_CONNECTION_ERROR || ex.err_num_ ==  CR_CONN_HOST_ERROR) \
            { \
                if (!__TRY_AGAIN) \
                { \
                    try \
                    { \
                        _readSession->reconnect(); \
                        \
                        { \
                            std::lock_guard<std::mutex> lock(_writeMutex); \
                            _writeSession->reconnect(); \
                        } \
                        \
                        __TRY_AGAIN = true; \
                    } \
                    catch (...) \
                    { \
                        qpcrApp.setException(std::current_exception()); \
                        \
                        throw std::runtime_error("DBControl::END_DB_READ - unable to reconnect to the MySQL server"); \
                    } \
                } \
                else \
                { \
                    qpcrApp.setException(std::current_exception()); \
                    \
                    throw std::runtime_error("DBControl::END_DB_READ - unable to reconnect to the MySQL server"); \
                } \
            } \
            else \
                throw; \
        } \
    } \
    while (__TRY_AGAIN)

DBControl::DBControl()
{
    _readSession = new soci::session(soci::mysql, DATABASE_ADDRESS);
    _writeSession = new soci::session(soci::mysql, DATABASE_ADDRESS);
    _pingTimer = new Poco::Timer(PING_TIMER_INTERVAL, PING_TIMER_INTERVAL);

    unsigned int reconnect = 1;

    mysql_options(static_cast<soci::mysql_session_backend*>(_readSession->get_backend())->conn_, MYSQL_OPT_RECONNECT, &reconnect);
    mysql_options(static_cast<soci::mysql_session_backend*>(_writeSession->get_backend())->conn_, MYSQL_OPT_RECONNECT, &reconnect);

    _pingTimer->start(Poco::TimerCallback<DBControl>(*this, &DBControl::ping));

    start();
}

DBControl::~DBControl()
{
    stop();

    if (joinable())
        join();

    delete _pingTimer;

    delete _readSession;
    delete _writeSession;
}

void DBControl::process()
{
    setThreadName("DBControl");

    std::vector<std::string> queries;

    _writeThreadState = true;
    while (_writeThreadState)
    {
        try
        {
            {
                std::unique_lock<std::mutex> lock(_writeQueueMutex);

                if (_writeQueriesQueue.empty())
                    _writeCondition.wait(lock);

                queries = std::move(_writeQueriesQueue);
            }

            if (!queries.empty())
            {
                std::vector<soci::statement> statements;
                std::lock_guard<std::mutex> lock(_writeMutex);

                for (const std::string &query: queries)
                {
                    statements.emplace_back((_writeSession->prepare << query));
                }

                write(statements);
            }
        }
        catch (const std::exception &ex)
        {
            qpcrApp.stopExperiment(ex.what());
        }
        catch (...)
        {
            qpcrApp.stopExperiment("DBControl::process - unknown error upon writing to the database");
        }
    }
}

void DBControl::stop()
{
    _writeThreadState = false;
    _writeCondition.notify_all();
}

void DBControl::ping(Poco::Timer &/*timer*/)
{
    {
        std::lock_guard<std::mutex> lock(_readMutex);
        mysql_ping(static_cast<soci::mysql_session_backend*>(_readSession->get_backend())->conn_);
    }

    {
        std::lock_guard<std::mutex> lock(_writeMutex);
        mysql_ping(static_cast<soci::mysql_session_backend*>(_writeSession->get_backend())->conn_);
    }
}

Experiment DBControl::getExperiment(int id)
{
    bool gotData = false;
    soci::row result;

    std::unique_lock<std::mutex> lock(_readMutex);
    {
        BEGIN_DB_READ()
        *_readSession << "SELECT * FROM experiments WHERE id = " << id, soci::into(result);
        END_DB_READ();

        gotData = _readSession->got_data();
    }
    lock.unlock();

    if (!gotData || result.get_indicator("id") == soci::i_null || result.get_indicator("experiment_definition_id") == soci::i_null)
        return Experiment();

    Experiment experiment(id, result.get<int>("experiment_definition_id"));

    if (result.get_indicator("name") != soci::i_null)
        experiment.setName(result.get<std::string>("name"));

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
            BEGIN_DB_READ()
            *_readSession << "SELECT * FROM experiment_definitions WHERE id = " << experiment.definationId(), soci::into(result);
            END_DB_READ();

            gotData = _readSession->got_data();
        }
        lock.unlock();

        if (!gotData || result.get_indicator("id") == soci::i_null)
        {
            Poco::LogStream(Logger::get()) << "DBControl::getExperimentDefination - unable to find experiment with definationId " << experiment.definationId() << std::endl;

            experiment.setDefinationId(-1);

            return false;
        }

        if (result.get_indicator("experiment_type") != soci::i_null)
            experiment.setType(result.get<Experiment::Type>("experiment_type"));

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
        BEGIN_DB_READ()
        *_readSession << "SELECT * FROM protocols WHERE experiment_definition_id = " << experimentId, soci::into(result);
        END_DB_READ();

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

    BEGIN_DB_READ()

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

    END_DB_READ();

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

    BEGIN_DB_READ()

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

        if (it->get_indicator("excitation_intensity") != soci::i_null)
        {
            if (it->get_properties("excitation_intensity").get_data_type() == soci::dt_double)
                step.setExcitationIntensity(it->get<double>("excitation_intensity"));
            else
                step.setExcitationIntensity(it->get<int>("excitation_intensity"));
        }

        if (step.name().empty())
        {
            std::stringstream stream;
            stream << "Step " << (step.orderNumber() + 1);

            step.setName(stream.str());
        }

        steps.push_back(std::move(step));
    }

    END_DB_READ();

    return steps;
}

Ramp* DBControl::getRamp(int stepId)
{
    bool gotData = false;
    soci::row result;

    std::unique_lock<std::mutex> lock(_readMutex);
    {
        BEGIN_DB_READ()
        *_readSession << "SELECT * FROM ramps WHERE next_step_id = " << stepId, soci::into(result);
        END_DB_READ();

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

    if (result.get_indicator("excitation_intensity") != soci::i_null)
    {
        if (result.get_properties("excitation_intensity").get_data_type() == soci::dt_double)
            ramp->setExcitationIntensity(result.get<double>("excitation_intensity"));
        else
            ramp->setExcitationIntensity(result.get<int>("excitation_intensity"));
    }

    return ramp;
}

void DBControl::startExperiment(const Experiment &experiment)
{
    std::vector<soci::statement> statements;
    std::unique_lock<std::mutex> lock(_writeMutex);

    statements.emplace_back((_writeSession->prepare << "UPDATE experiments SET started_at = :started_at, time_valid = (SELECT time_valid FROM settings),"
                                                       "calibration_id = (SELECT calibration_id FROM settings), power_cycles = (SELECT power_cycles FROM settings) WHERE id = " << experiment.id(),
                             soci::use(experiment.startedAt())));

    write(statements);
}

void DBControl::completeExperiment(const Experiment &experiment)
{
    std::vector<std::string> queries;
    std::stringstream stream;

    stream << "UPDATE experiments SET completed_at = \'" << experiment.completedAt().date().year() << '-'
           << std::setw(2) << std::setfill('0') << experiment.completedAt().date().month().as_number() << '-'
           << std::setw(2) << std::setfill('0') << experiment.completedAt().date().day() << ' '
           << std::setw(2) << std::setfill('0') << experiment.completedAt().time_of_day().hours() << ':'
           << std::setw(2) << std::setfill('0') << experiment.completedAt().time_of_day().minutes() << ':'
           << std::setw(2) << std::setfill('0') << experiment.completedAt().time_of_day().seconds() << "\', completion_status = \'";

    switch (experiment.completionStatus())
    {
    case Experiment::Success:
        stream << "success";
        break;

    case Experiment::Failed:
        stream << "failure";
        break;

    case Experiment::Aborted:
        stream << "aborted";
        break;

    default:
        break;
    }

    stream << "\', completion_message = \'" << experiment.completionMessage() << "\', time_valid = (SELECT time_valid FROM settings) WHERE id = " << experiment.id();

    queries.emplace_back(std::move(stream.str()));

    addWriteQueries(queries);
}

void DBControl::addTemperatureLog(const std::vector<TemperatureLog> &logs)
{
    if (logs.empty())
        return;

    std::vector<std::string> queries;
    std::stringstream stream;
    std::stringstream stream2;

    bool tempLogs = false;
    bool debugTempLogs = false;

    stream << "INSERT INTO temperature_logs(experiment_id, elapsed_time, lid_temp, heat_block_zone_1_temp, heat_block_zone_2_temp, stage_id, cycle_num, step_id, ramp_id) VALUES";
    stream2 << "INSERT INTO temperature_debug_logs(experiment_id, elapsed_time, lid_drive, heat_block_zone_1_drive, heat_block_zone_2_drive, heat_sink_temp, heat_sink_drive) VALUES";

    for (std::vector<TemperatureLog>::const_iterator it = logs.begin(); it != logs.end(); ++it)
    {
        if (it->hasTemperatureInfo())
        {
            if (tempLogs)
                stream << ",";

            tempLogs = true;

            stream << "(" << it->experimentId() << "," << it->elapsedTime() << "," << ROUND(it->lidTemperature()) << "," << ROUND(it->heatBlockZone1Temperature())
                   << "," << ROUND(it->heatBlockZone2Temperature()) << "," << it->stageId() << "," << it->cycleNum() << ",";

            if (it->stepId() != -1)
                stream << it->stepId() << ",";
            else
                stream << "NULL,";

            if (it->rampId() != -1)
                stream << it->rampId() << ")";
            else
                stream << "NULL)";
        }

        if (it->hasDebugInfo())
        {
            if (debugTempLogs)
                stream2 << ",";

            debugTempLogs = true;

            stream2 << "(" << it->experimentId() << "," << it->elapsedTime() << "," << ROUND(it->lidDrive()) << ","
                   << ROUND(it->heatBlockZone1Drive()) << "," << ROUND(it->heatBlockZone2Drive()) << ","
                   << ROUND(it->heatSinkTemperature()) << "," << ROUND(it->heatSinkDrive()) << ")";
        }
    }

    if (tempLogs)
        queries.emplace_back(std::move(stream.str()));
    if (debugTempLogs)
        queries.emplace_back(std::move(stream2.str()));

    addWriteQueries(queries);
}

void DBControl::addFluorescenceData(const Experiment &experiment, const std::vector<Optics::FluorescenceData> &fluorescenceData, bool isRamp)
{
    if (fluorescenceData.empty())
        return;

    std::vector<std::string> queries;
    std::stringstream stream, stream2;

    bool hasDebugInfo = false;

    stream << "INSERT INTO fluorescence_data(experiment_id, step_id, ramp_id, baseline_value, fluorescence_value, well_num, channel, cycle_num) VALUES";
    stream2 << "INSERT INTO fluorescence_debug_data(experiment_id, step_id, ramp_id, well_num, channel, cycle_num, baseline_values, optical_values) VALUES";

    for (std::vector<Optics::FluorescenceData>::const_iterator it = fluorescenceData.begin(); it != fluorescenceData.end(); ++it)
    {
        stream << "(" << experiment.id() << ",";

        if (!isRamp)
            stream << experiment.protocol()->currentStep()->id() << ",NULL,";
        else
            stream << "NULL,"  << experiment.protocol()->currentRamp()->id() << ",";

        stream << it->baselineValue << "," << it->fluorescenceValue << "," << it->wellId << "," << (it->channel + 1) << "," << experiment.protocol()->currentStage()->currentCycle() << ")";

        if (it + 1 != fluorescenceData.end())
            stream << ",";

        if (!it->baselineData.empty() && !it->fluorescenceData.empty())
        {
            hasDebugInfo = true;

            stream2 << "(" << experiment.id() << ",";

            if (!isRamp)
                stream2 << experiment.protocol()->currentStep()->id() << ",NULL,";
            else
                stream2 << "NULL,"  << experiment.protocol()->currentRamp()->id() << ",";

            stream2 << it->wellId << "," << (it->channel + 1) << "," << experiment.protocol()->currentStage()->currentCycle() << ",\'";

            for (std::vector<int32_t>::const_iterator it2 = it->baselineData.begin(); it2 != it->baselineData.end(); ++it2)
            {
                stream2 << *it2;

                if (it2 + 1 != it->baselineData.end())
                    stream2 << ",";
            }

            stream2 << "\',\'";

            for (std::vector<int32_t>::const_iterator it2 = it->fluorescenceData.begin(); it2 != it->fluorescenceData.end(); ++it2)
            {
                stream2 << *it2;

                if (it2 + 1 != it->fluorescenceData.end())
                    stream2 << ",";
            }

            stream2 << "\')";

            if (it + 1 != fluorescenceData.end())
                stream2 << ",";
        }
    }

    queries.emplace_back(std::move(stream.str()));

    if (hasDebugInfo)
        queries.emplace_back(std::move(stream2.str()));

    addWriteQueries(queries);
}

void DBControl::addMeltCurveData(const Experiment &experiment, const std::vector<Optics::MeltCurveData> &meltCurveData)
{
    if (meltCurveData.empty())
        return;

    std::vector<std::string> queries;
    std::stringstream stream;

    stream << "INSERT INTO melt_curve_data(experiment_id, stage_id, well_num, temperature, fluorescence_value, channel, ramp_id, optical_values) VALUES";

    for (std::vector<Optics::MeltCurveData>::const_iterator it = meltCurveData.begin(); it != meltCurveData.end(); ++it)
    {
        stream << "(" << experiment.id() << "," << experiment.protocol()->currentStage()->id() << ","
               << it->wellId << "," << it->temperature << "," << it->fluorescenceValue << "," << (it->channel + 1) << "," << experiment.protocol()->currentRamp()->id() << ",\'";

        for (std::vector<int32_t>::const_iterator it2 = it->fluorescenceData.begin(); it2 != it->fluorescenceData.end(); ++it2)
        {
            stream << *it2;

            if (it2 + 1 != it->fluorescenceData.end())
                stream << ",";
        }

        stream << "\')";

        if (it + 1 != meltCurveData.end())
            stream << ",";
    }

    queries.emplace_back(std::move(stream.str()));

    addWriteQueries(queries);
}

Settings DBControl::getSettings()
{
    soci::row result;
    std::unique_lock<std::mutex> lock(_readMutex);

    BEGIN_DB_READ()
    *_readSession << "SELECT * FROM settings", soci::into(result);
    END_DB_READ();

    lock.unlock();

    Settings settings;

    if (result.get_indicator("debug") != soci::i_null)
        settings.setDebugMode(result.get<int>("debug"));

    if (result.get_indicator("time_zone") != soci::i_null)
        settings.setTimeZone(result.get<std::string>("time_zone"));

    if (result.get_indicator("wifi_ssid") != soci::i_null)
        settings.setWifiSsid(result.get<std::string>("wifi_ssid"));

    if (result.get_indicator("wifi_password") != soci::i_null)
        settings.setWifiPassword(result.get<std::string>("wifi_password"));

    if (result.get_indicator("wifi_enabled") != soci::i_null)
        settings.setWifiEnabled(result.get<int>("wifi_enabled"));

    if (result.get_indicator("calibration_id") != soci::i_null)
        settings.setCallibrationId(result.get<int>("calibration_id"));

    if (result.get_indicator("time_valid") != soci::i_null)
        settings.setTimeValid(result.get<int>("time_valid"));

    return settings;
}

void DBControl::updateSettings(const Settings &settings)
{
    if (!settings.hasDirty())
        return;

    std::stringstream stream;

    stream << "UPDATE settings SET ";

    if (settings.isDebugModeDirty())
    {
        stream << "debug = " << (settings.debugMode() ? 1 : 0);

        if (settings.isTimeZoneDirty())
            stream << ", ";
    }

    if (settings.isTimeZoneDirty())
    {
        stream << "time_zone = \'" << settings.timeZone() << '\'';

        if (settings.isWifiSsidDirty())
            stream << ", ";
    }

    if (settings.isWifiSsidDirty())
    {
        stream << "wifi_ssid = \'" << settings.wifiSsid() << '\'';

        if (settings.isWifiSsidPassword())
            stream << ", ";
    }

    if (settings.isWifiSsidDirty())
    {
        stream << "wifi_password = \'" << settings.wifiPassword() << '\'';

        if (settings.isWifiEnabledDirty())
            stream << ", ";
    }

    if (settings.isWifiEnabledDirty())
    {
        stream << "wifi_enabled = " << (settings.wifiEnabled() ? 1 : 0);

        if (settings.isCallibrationIdDirty())
            stream << ", ";
    }

    if (settings.isCallibrationIdDirty())
    {
        stream << "calibration_id = " << settings.calibrationId();

        if (settings.isTimeValidDirty())
            stream << ", ";
    }

    if (settings.isTimeValidDirty())
        stream << "time_valid = " << (settings.timeValid() ? 1 : 0);

    std::vector<soci::statement> statements;
    std::unique_lock<std::mutex> lock(_writeMutex);

    statements.emplace_back((_writeSession->prepare << stream.str()));

    write(statements);
}

void DBControl::getCurrentUpgrade(std::string &version, bool &downloaded)
{
    int tmpDownloaded = 0;
    soci::indicator indicator;

    {
        std::lock_guard<std::mutex> lock(_readMutex);

        BEGIN_DB_READ()
        *_readSession << "SELECT COUNT(1) version, downloaded FROM upgrades", soci::into(version, indicator), soci::into(tmpDownloaded, indicator);
        END_DB_READ();
    }

    downloaded = tmpDownloaded;
}

void DBControl::updateUpgrade(const Upgrade &upgrade)
{
    std::vector<soci::statement> statements;
    std::lock_guard<std::mutex> lock(_writeMutex);

    statements.emplace_back((_writeSession->prepare << "INSERT INTO upgrades(id, version, checksum, release_date, brief_description, full_description, password, downloaded) VALUES("
                             "1, :version, :checksum, :release_date, :brief_description, :full_description, :password, 0) ON DUPLICATE KEY UPDATE "
                             "version = :version, checksum = :checksum, release_date = :release_date, brief_description = :brief_description, full_description = :full_description, password = :password, downloaded = 0",
                             soci::use(upgrade.version()), soci::use(upgrade.checksum()), soci::use(upgrade.releaseDate()), soci::use(upgrade.briefDescription()), soci::use(upgrade.fullDescription()), soci::use(upgrade.password()),
                             soci::use(upgrade.version()), soci::use(upgrade.checksum()), soci::use(upgrade.releaseDate()), soci::use(upgrade.briefDescription()), soci::use(upgrade.fullDescription()), soci::use(upgrade.password())));

    write(statements);
}

void DBControl::setUpgradeDownloaded(bool state)
{
    std::vector<soci::statement> statements;
    std::lock_guard<std::mutex> lock(_writeMutex);

    statements.emplace_back((_writeSession->prepare << "UPDATE upgrades SET downloaded = :downloaded", soci::use(state ? 1 : 0)));

    write(statements);
}

int DBControl::getUserId(const std::string &token)
{
    int id = -1;

    std::lock_guard<std::mutex> lock(_readMutex);

    BEGIN_DB_READ()
    *_readSession << "SELECT user_id FROM user_tokens WHERE access_token = \'" << token << '\'', soci::into(id);
    END_DB_READ();

    return id;
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
        std::lock_guard<std::mutex> lock(_writeQueueMutex);

        _writeQueriesQueue.insert(_writeQueriesQueue.end(), std::make_move_iterator(queries.begin()), std::make_move_iterator(queries.end()));
        _writeCondition.notify_all();
    }
}

void DBControl::write(std::vector<soci::statement> &statements)
{
    if (!statements.empty())
    {
        bool tryAgain = false;

        do
        {
            try
            {
                soci::transaction transaction(*_writeSession);

                for (soci::statement &statement: statements)
                    statement.execute(true);

                transaction.commit();
            }
            catch (const soci::mysql_soci_error &ex)
            {
                if (ex.err_num_ == CR_SERVER_LOST || ex.err_num_ == CR_SERVER_GONE_ERROR ||
                        ex.err_num_ == CR_CONNECTION_ERROR || ex.err_num_ ==  CR_CONN_HOST_ERROR)
                {
                    if (!tryAgain)
                    {
                        try
                        {
                            {
                                std::lock_guard<std::mutex> lock(_readMutex);
                                _readSession->reconnect();
                            }

                            _writeSession->reconnect();

                            tryAgain = true;
                        }
                        catch (...)
                        {
                            qpcrApp.setException(std::current_exception());

                            throw std::runtime_error("DBControl::END_DB_READ - unable to reconnect to the MySQL server");
                        }
                    }
                    else
                    {
                        qpcrApp.setException(std::current_exception());

                        throw std::runtime_error("DBControl::END_DB_READ - unable to reconnect to the MySQL server");
                    }
                }
                else
                    throw;
            }
        }
        while (tryAgain);
    }
}
