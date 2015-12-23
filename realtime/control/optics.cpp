#include <Poco/Timer.h>

#include "pcrincludes.h"
#include "pid.h"
#include "ledcontroller.h"
#include "optics.h"
#include "maincontrollers.h"
#include "qpcrapplication.h"

using namespace std;
using namespace Poco;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics(unsigned int lidSensePin, shared_ptr<LEDController> ledController, MUX &&photoDiodeMux)
    :_ledController(ledController),
     _lidSensePin(lidSensePin, GPIO::kInput),
     _photodiodeMux(move(photoDiodeMux))
{
    _lidOpen = false;
    _collectData = false;
    _meltCurveCollection = false;
    _collectDataTimer = new Timer;
    _wellNumber = 0;
    _adcValue = {0, 0};

    _collectDataTimer->setPeriodicInterval(0);
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

        if (_lidOpen)
            qpcrApp.stopExperiment("Lid opened during run");
    }
}

void Optics::setADCValue(unsigned int adcValue, std::size_t channel)
{
    {
        std::lock_guard<std::mutex> lock(_adcMutex);

        _adcValue = {(adcValue >> 7), channel}; //convert positive range of signed 24 bit ADC value to 16 bit unsigned value
        _adcCondition.notify_all();
    }

    _lastAdcValues[channel] = (adcValue >> 7);
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

void Optics::toggleCollectData()
{
    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

    if (_collectData && !lidOpen())
    {
        if (_collectDataTimer->getPeriodicInterval() == 0)
        {
            _collectDataTimer->setStartInterval(kFluorescenceDataCollectionDelayTimeMs);
            _collectDataTimer->setPeriodicInterval(kFluorescenceDataCollectionDelayTimeMs);
            _collectDataTimer->start(TimerCallback<Optics>(*this, &Optics::collectDataCallback));
        }
    }
    else
    {
        _adcCondition.notify_all();
        _collectDataTimer->stop();
        _collectDataTimer->setPeriodicInterval(0);
        _ledController->disableLEDs();
    }
}

void Optics::collectDataCallback(Poco::Timer &timer)
{
    try
    {
        std::vector<std::vector<unsigned long>> adcValues;
        adcValues.resize(qpcrApp.settings().device.opticsChannels);

        {
            std::size_t doneChannels = 0;
            std::unique_lock<std::mutex> lock(_adcMutex);

            while (doneChannels < adcValues.size())
            {
                _adcCondition.wait(lock);

                std::vector<unsigned long> &channel = adcValues.at(_adcValue.second);

                if (channel.size() < kADCReadsPerOpticalMeasurement)
                {
                    channel.emplace_back(_adcValue.first);

                    if (channel.size() == kADCReadsPerOpticalMeasurement)
                        ++doneChannels;
                }

                if (!_collectData)
                {
                    adcValues.clear();
                    break;
                }
            }
        }

        if (!adcValues.empty())
        {
            if (!_meltCurveCollection)
            {
                std::size_t i = 0;
                for (std::vector<unsigned long> &channel: adcValues)
                {
                    for (unsigned long value: channel)
                        _fluorescenceData[_wellNumber][i].emplace_back(value);

                    ++i;
                }
            }
            else
            {
                double temperature = HeatBlockInstance::getInstance()->temperature();

                std::size_t i = 0;
                for (std::vector<unsigned long> &channel: adcValues)
                {
                    unsigned int adc = 0;

                    for (unsigned long value: channel)
                        adc += value;

                    std::lock_guard<std::mutex> meltCurveDataLock(_meltCurveDataMutex);
                    _meltCurveData.emplace_back(adc / kADCReadsPerOpticalMeasurement, temperature, _wellNumber, i);

                    ++i;
                }
            }
        }

        ++_wellNumber;
        if (_wellNumber >= kWellToLedMappingList.size())
            _wellNumber = 0;

        _ledController->activateLED(kWellToLedMappingList.at(_wellNumber));
        _photodiodeMux.setChannel(_wellNumber);

        timer.restart(timer.getPeriodicInterval());
    }
    catch (...)
    {
        qpcrApp.setException(std::current_exception());
    }
}

std::vector<Optics::FluorescenceData> Optics::getFluorescenceData()
{
    std::vector<FluorescenceData> data;
    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

    if (_collectData)
    {
        _collectData = false;
        toggleCollectData();

        for (std::map<unsigned int, std::map<std::size_t, std::vector<unsigned long>>>::iterator it = _fluorescenceData.begin(); it != _fluorescenceData.end(); ++it)
        {
            for (std::map<std::size_t, std::vector<unsigned long>>::iterator it2 = it->second.begin(); it2 != it->second.end(); ++it2)
            {
                if (!it2->second.empty())
                {
                    data.emplace_back(std::accumulate(it2->second.begin(), it2->second.end(), 0) / it2->second.size(), it->first, it2->first);

                    it2->second.clear();
                }
                else
                    data.emplace_back(0, it->first, it2->first);
            }
        }
    }

    return data;
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
