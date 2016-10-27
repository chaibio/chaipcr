#include "adcdebuglogger.h"
#include "maincontrollers.h"
#include "qpcrapplication.h"

#include <map>
#include <thread>
#include <sstream>
#include <fstream>
#include <cstdio>
#include <boost/chrono.hpp>

ADCDebugLogger::SampleData::SampleData(std::int8_t heatBlockZone1Drive, std::int8_t heatBlockZone2Drive, std::int8_t fanDrive, std::int8_t muxChannel)
{
    time = boost::chrono::system_clock::now();

    this->heatBlockZone1Drive = heatBlockZone1Drive;
    this->heatBlockZone2Drive = heatBlockZone2Drive;
    this->fanDrive = fanDrive;
    this->muxChannel = muxChannel;
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

            _preSamples.emplace_back(HeatBlockInstance::getInstance()->zone1DriveValue() * 100, HeatBlockInstance::getInstance()->zone2DriveValue() * 100,
                                     HeatSinkInstance::getInstance()->fanDrive() * 100, OpticsInstance::getInstance()->getPhotodiodeMux().getChannel());

            _currentSmapleIt = std::prev(_preSamples.end());
        }
        else
        {
            if (_postSamples.size() == _postSamplesCount)
            {
                save();
                return;
            }

            _postSamples.emplace_back(HeatBlockInstance::getInstance()->zone1DriveValue() * 100, HeatBlockInstance::getInstance()->zone2DriveValue() * 100,
                                      HeatSinkInstance::getInstance()->fanDrive() * 100, OpticsInstance::getInstance()->getPhotodiodeMux().getChannel());

            _currentSmapleIt = std::prev(_postSamples.end());
        }

    }

    _currentSmapleIt->adcValues[state][channel] = value;
}

void ADCDebugLogger::save()
{
    //Order of ADC states here is hardcoded
    std::thread([](std::string savePath, std::vector<SampleData> preSamples, std::vector<SampleData> postSamples)
    {
        std::fstream stream((savePath + ".tmp").c_str(), std::fstream::out | std::fstream::trunc);

        stream << "time_offset,heat_block_1_drive,heat_block_2_drive,fan_drive,mux_channel,"
               << "heat_block_1,heat_block_2,";

        for (std::size_t i = 0; i < qpcrApp.settings().device.opticsChannels; ++i)
            stream << "optics_" << i + 1 << ',';

        stream << "lid\n";

        boost::chrono::system_clock::time_point triggetPoint = postSamples.front().time;

        for (const SampleData &sample: preSamples)
        {
            stream << boost::chrono::duration_cast<boost::chrono::milliseconds>(sample.time - triggetPoint).count() << ',' << (sample.heatBlockZone1Drive / 100.0)
                   << ',' << (sample.heatBlockZone2Drive / 100.0) << ',' << (sample.fanDrive / 100.0) << ',' << static_cast<int>(sample.muxChannel) << ',';

            for (std::map<ADCController::ADCState, std::map<std::size_t, std::int32_t>>::const_iterator it = sample.adcValues.begin(); it != sample.adcValues.end(); ++it)
            {
                for (std::map<std::size_t, std::int32_t>::const_iterator it2 = it->second.begin(); it2 != it->second.end(); ++it2)
                {
                    stream << it2->second;

                    if (std::next(it2) != it->second.end() || std::next(it) != sample.adcValues.end())
                        stream << ',';
                }
            }

            stream << '\n';
        }

        for (const SampleData &sample: postSamples)
        {
            stream << boost::chrono::duration_cast<boost::chrono::milliseconds>(sample.time - triggetPoint).count() << ',' << (sample.heatBlockZone1Drive / 100.0)
                   << ',' << (sample.heatBlockZone2Drive / 100.0) << ',' << (sample.fanDrive / 100.0) << ',' << static_cast<int>(sample.muxChannel) << ',';

            for (std::map<ADCController::ADCState, std::map<std::size_t, std::int32_t>>::const_iterator it = sample.adcValues.begin(); it != sample.adcValues.end(); ++it)
            {
                for (std::map<std::size_t, std::int32_t>::const_iterator it2 = it->second.begin(); it2 != it->second.end(); ++it2)
                {
                    stream << it2->second;

                    if (std::next(it2) != it->second.end() || std::next(it) != sample.adcValues.end())
                        stream << ',';
                }
            }

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
