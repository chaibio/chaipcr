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

#ifdef KERNEL_49
	#include <numeric>
#endif // KERNEL_49

#include "pcrincludes.h"
#include "pid.h"
#include "ledcontroller.h"
#include "optics.h"
#include "maincontrollers.h"
#include "qpcrapplication.h"
#include "experimentcontroller.h"
#include "util.h"
#include "logger.h"

std::vector<std::int32_t> removePeaks(std::vector<std::int32_t> data);

////////////////////////////////////////////////////////////////////////////////
// Class FluorescenceRoughData
struct Optics::FluorescenceRoughData
{
    FluorescenceRoughData(): baselineAccumulatedData(0), baselineValuesCount(0), fluorescenceAccumulatedData(0), fluorescenceValuesCount(0) {}

    void addData(const std::vector<std::int32_t> &data)
    {
        if (baselineValuesCount < (kADCReadsPerOpticalMeasurementFinal * kBaselineMeasurementsPerCycle))
            addData(data, baselineAccumulatedData, baselineValuesCount, baselineData);
        else
            addData(data, fluorescenceAccumulatedData, fluorescenceValuesCount, fluorescenceData);
    }

    inline std::int32_t averageBaselineValue() const noexcept { return baselineValuesCount > 0 ? baselineAccumulatedData / baselineValuesCount : 0; }
    inline std::int32_t averageFluorescenceValue() const noexcept { return fluorescenceValuesCount > 0 ? fluorescenceAccumulatedData / fluorescenceValuesCount : 0; }

    std::int32_t baselineAccumulatedData;
    std::int32_t baselineValuesCount;
    std::vector<std::int32_t> baselineData;

    std::int32_t fluorescenceAccumulatedData;
    std::int32_t fluorescenceValuesCount;
    std::vector<std::int32_t> fluorescenceData;

private:
    void addData(std::vector<std::int32_t> newData, std::int32_t &accumulatedData, std::int32_t &valuesCount, std::vector<std::int32_t> &data)
    {
        if (ExperimentController::getInstance()->debugMode())
            data.insert(data.end(), newData.begin(), newData.end());

        newData = removePeaks(newData);
        accumulatedData = std::accumulate(newData.begin(), newData.end(), accumulatedData);

        valuesCount += newData.size();
    }
};

// Class Optics
Optics::Optics(unsigned int lidSensePin, std::shared_ptr<LEDController> ledController, MUX &&photoDiodeMux)
    :_ledController(ledController),
     _lidSensePin(lidSensePin, GPIO::kInput),
     _photodiodeMux(std::move(photoDiodeMux))
{
    _lidOpen = false;
    _collectDataType = NoCollectionDataType;
    _collectDataTimer = new Poco::Util::Timer();
    _wellNumber = 0;
    _adcState = false;
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
    _lastAdcValues[channel] = adcValue;

    if (_adcState)
    {
        _adcValues.at(channel).emplace_back(adcValue);

        for (const std::vector<std::int32_t> &adcChannel: _adcValues)
        {
            if (adcChannel.size() < kADCReadsPerOpticalMeasurement)
                return;
        }

        _adcState = false;
        _adcCondition.notify_all();
    }
}

void Optics::startCollectData(CollectionDataType type)
{
    if (type == NoCollectionDataType)
        return;

    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

    CollectionDataType expectedType = NoCollectionDataType;

    if (_collectDataType.compare_exchange_strong(expectedType, type))
    {
        _wellNumber = 0;

        _fluorescenceData.clear();
        _meltCurveData.clear();

        if (_collectDataType == MeltCurveDataType)
            _ledController->activateLED(_wellNumber);

        _photodiodeMux.setChannel(_wellNumber);

        toggleCollectData();
    }
}

void Optics::stopCollectData()
{
    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

    if (_collectDataType.exchange(NoCollectionDataType) != NoCollectionDataType)
    {
        toggleCollectData();

        _wellNumber = 0;

        _fluorescenceData.clear();
        _meltCurveData.clear();
    }
}

void Optics::toggleCollectData(bool waitStop)
{
    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

    if (_collectDataType != NoCollectionDataType && !lidOpen())
    {
        _collectDataTimer->schedule(Poco::Util::TimerTask::Ptr(new Poco::Util::TimerTaskAdapter<Optics>(*this, &Optics::collectDataCallback)),
                                    Poco::Timestamp() + (kFluorescenceDataCollectionDelayTimeMs * 1000));
    }
    else
    {
        CollectionDataType type = _collectDataType.exchange(NoCollectionDataType);

        _adcState = false;
        _adcCondition.notify_all();
        _collectDataTimer->cancel(waitStop);
        _ledController->disableLEDs();

        _collectDataType = type;
    }
}

void Optics::collectDataCallback(Poco::Util::TimerTask &/*task*/)
{
    try
    {
        Util::NullMutex mutex;
        std::unique_lock<Util::NullMutex> lock(mutex);

        _adcValues.clear();
        _adcValues.resize(qpcrApp.settings().device.opticsChannels);

        for (std::vector<std::int32_t> &channel: _adcValues)
            channel.reserve(kADCReadsPerOpticalMeasurement);

        _adcState = true;
        _adcCondition.wait(lock);
        _adcState = false;

        if (_collectDataType == NoCollectionDataType)
            _adcValues.clear();

        if (!_adcValues.empty())
        {
            if (_collectDataType != MeltCurveDataType)
            {
                std::size_t i = 0;
                for (const std::vector<int32_t> &channel: _adcValues)
                    _fluorescenceData[_wellNumber][i++].addData(channel);
            }
            else
            {
                double temperature = HeatBlockInstance::getInstance()->temperature();
                bool debugMode = ExperimentController::getInstance()->debugMode();

                std::size_t i = 0;
                for (std::vector<int32_t> &channel: _adcValues)
                {
                    MeltCurveData data(std::round(Util::average(removePeaks(channel))), temperature, _wellNumber, i++);

                    if (debugMode)
                        data.fluorescenceData = std::move(channel);

                    std::lock_guard<std::mutex> meltCurveDataLock(_meltCurveDataMutex);
                    _meltCurveData.emplace_back(std::move(data));
                }
            }
        }

        ++_wellNumber;

        if (_wellNumber >= kWellCount)
        {
            _wellNumber = 0;

            //Assuming that other wells have the same amount of fluorescence data
            if ((_collectDataType == FluorescenceDataType || _collectDataType == FluorescenceCalibrationDataType) && !_fluorescenceData.empty())
            {
                int measurments = _collectDataType != FluorescenceCalibrationDataType ? kOpticalMeasurementsPerCycle : kOpticalMeasurementsPerCalibrationCycle;

                if (_fluorescenceData[0][0].fluorescenceValuesCount == measurments * kADCReadsPerOpticalMeasurementFinal)
                {
                    _collectDataType = NoCollectionDataType;

                    toggleCollectData(false);
                    fluorescenceDataCollected();

                    return;
                }
            }
        }

        //Assuming that other wells have the same amount of baseline data
        if (_collectDataType == MeltCurveDataType ||
                (!_fluorescenceData.empty() && _fluorescenceData[_wellNumber][0].baselineValuesCount == (kBaselineMeasurementsPerCycle * kADCReadsPerOpticalMeasurementFinal)))
            _ledController->activateLED(_wellNumber);

        _photodiodeMux.setChannel(_wellNumber);

        if (_collectDataType != NoCollectionDataType)
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

    if (_collectDataType == NoCollectionDataType)
    {
        for (std::pair<const unsigned int, std::map<std::size_t, FluorescenceRoughData>> &wellData: _fluorescenceData)
        {
            for (std::pair<const std::size_t, FluorescenceRoughData> &channelData: wellData.second)
            {
                FluorescenceData data(channelData.second.averageBaselineValue(), channelData.second.averageFluorescenceValue(), wellData.first, channelData.first);

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

    if (_collectDataType == MeltCurveDataType)
    {
        if (stopDataCollect)
        {
            _collectDataType = NoCollectionDataType;
            toggleCollectData();
        }
        else
            meltCurveDataLock.lock();

        meltCurveData = std::move(_meltCurveData);
    }

    return meltCurveData;
}

std::vector<std::int32_t> removePeaks(std::vector<std::int32_t> data)
{
    std::sort(data.begin(), data.end());

    std::vector<std::int32_t>::iterator medianIt = data.begin() + data.size() / 2;
    double median = data.size() % 2 != 0 ? *medianIt : (*(medianIt - 1) + *medianIt) / 2;

    for (int i = 0; i < kOpticalRejectedOutlierMeasurements; ++i)
    {
        if ((median - data.front()) > (data.back() - median))
            data.erase(data.begin());
        else
            data.pop_back();
    }

    return data;
}
