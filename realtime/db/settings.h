#ifndef SETTINGS_H
#define SETTINGS_H

#include <atomic>
#include <boost/date_time/posix_time/ptime.hpp>

class Settings
{
public:
    class TemperatureLogs
    {
    public:
        TemperatureLogs()
        {
            _temperatureLogsState = false;
            _debugTemperatureLogsState = false;
        }

        inline void setTemperatureLogs(bool state) { _temperatureLogsState = state; }
        inline bool hasTemperatureLogs() const { return _temperatureLogsState; }

        inline void setDebugTemperatureLogs(bool state) { _debugTemperatureLogsState = state; }
        inline bool hasDebugTemperatureLogs() const { return _debugTemperatureLogsState; }

        inline void setStartTime(const boost::posix_time::ptime &time) { _startTime = time; }
        inline const boost::posix_time::ptime& startTime() const { return _startTime; }

    private:
        std::atomic<bool> _temperatureLogsState;
        std::atomic<bool> _debugTemperatureLogsState;

        boost::posix_time::ptime _startTime;
    }temperatureLogs;

    Settings()
    {
        _debugMode = false;
    }

    inline void setDebugMode(bool mode) { _debugMode = mode; }
    inline bool debugMode() const { return _debugMode; }

private:
    std::atomic<bool> _debugMode;
};

#endif // SETTINGS_H
