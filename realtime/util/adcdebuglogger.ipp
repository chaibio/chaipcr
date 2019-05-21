#ifndef ADCDEBUGLOGGER_IPP
#define ADCDEBUGLOGGER_IPP

#include "adcdebuglogger.h"
#include "maincontrollers.h"
#include "thread"

#include <fstream>
#include <thread>

template <int Channels>
ADCDebugLogger<Channels>::SampleData::SampleData()
{
    time = boost::chrono::steady_clock::now();

    adcValuesSize = 0;
    heatBlockZone1Drive = HeatBlockInstance::getInstance()->zone1DriveValue() * 100;
    heatBlockZone2Drive = HeatBlockInstance::getInstance()->zone2DriveValue() * 100;
    fanDrive = HeatSinkInstance::getInstance()->fanDrive() * 100;
    muxChannel = OpticsInstance::getInstance()->getPhotodiodeMux().getChannel();
    lidDrive = LidInstance::getInstance()->drive() * 100;
    heatSinkAdcValue = HeatSinkInstance::getInstance()->adcValue();
}

template <int Channels>
void ADCDebugLogger<Channels>::SampleData::write(std::ostream &stream, const boost::chrono::steady_clock::time_point &triggetPoint) const
{
    stream << boost::chrono::duration_cast<boost::chrono::milliseconds>(time - triggetPoint).count() << ',' << (heatBlockZone1Drive / 100.0)
           << ',' << (heatBlockZone2Drive / 100.0) << ',' << (fanDrive / 100.0) << ',' << static_cast<int>(muxChannel) << ',' << (lidDrive / 100.0)
           << ',' << heatSinkAdcValue << ',';

    stream << std::get<ADCController::EReadZone1Singular>(adcValues) << ',';
    stream << std::get<ADCController::EReadZone2Singular>(adcValues) << ',';

    for (std::size_t i = 0; i < Channels; ++i)
        stream << std::get<ADCController::EReadLIA>(adcValues).at(i) << ',';

    stream << std::get<ADCController::EReadLid>(adcValues);
}

template <int Channels>
void ADCDebugLogger<Channels>::SampleData::writeHeaders(std::ostream &stream)
{
    //The order of the ADC states here is hardcoded and repeats the order of the states from ADCController::ADCState
    stream << "time_offset,heat_block_1_drive,heat_block_2_drive,fan_drive,mux_channel,lid_drive,heat_sink_adc,heat_block_1,heat_block_2,";

    for (std::size_t i = 0; i < Channels; ++i)
        stream << "optics_" << i + 1 << ',';

    stream << "lid";
}

template <int Channels>
ADCDebugLogger<Channels>::ADCDebugLogger(const std::string &storeFile)
    :BaseADCDebugLogger(storeFile)
{
    _currentSampleIt = _preSamples.end();
}

template <int Channels>
void ADCDebugLogger<Channels>::store(ADCController::ADCState state, int32_t value, std::size_t channel)
{
    std::unique_lock<std::mutex> lock(_mutex, std::defer_lock);

    if (lock.try_lock())
    {
        if (workState() != WorkingState)
            return;

        bool triggerState = _triggerState;

        if (_currentSampleIt == _preSamples.end() || _currentSampleIt->adcValuesSize == (ADCController::EFinal + Channels - 1))
        {
            if (!triggerState)
            {
                _preSamples.push_back();
                _currentSampleIt = std::prev(_preSamples.end());
            }
            else
            {
                _postSamples.push_back();
                _currentSampleIt = std::prev(_postSamples.end());
            }
        }

        switch (state)
        {
        case ADCController::EReadZone1Singular:
            std::get<ADCController::EReadZone1Singular>(_currentSampleIt->adcValues) = value;
            break;

        case ADCController::EReadZone2Singular:
            std::get<ADCController::EReadZone2Singular>(_currentSampleIt->adcValues) = value;
            break;

        case ADCController::EReadLIA:
            std::get<ADCController::EReadLIA>(_currentSampleIt->adcValues).at(channel) = value;
            break;

        case ADCController::EReadLid:
            std::get<ADCController::EReadLid>(_currentSampleIt->adcValues) = value;
            break;

        default:
            break;
        }

        ++_currentSampleIt->adcValuesSize;

        if (triggerState && _currentSampleIt->adcValuesSize == (ADCController::EFinal + Channels - 1) && _postSamples.size() == _postSamplesCount)
            save();
    }
}

template <int Channels>
void ADCDebugLogger<Channels>::starting()
{
    _preSamples.clear();
    _postSamples.clear();

    _preSamples.set_capacity(_preSamplesCount);
    _postSamples.set_capacity(_postSamplesCount);

    _currentSampleIt = _preSamples.end();
}

template <int Channels>
void ADCDebugLogger<Channels>::stopping()
{
    _preSamples.set_capacity(0);
    _postSamples.set_capacity(0);

    _currentSampleIt = _preSamples.end();
}

template <int Channels>
void ADCDebugLogger<Channels>::save()
{
    _workState = SavingState;

    std::thread([=]()
    {
        sched_param params;
        params.__sched_priority = sched_get_priority_max(SCHED_IDLE);

        pthread_setschedparam(pthread_self(), SCHED_IDLE, &params);

        std::fstream stream((_storeFile + ".tmp").c_str(), std::fstream::out | std::fstream::trunc);

        SampleData::writeHeaders(stream);

        stream << '\n';

        boost::chrono::steady_clock::time_point triggetPoint = _postSamples.front().time;

        for (const SampleData &sample: _preSamples)
        {
            sample.write(stream, triggetPoint);

            stream << '\n';
        }

        for (const SampleData &sample: _postSamples)
        {
            sample.write(stream, triggetPoint);

            stream << '\n';
        }

        stream.flush();
        stream.close();

        std::remove(_storeFile.c_str());
        std::rename((_storeFile + ".tmp").c_str(), _storeFile.c_str());

        if (_preSamplesCount > 0)
        {
            starting();

            _triggerState = false;
            _workState = WorkingState;
        }
        else
        {
            stopping();

            _workState = NotWorkingState;
        }
    }).detach();
}

#endif // ADCDEBUGLOGGER_IPP
