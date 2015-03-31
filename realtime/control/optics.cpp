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
     _fluorescenceData(kWellList.size()),
     _photodiodeMux(move(photoDiodeMux))
{
    _lidOpen = false;
    _collectData = false;
    _meltCurveCollection = false;
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

void Optics::setCollectData(bool state, bool isMeltCurve)
{
    std::unique_lock<std::recursive_mutex> lock(_collectDataMutex);

    if (_collectData.exchange(state) != state)
    {
        if (_collectData)
        {
            _meltCurveCollection = isMeltCurve;
            _ledNumber = 0;

            _fluorescenceData.clear();
            _fluorescenceData.resize(kWellList.size());

            _meltCurveData.clear();

            _ledController->activateLED(kWellList.at(_ledNumber));
            _photodiodeMux.setChannel(_ledNumber);
        }

        toggleCollectData();

        if (!_collectData)
        {
            _meltCurveCollection = false;
            _ledNumber = 0;

            _fluorescenceData.clear();
            _fluorescenceData.resize(kWellList.size());

            _meltCurveData.clear();
        }
    }
}

void Optics::toggleCollectData()
{
    std::unique_lock<std::recursive_mutex> lock(_collectDataMutex);

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

void Optics::collectDataCallback(Poco::Timer &timer)
{
    try
    {
        std::mutex waitMutex;
        std::unique_lock<std::mutex> waitLock(waitMutex);

        if (!_meltCurveCollection)
        {
            for (int i = 0; i < kADCReadsPerOpticalMeasurement; ++i)
            {
                _adcCondition.wait(waitLock);
                _fluorescenceData[_ledNumber].emplace_back(_adcValue);

                if (!_collectData)
                    break;
            }
        }
        else
        {
            double temperature = HeatBlockInstance::getInstance()->temperature();
            unsigned int adc = 0;

            for (int i = 0; i < kADCReadsPerOpticalMeasurement; ++i)
            {
                _adcCondition.wait(waitLock);
                adc += _adcValue;

                if (!_collectData)
                    break;
            }

            _meltCurveData.emplace_back(adc / kADCReadsPerOpticalMeasurement, temperature, kWellList.at(_ledNumber));
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

std::vector<int> Optics::getFluorescenceData()
{
    std::vector<int> collectedData;
    std::unique_lock<std::recursive_mutex> lock(_collectDataMutex);

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
    }

    return collectedData;
}

std::vector<Optics::MeltCurveData> Optics::getMeltCurveData()
{
    std::vector<MeltCurveData> meltCurveData;
    std::unique_lock<std::recursive_mutex> lock(_collectDataMutex);

    if (_collectData && _meltCurveCollection)
    {
        _collectData = _meltCurveCollection = false;
        toggleCollectData();

        meltCurveData = std::move(_meltCurveData);
    }

    return meltCurveData;
}
