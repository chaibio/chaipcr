/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef _OPTICS_H_
#define _OPTICS_H_

#include "icontrol.h"
#include "adcconsumer.h"
#include "gpio.h"
#include "mux.h"
#include "lockfreesignal.h"

#include <map>
#include <vector>
#include <memory>
#include <atomic>
#include <mutex>
#include <condition_variable>

class LEDController;

namespace Poco { namespace Util { class Timer; class TimerTask; } }

////////////////////////////////////////////////////////////////////////////////
// Class Optics
class Optics : public IControl, public ADCConsumer
{
public:
    enum CollectionDataType
    {
        NoCollectionDataType,
        FluorescenceDataType,
        FluorescenceCalibrationDataType,
        MeltCurveDataType
    };

    struct FluorescenceData
    {
        FluorescenceData(int32_t baselineValue, int32_t fluorescenceValue, unsigned int wellId, std::size_t channel):
            baselineValue(baselineValue), fluorescenceValue(fluorescenceValue), wellId(wellId), channel(channel) {}

        int32_t baselineValue;
        int32_t fluorescenceValue;

        unsigned int wellId;
        std::size_t channel;

        std::vector<int32_t> baselineData;
        std::vector<int32_t> fluorescenceData;
    };

    struct MeltCurveData
    {
        MeltCurveData(int32_t fluorescenceValue, double temperature, unsigned int wellId, std::size_t channel):
            fluorescenceValue(fluorescenceValue), temperature(temperature), wellId(wellId), channel(channel) {}

        MeltCurveData(MeltCurveData &&other)
        {
            fluorescenceValue = other.fluorescenceValue;
            temperature = other.temperature;
            wellId = other.wellId;
            channel = other.channel;
            fluorescenceData = std::move(other.fluorescenceData);
        }

        int32_t fluorescenceValue;
        double temperature;
        unsigned int wellId;
        std::size_t channel;

        std::vector<int32_t> fluorescenceData;
    };

    Optics(unsigned int lidSensePin, std::shared_ptr<LEDController> ledController, MUX &&photoDiodeMux);
    ~Optics();

    void process();

    void setADCValue(int32_t adcValue, std::size_t channel);
    inline const std::map<std::size_t, std::atomic<int32_t>>& lastAdcValues() const noexcept { return _lastAdcValues; }
	
	//accessors
    inline bool lidOpen() const noexcept { return _lidOpen; }

    inline CollectionDataType collectDataType() const noexcept { return _collectDataType; }
    void startCollectData(CollectionDataType type);
    void stopCollectData();

    inline unsigned wellNumber() const noexcept { return _wellNumber; } //Yes, it's used in multithreading. Yes, it isn't thread safe here. It's just for testing

    inline std::shared_ptr<LEDController> getLedController() const noexcept { return _ledController; }
    inline MUX& getPhotodiodeMux() noexcept { return _photodiodeMux; }

    std::vector<FluorescenceData> getFluorescenceData();
    std::vector<MeltCurveData> getMeltCurveData(bool stopDataCollect = true);

    boost::signals2::lockfree_signal<void()> fluorescenceDataCollected;

private:
    void toggleCollectData(bool cancelCollect = true);
    void collectDataCallback(Poco::Util::TimerTask &task);
	
private:
    struct FluorescenceRoughData;

    std::shared_ptr<LEDController> _ledController;

    std::atomic<bool> _lidOpen;
    GPIO _lidSensePin;

    std::vector<std::vector<int32_t>> _adcValues;
    std::atomic<bool> _adcState;
    std::condition_variable_any _adcCondition;

    std::atomic<CollectionDataType> _collectDataType;
    Poco::Util::Timer *_collectDataTimer;
    mutable std::recursive_mutex _collectDataMutex;

    unsigned int _wellNumber;

    std::map<unsigned int, std::map<std::size_t, FluorescenceRoughData>> _fluorescenceData;

    std::vector<MeltCurveData> _meltCurveData;
    std::mutex _meltCurveDataMutex;

    MUX _photodiodeMux;

    bool _firstErrorState;

    //Hardcode for testing
    std::map<std::size_t, std::atomic<int32_t>> _lastAdcValues; //Not thread safe
};

#endif
