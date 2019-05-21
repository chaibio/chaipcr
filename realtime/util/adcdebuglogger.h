#ifndef ADCDEBUGLOGGER_H
#define ADCDEBUGLOGGER_H

#include "adccontroller.h"

#include <tuple>
#include <array>
#include <string>
#include <vector>
#include <atomic>
#include <mutex>
#include <boost/chrono.hpp>
#include <boost/circular_buffer.hpp>

class BaseADCDebugLogger
{
public:
    enum WorkState
    {
        NotWorkingState,
        WorkingState,
        SavingState
    };

    BaseADCDebugLogger(const std::string &storeFile);
    virtual ~BaseADCDebugLogger() {}

    bool start(std::size_t preSamplesCount, std::size_t postSamplesCount);
    void stop();

    inline void trigger() { _triggerState = _workState.load(); }

    virtual void store(ADCController::ADCState state, std::int32_t value, std::size_t channel = 0) = 0;

    inline WorkState workState() const { return _workState; }

protected:
    virtual void starting() = 0;
    virtual void stopping() = 0;

protected:
    std::string _storeFile;

    std::mutex _mutex;

    std::size_t _preSamplesCount;
    std::size_t _postSamplesCount;

    std::atomic<WorkState> _workState;
    std::atomic<bool> _triggerState;
};

template <int Channels>
class ADCDebugLogger : public BaseADCDebugLogger
{
public:
    ADCDebugLogger(const std::string &storeFile);

    void store(ADCController::ADCState state, std::int32_t value, std::size_t channel = 0);

protected:
    void starting();
    void stopping();

private:
    void save();

private:
    class SampleData
    {
    public:
        SampleData();

        void write(std::ostream &stream, const boost::chrono::steady_clock::time_point &triggetPoint) const;

        static void writeHeaders(std::ostream &stream);

    public:
        boost::chrono::steady_clock::time_point time;

        std::tuple<std::int32_t, std::int32_t, std::array<std::int32_t, Channels>, std::int32_t> adcValues;
        std::uint8_t adcValuesSize;

        std::int8_t heatBlockZone1Drive;
        std::int8_t heatBlockZone2Drive;
        std::int8_t fanDrive;
        std::int8_t muxChannel;
        std::int8_t lidDrive;
        std::uint16_t heatSinkAdcValue;
    };

    boost::circular_buffer<SampleData> _preSamples;
    boost::circular_buffer<SampleData> _postSamples;

    typename boost::circular_buffer<SampleData>::iterator _currentSampleIt;
};

#include "adcdebuglogger.ipp"

#endif // ADCDEBUGLOGGER_H
