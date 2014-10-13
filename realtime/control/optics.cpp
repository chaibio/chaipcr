#include <Poco/Timer.h>

#include "pcrincludes.h"
#include "pid.h"
#include "ledcontroller.h"
#include "optics.h"
#include "qpcrapplication.h"

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
    _adcValue =  0;

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
        toggleCollectData();
}

void Optics::setADCValue(unsigned int adcValue)
{
    _adcValue = (adcValue >> 7); //convert positive range of signed 24 bit ADC value to 16 bit unsigned value
    _adcCondition.notify_all();
}

void Optics::setCollectData(bool state)
{
    _collectDataMutex.lock();
    {
        if (_collectData.exchange(state) != state)
        {
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
}

void Optics::toggleCollectData()
{
    _collectDataMutex.lock();
    {
        if (_collectData && !lidOpen())
        {
            if (_collectDataTimer->getPeriodicInterval() == 0)
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
    try
    {
        std::mutex waitMutex;
        std::unique_lock<std::mutex> waitLock(waitMutex);

        for (int i = 0; i < kADCReadsPerOpticalMeasurement; ++i)
        {
            _adcCondition.wait(waitLock);
            _fluorescenceData[_ledNumber].push_back(_adcValue);

            if (!_collectData)
                break;
        }

        ++_ledNumber;
        if (_ledNumber >= kWellList.size())
            _ledNumber = 0;

        _ledController->activateLED(kWellList.at(_ledNumber));
        _photodiodeMux.setChannel(_ledNumber);

        timer.restart(timer.getPeriodicInterval());
    }
    catch (...)
    {
        qpcrApp.setException(std::current_exception());
    }
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
}
