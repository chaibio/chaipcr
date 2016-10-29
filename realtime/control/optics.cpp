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

#include <Poco/Timestamp.h>
#include <Poco/Util/Timer.h>
#include <Poco/Util/TimerTaskAdapter.h>

#include <limits>
#include <sstream>

#include "pcrincludes.h"
#include "pid.h"
#include "ledcontroller.h"
#include "optics.h"
#include "maincontrollers.h"
#include "qpcrapplication.h"
#include "experimentcontroller.h"
#include "util.h"
#include "logger.h"

////////////////////////////////////////////////////////////////////////////////
// Class FluorescenceRoughData
struct Optics::FluorescenceRoughData
{
    inline int32_t accumulateBaselineData() const
    {
        return !baselineData.empty() ? std::accumulate(baselineData.begin(), baselineData.end(), 0) / static_cast<int32_t>(baselineData.size()) : 0;
    }

    inline int32_t accumulateFluorescenceData() const
    {
        return !fluorescenceData.empty() ? std::accumulate(fluorescenceData.begin(), fluorescenceData.end(), 0) / static_cast<int32_t>(fluorescenceData.size()) : 0;
    }

    std::vector<int32_t> baselineData;
    std::vector<int32_t> fluorescenceData;
};

// Class Optics
Optics::Optics(unsigned int lidSensePin, std::shared_ptr<LEDController> ledController, MUX &&photoDiodeMux)
    :_ledController(ledController),
     _lidSensePin(lidSensePin, GPIO::kInput),
     _photodiodeMux(std::move(photoDiodeMux))
{
    _lidOpen = false;
    _collectData = false;
    _meltCurveCollection = false;
    _collectDataTimer = new Poco::Util::Timer();
    _wellNumber = 0;
    _adcValue = {0, 0};
    _firstErrorState = false;
}

Optics::~Optics()
{
    delete _collectDataTimer;
}

void Optics::process()
{
    bool lidState = _lidSensePin.value() == GPIO::kHigh ? true : false;
    if (_lidOpen.compare_exchange_strong(lidState, !lidState))
    {
        toggleCollectData();

        if (_lidOpen && !qpcrApp.isMachinePaused())
            qpcrApp.stopExperiment("Lid opened during run");
    }
}

void Optics::setADCValue(int32_t adcValue, std::size_t channel)
{
    if (adcValue == std::numeric_limits<int32_t>::max() || adcValue == std::numeric_limits<int32_t>::min())
    {
        if (_firstErrorState)
        {
            std::stringstream stream;
            stream << "Invalid optical read (" << (adcValue == std::numeric_limits<int32_t>::max() ? 1 : 0) << ")";

            throw std::runtime_error(stream.str());
        }
        else
        {
            _firstErrorState = true;

            APP_LOGGER << "Optics::setADCValue - invalid adc value occured. Skipping";

            return;
        }
    }

    _firstErrorState = false;

    {
        std::lock_guard<std::mutex> lock(_adcMutex);

        _adcValue = {adcValue, channel};
        _adcCondition.notify_all();
    }

    _lastAdcValues[channel] = adcValue;
}

void Optics::setCollectData(bool state, bool isMeltCurve)
{
    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

    if (_collectData.exchange(state) != state)
    {
        if (_collectData)
        {
            _meltCurveCollection = isMeltCurve;
            _wellNumber = 0;

            _fluorescenceData.clear();
            _meltCurveData.clear();

            if (isMeltCurve)
                _ledController->activateLED(kWellToLedMappingList.at(_wellNumber));

            _photodiodeMux.setChannel(_wellNumber);
        }

        toggleCollectData();

        if (!_collectData)
        {
            _meltCurveCollection = false;
            _wellNumber = 0;

            _fluorescenceData.clear();
            _meltCurveData.clear();
        }
    }
}

void Optics::toggleCollectData(bool waitStop)
{
    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

    if (_collectData && !lidOpen())
    {
        _collectDataTimer->schedule(Poco::Util::TimerTask::Ptr(new Poco::Util::TimerTaskAdapter<Optics>(*this, &Optics::collectDataCallback)),
                                    Poco::Timestamp() + (kFluorescenceDataCollectionDelayTimeMs * 1000));
    }
    else
    {
        bool collect = _collectData.exchange(false);

        {
            std::unique_lock<std::mutex> lock(_adcMutex);
            _adcCondition.notify_all();
        }

        _collectDataTimer->cancel(waitStop);
        _ledController->disableLEDs();

        _collectData = collect;
    }
}

void Optics::collectDataCallback(Poco::Util::TimerTask &/*task*/)
{
    try
    {
        std::vector<std::vector<int32_t>> adcValues;
        adcValues.resize(qpcrApp.settings().device.opticsChannels);

        {
            std::size_t doneChannels = 0;
            std::unique_lock<std::mutex> lock(_adcMutex);

            while (doneChannels < adcValues.size())
            {
                if (_collectData)
                {
                    _adcCondition.wait(lock);

                    std::vector<int32_t> &channel = adcValues.at(_adcValue.second);

                    if (channel.size() < kADCReadsPerOpticalMeasurement)
                    {
                        channel.emplace_back(_adcValue.first);

                        if (channel.size() == kADCReadsPerOpticalMeasurement)
                            ++doneChannels;
                    }

                    if (!_collectData)
                        break;
                }
                else
                    break;
            }
        }

        if (!_collectData)
            adcValues.clear();

        if (!adcValues.empty())
        {
            if (!_meltCurveCollection)
            {
                std::size_t i = 0;
                for (std::vector<int32_t> &channel: adcValues)
                {
                    for (int32_t value: channel)
                    {
                        if (_fluorescenceData[_wellNumber][i].baselineData.size() < (kBaselineMeasurementsPerCycle * kADCReadsPerOpticalMeasurement))
                            _fluorescenceData[_wellNumber][i].baselineData.emplace_back(value);
                        else
                            _fluorescenceData[_wellNumber][i].fluorescenceData.emplace_back(value);
                    }

                    ++i;
                }
            }
            else
            {
                double temperature = HeatBlockInstance::getInstance()->temperature();
                bool debugMode = ExperimentController::getInstance()->debugMode();

                std::size_t i = 0;
                for (std::vector<int32_t> &channel: adcValues)
                {
                    MeltCurveData data(std::round(Util::average(channel.begin(), channel.end())), temperature, _wellNumber, i++);

                    if (debugMode)
                        data.fluorescenceData = std::move(channel);

                    std::lock_guard<std::mutex> meltCurveDataLock(_meltCurveDataMutex);
                    _meltCurveData.emplace_back(std::move(data));
                }
            }
        }

        ++_wellNumber;

        if (_wellNumber >= kWellToLedMappingList.size())
        {
            _wellNumber = 0;

            //Assuming that other wells have the same amount of fluorescence data
            if (!_meltCurveCollection && _fluorescenceData[0][0].fluorescenceData.size() == (kOpticalMeasurementsPerCycle * kADCReadsPerOpticalMeasurement))
            {
                _collectData = false;

                toggleCollectData(false);
                fluorescenceDataCollected();

                return;
            }
        }

        //Assuming that other wells have the same amount of baseline data
        if (_meltCurveCollection || _fluorescenceData[_wellNumber][0].baselineData.size() == (kBaselineMeasurementsPerCycle * kADCReadsPerOpticalMeasurement))
            _ledController->activateLED(kWellToLedMappingList.at(_wellNumber));

        _photodiodeMux.setChannel(_wellNumber);

        if (_collectData)
        {
            _collectDataTimer->schedule(Poco::Util::TimerTask::Ptr(new Poco::Util::TimerTaskAdapter<Optics>(*this, &Optics::collectDataCallback)),
                                        Poco::Timestamp() + (kFluorescenceDataCollectionDelayTimeMs * 1000));
        }
    }
    catch (...)
    {
        qpcrApp.setException(std::current_exception());
    }
}

std::vector<Optics::FluorescenceData> Optics::getFluorescenceData()
{
    std::vector<Optics::FluorescenceData> dataList;
    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

    if (!_collectData)
    {
        for (std::pair<const unsigned int, std::map<std::size_t, FluorescenceRoughData>> &wellData: _fluorescenceData)
        {
            for (std::pair<const std::size_t, FluorescenceRoughData> &channelData: wellData.second)
            {
                FluorescenceData data(channelData.second.accumulateBaselineData(), channelData.second.accumulateFluorescenceData(), wellData.first, channelData.first);

                if (ExperimentController::getInstance()->debugMode())
                {
                    data.fluorescenceData = std::move(channelData.second.fluorescenceData);
                    data.baselineData = std::move(channelData.second.baselineData);
                }

                dataList.push_back(data);
            }
        }

        _fluorescenceData.clear();
    }

    return dataList;
}

std::vector<Optics::MeltCurveData> Optics::getMeltCurveData(bool stopDataCollect)
{
    std::vector<MeltCurveData> meltCurveData;
    std::lock_guard<std::recursive_mutex> collectDataLock(_collectDataMutex);
    std::unique_lock<std::mutex> meltCurveDataLock(_meltCurveDataMutex, std::defer_lock);

    if (_collectData && _meltCurveCollection)
    {
        if (stopDataCollect)
        {
            _collectData = _meltCurveCollection = false;
            toggleCollectData();
        }
        else
            meltCurveDataLock.lock();

        meltCurveData = std::move(_meltCurveData);
    }

    return meltCurveData;
}
