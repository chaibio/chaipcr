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
     _fluorescenceData(kWellToLedMappingList.size()),
     _photodiodeMux(move(photoDiodeMux))
{
    _lidOpen = false;
    _collectData = false;
    _meltCurveCollection = false;
    _collectDataTimer = new Timer;
    _wellNumber = 0;
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
    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

    if (_collectData.exchange(state) != state)
    {
        if (_collectData)
        {
            _meltCurveCollection = isMeltCurve;
            _wellNumber = 0;

            _fluorescenceData.clear();
            _fluorescenceData.resize(kWellToLedMappingList.size());

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
            _fluorescenceData.resize(kWellToLedMappingList.size());

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
                _fluorescenceData[_wellNumber].emplace_back(_adcValue);

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

            std::lock_guard<std::mutex> meltCurveDataLock(_meltCurveDataMutex);
            _meltCurveData.emplace_back(adc / kADCReadsPerOpticalMeasurement, temperature, kWellToLedMappingList.at(_wellNumber));
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

std::vector<int> Optics::getFluorescenceData()
{
    std::vector<int> collectedData;
    std::lock_guard<std::recursive_mutex> lock(_collectDataMutex);

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
