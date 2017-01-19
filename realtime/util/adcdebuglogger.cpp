#include "adcdebuglogger.h"
#include "maincontrollers.h"
#include "qpcrapplication.h"

#include <map>
#include <thread>
#include <sstream>
#include <fstream>
#include <cstdio>
#include <boost/chrono.hpp>

ADCDebugLogger::SampleData::SampleData()
{
    time = boost::chrono::system_clock::now();

    heatBlockZone1Drive = HeatBlockInstance::getInstance()->zone1DriveValue() * 100;
    heatBlockZone2Drive = HeatBlockInstance::getInstance()->zone2DriveValue() * 100;
    fanDrive = HeatSinkInstance::getInstance()->fanDrive() * 100;
    muxChannel = OpticsInstance::getInstance()->getPhotodiodeMux().getChannel();
    lidDrive = LidInstance::getInstance()->drive() * 100;
    heatSinkAdcValue = HeatSinkInstance::getInstance()->adcValue();
}

void ADCDebugLogger::SampleData::write(std::ostream &stream, const boost::chrono::system_clock::time_point &triggetPoint) const
{
    stream << boost::chrono::duration_cast<boost::chrono::milliseconds>(time - triggetPoint).count() << ',' << (heatBlockZone1Drive / 100.0)
           << ',' << (heatBlockZone2Drive / 100.0) << ',' << (fanDrive / 100.0) << ',' << static_cast<int>(muxChannel) << ',' << (lidDrive / 100.0)
           << ',' << heatSinkAdcValue << ',';

    for (std::map<ADCController::ADCState, std::map<std::size_t, std::int32_t>>::const_iterator it = adcValues.begin(); it != adcValues.end(); ++it)
    {
        for (std::map<std::size_t, std::int32_t>::const_iterator it2 = it->second.begin(); it2 != it->second.end(); ++it2)
        {
            stream << it2->second;

            if (std::next(it2) != it->second.end() || std::next(it) != adcValues.end())
                stream << ',';
        }
    }
}

void ADCDebugLogger::SampleData::writeHeaders(std::ostream &stream)
{
    //Order of ADC states here is hardcoded
    stream << "time_offset,heat_block_1_drive,heat_block_2_drive,fan_drive,mux_channel,lid_drive,heat_sink_adc,heat_block_1,heat_block_2,";

    for (std::size_t i = 0; i < qpcrApp.settings().device.opticsChannels; ++i)
        stream << "optics_" << i + 1 << ',';

    stream << "lid";
}

ADCDebugLogger::ADCDebugLogger(const std::string &storeFile)
{
    _storeFile = storeFile;
    _preSamplesCount = 0;
    _postSamplesCount = 0;
    _workState = false;
    _triggerState = false;
    _currentSmapleIt = _preSamples.end();
}

void ADCDebugLogger::start(std::size_t preSamplesCount, std::size_t postSamplesCount)
{
    if (preSamplesCount == 0 || postSamplesCount == 0)
        std::logic_error("Pre/post samples cound must not be 0");

    std::lock_guard<std::mutex> lock(_mutex);

    _triggerState = false;
    _preSamplesCount = preSamplesCount;
    _postSamplesCount = postSamplesCount;
    _preSamples.clear();
    _postSamples.clear();
    _preSamples.reserve(preSamplesCount);
    _postSamples.reserve(postSamplesCount);
    _currentSmapleIt = _preSamples.end();
    _workState = true;
}

void ADCDebugLogger::stop()
{
    std::lock_guard<std::mutex> lock(_mutex);

    _workState = false;
    _triggerState = false;
    _preSamplesCount = 0;
    _postSamplesCount = 0;
    _preSamples.clear();
    _postSamples.clear();
    _currentSmapleIt = _preSamples.end();
}

void ADCDebugLogger::trigger()
{
    _triggerState = _workState.load();
}

void ADCDebugLogger::store(ADCController::ADCState state, std::int32_t value, std::size_t channel)
{
    std::lock_guard<std::mutex> lock(_mutex);

    if (!isWorking())
        return;

    if (_currentSmapleIt == _preSamples.end() || _currentSmapleIt->adcValues.size() == ADCController::EFinal)
    {
        if (!_triggerState)
        {
            if (_preSamples.size() == _preSamplesCount)
                _preSamples.erase(_preSamples.begin());

            _preSamples.emplace_back();
            _currentSmapleIt = std::prev(_preSamples.end());
        }
        else
        {
            if (_postSamples.size() == _postSamplesCount)
            {
                save();
                return;
            }

            _postSamples.emplace_back();
            _currentSmapleIt = std::prev(_postSamples.end());
        }

    }

    _currentSmapleIt->adcValues[state][channel] = value;
}

void ADCDebugLogger::save()
{
    std::thread([](std::string savePath, std::vector<SampleData> preSamples, std::vector<SampleData> postSamples)
    {
        sched_param params;
        params.__sched_priority = sched_get_priority_max(SCHED_IDLE);

        pthread_setschedparam(pthread_self(), SCHED_IDLE, &params);

        std::fstream stream((savePath + ".tmp").c_str(), std::fstream::out | std::fstream::trunc);

        SampleData::writeHeaders(stream);

        stream << '\n';

        boost::chrono::system_clock::time_point triggetPoint = postSamples.front().time;

        for (const SampleData &sample: preSamples)
        {
            sample.write(stream, triggetPoint);

            stream << '\n';
        }

        for (const SampleData &sample: postSamples)
        {
            sample.write(stream, triggetPoint);

            stream << '\n';
        }

        stream.flush();
        stream.close();

        std::remove(savePath.c_str());
        std::rename((savePath + ".tmp").c_str(), savePath.c_str());

    }, _storeFile, std::move(_preSamples), std::move(_postSamples)).detach();

    _currentSmapleIt = _preSamples.end();
    _triggerState = false;
}
