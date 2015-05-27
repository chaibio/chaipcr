#include "csvcontrol.h"
#include "optics.h"
#include "experiment.h"
#include "protocol.h"
#include "stage.h"

#include <sstream>
#include <fstream>

#define STORAGE_PATH "/root/tmp/csv_data/"

inline std::string ptime_to_string(const boost::posix_time::ptime &date_time)
{
    if (date_time.is_not_a_date_time())
        return std::string();

    std::stringstream stream;
    stream << date_time.date().year() << "-" << date_time.date().month() << "-" << date_time.date().day() << " "
           << date_time.time_of_day().hours() << ":" << date_time.time_of_day().minutes() << ":" << date_time.time_of_day().seconds();

    return stream.str();
}

CSVControl::CSVControl()
{
    _writeThreadState = false;

    start();
}

CSVControl::~CSVControl()
{
    stop();

    if (joinable())
        join();
}

void CSVControl::process()
{
    std::mutex tmpMutex;
    std::unique_lock<std::mutex> tmpLock(tmpMutex);

    _writeThreadState = true;
    while (_writeThreadState)
    {
        _writeCondition.wait(tmpLock);

        {
            std::unique_lock<std::mutex> meltCurveLock(_meltCurveMutex);

            for (const std::pair<std::string, std::vector<Optics::MeltCurveData>> &data: _meltCurveData)
            {
                std::ofstream fileStream(STORAGE_PATH + data.first);

                if (fileStream.is_open())
                {
                    for (const Optics::MeltCurveData &meltCurveData: data.second)
                        fileStream << meltCurveData.wellId << ',' << meltCurveData.temperature << ',' << meltCurveData.fluorescenceValue << '\n';
                }
            }

            _meltCurveData.clear();
        }
    }
}

void CSVControl::stop()
{
    _writeThreadState = false;
    _writeCondition.notify_all();
}

void CSVControl::writeMeltCurveData(const Experiment &experiment, std::vector<Optics::MeltCurveData> &&data)
{
    if (data.empty())
        return;

    std::stringstream stream;
    stream << ptime_to_string(experiment.startedAt()) << '_' << experiment.id() << '_' << experiment.protocol()->currentStage()->id();

    std::unique_lock<std::mutex> lock(_meltCurveMutex);
    _meltCurveData.emplace_back(stream.str(), std::move(data));
    lock.unlock();

    _writeCondition.notify_all();
}

