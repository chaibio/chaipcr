#ifndef ADCDEBUGLOGGER_H
#define ADCDEBUGLOGGER_H

#include "adccontroller.h"

#include <string>
#include <vector>
#include <atomic>
#include <mutex>
#include <boost/chrono.hpp>

class ADCDebugLogger
{
public:
    ADCDebugLogger(const std::string &storeFile);

    void start(std::size_t preSamplesCount, std::size_t postSamplesCount);
    void stop();
    void trigger();

    void store(ADCController::ADCState state, std::int32_t value, std::size_t channel = 0);

    inline bool isWorking() const { return _workState; }

private:
    void save();

private:
    class SampleData
    {
    public:
        SampleData();

        void write(std::ostream &stream, const boost::chrono::system_clock::time_point &triggetPoint) const;

        static void writeHeaders(std::ostream &stream);

    public:
        boost::chrono::system_clock::time_point time;

        std::map<ADCController::ADCState, std::map<std::size_t, std::int32_t>> adcValues;

        std::int8_t heatBlockZone1Drive;
        std::int8_t heatBlockZone2Drive;
        std::int8_t fanDrive;
        std::int8_t muxChannel;
        std::int8_t lidDrive;
        std::uint32_t heatSinkAdcValue;
    };

    std::string _storeFile;

    std::mutex _mutex;

    std::size_t _preSamplesCount;
    std::size_t _postSamplesCount;

    std::atomic<bool> _workState;
    std::atomic<bool> _triggerState;

    std::vector<SampleData> _preSamples;
    std::vector<SampleData> _postSamples;
    std::vector<SampleData>::iterator _currentSmapleIt;
};

#endif // ADCDEBUGLOGGER_H
