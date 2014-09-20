#include <Poco/Timer.h>

#include "pcrincludes.h"
#include "pid.h"
#include "ledcontroller.h"
#include "optics.h"

using namespace std;
using namespace Poco;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics(unsigned int lidSensePin, shared_ptr<LEDController> ledController, MUX &&photoDiodeMux)
    :_ledController(ledController),
     _lidSensePin(lidSensePin, GPIO::kInput),
     _fluorescenceData(kWellList.size()),
     _photodiodeMux(move(photoDiodeMux))
{
    _lidOpen = false;
    _collectData = false;
    _collectDataTimer = new Timer;
    _ledNumber = 0;
}

Optics::~Optics()
{
    delete _collectDataTimer;
}

void Optics::process()
{
    bool lidState = _lidSensePin.value() == GPIO::kHigh ? true : false;
    if (_lidOpen.compare_exchange_strong(lidState, !lidState))
        toggleCollectData();

    /*bool oldLidState = _lidOpen.exchange(!_lidSensePin.value()); //read lid state

    if (oldLidState != _lidOpen.load() && collectData())
    {
        if (_lidOpen.load())
        {
            _collectDataTimer->stop();
            _ledController->disableLEDs();
        }
        else
        {
            _collectDataTimer->setPeriodicInterval(kFluorescenceDataCollectionDelayTimeMs);
            _collectDataTimer->start(TimerCallback<Optics>(*this, &Optics::collectDataCallback));
        }
    }*/
}

void Optics::setADCValue(unsigned int adcValue)
{
    _adcValue = (adcValue >> 7); //convert positive range of signed 24 bit ADC value to 16 bit unsigned value
    _adcCondition.notify_all();
}

bool Optics::collectData() const
{
    bool result;

    _collectDataMutex.lock();
    result = _collectData;
    _collectDataMutex.unlock();

    return result;
}

void Optics::setCollectData(bool state)
{
    _collectDataMutex.lock();
    {
        if (_collectData != state)
        {
            _collectData = state;

            if (_collectData)
            {
                _ledNumber = 0;

                _fluorescenceData.clear();
                _fluorescenceData.resize(kWellList.size());

                _ledController->activateLED(kWellList.at(_ledNumber));
                _photodiodeMux.setChannel(_ledNumber);
            }

            toggleCollectData();

            if (!_collectData)
            {
                _ledNumber = 0;

                _fluorescenceData.clear();
                _fluorescenceData.resize(kWellList.size());
            }
        }
    }
    _collectDataMutex.unlock();

    /*if (state != _collectData.load())
    {
        if (state)
        {
            _ledNumber = 0;

            if (!lidOpen())
            {
                _collectDataTimer->setPeriodicInterval(kFluorescenceDataCollectionDelayTimeMs);
                _collectDataTimer->start(TimerCallback<Optics>(*this, &Optics::collectDataCallback));
            }
        }
        else
        {
            _collectDataTimer->stop();
            _ledController->disableLEDs();
        }

        _collectData.store(state);
    }*/
}

void Optics::toggleCollectData()
{
    _collectDataMutex.lock();
    {
        if (_collectData && !lidOpen())
        {
            if (_collectDataTimer->getPeriodicInterval() != 0)
            {
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
    _collectDataMutex.unlock();
}

void Optics::collectDataCallback(Poco::Timer &timer)
{
    {
        std::mutex waitMutex;
        std::unique_lock<std::mutex> waitLock(waitMutex);
        _adcCondition.wait(waitLock);
    }

    _fluorescenceData[_ledNumber].push_back(_adcValue);

    ++_ledNumber;
    if (_ledNumber >= kWellList.size())
        _ledNumber = 0;

    _ledController->activateLED(kWellList.at(_ledNumber));
    _photodiodeMux.setChannel(_ledNumber);

    timer.restart(timer.getPeriodicInterval());
}

std::vector<int> Optics::restartCollection()
{
    std::vector<int> collectedData;

    _collectDataMutex.lock();
    {
        if (_collectData)
        {
            _collectData = false;
            toggleCollectData();

            for (std::vector<int> &data: _fluorescenceData)
            {
                if (!data.empty())
                {
                    collectedData.emplace_back(std::accumulate(data.begin(), data.end(), 0) / data.size());

                    data.clear();
                }
                else
                    collectedData.emplace_back(0);
            }

            setCollectData(true);
        }
    }
    _collectDataMutex.unlock();

    return collectedData;

    /*_collectDataTimer->stop();

    std::vector<int> collectedData;
    for (std::vector<int> &data: _fluorescenceData)
    {
        if (!data.empty())
        {
            collectedData.emplace_back(std::accumulate(data.begin(), data.end(), 0) / data.size());

            data.clear();
        }
        else
            collectedData.emplace_back(0);
    }

    _ledNumber = 0;
    _fluorescenceData.clear();

    if (!lidOpen())
    {
        _collectDataTimer->setPeriodicInterval(kFluorescenceDataCollectionDelayTimeMs);
        _collectDataTimer->start(TimerCallback<Optics>(*this, &Optics::collectDataCallback));
    }

    return collectedData;*/
}
