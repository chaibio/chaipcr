#include "pcrincludes.h"
#include "pocoincludes.h"
#include "utilincludes.h"

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
            _collectDataTimer->setPeriodicInterval(kCollectDataInterval);
            _collectDataTimer->start(TimerCallback<Optics>(*this, &Optics::collectDataCallback));
        }
    }
}

void Optics::setADCValue(unsigned int adcValue)
{
    _adcValue = adcValue;
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
                _collectDataTimer->setPeriodicInterval(kCollectDataInterval);
                _collectDataTimer->start(TimerCallback<Optics>(*this, &Optics::collectDataCallback));
            }
        }
        else
            _collectDataTimer->stop();

        _collectData.store(state);
    }
}

void Optics::collectDataCallback(Poco::Timer&)
{
    _ledController->activateLED(kWellList.at(_ledNumber++));

    if (_ledNumber >= kWellList.size())
        _ledNumber = 0;
}
