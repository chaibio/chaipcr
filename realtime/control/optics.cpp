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
    :_lidSensePin(lidSensePin, GPIO::kInput),
     _ledController(ledController),
     _photodiodeMux(move(photoDiodeMux))
{
    _lidOpen.store(false);

    _collectData.store(false);
    _collectDataTimer = new Timer;
    _ledNumber = 0;

    for (size_t i = 0; i < kWellList.size(); ++i)
        _fluorescenceData.emplace_back();
}

Optics::~Optics()
{
    delete _collectDataTimer;
}

void Optics::process()
{
	//read lid state
    bool oldLidState = _lidOpen.exchange(!_lidSensePin.value());

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
    }
}

void Optics::setADCValue(unsigned int adcValue)
{
    //convert positive range of signed 24 bit ADC value to 16 bit unsigned value
    _adcValue = (adcValue >> 7);
}

void Optics::setCollectData(bool state)
{
    if (state != _collectData.load())
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
    }
}

void Optics::collectDataCallback(Poco::Timer&)
{
    _ledController->activateLED(kWellList.at(_ledNumber));
    _photodiodeMux.setChannel(_ledNumber);

    _fluorescenceData[_ledNumber].push_back(_adcValue);

    ++_ledNumber;

    if (_ledNumber >= kWellList.size())
        _ledNumber = 0;
}

std::vector<int> Optics::restartCollection()
{
    _collectDataTimer->stop();

    _ledNumber = 0;

    std::vector<int> collectedData;
    for (std::vector<int> &data: _fluorescenceData)
    {
        collectedData.push_back(std::accumulate(data.begin(), data.end(), 0) / data.size());

        data.clear();
    }

    if (!lidOpen())
    {
        _collectDataTimer->setPeriodicInterval(kFluorescenceDataCollectionDelayTimeMs);
        _collectDataTimer->start(TimerCallback<Optics>(*this, &Optics::collectDataCallback));
    }

    return collectedData;
}
