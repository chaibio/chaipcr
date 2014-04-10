#include "pcrincludes.h"
#include "pocoincludes.h"
#include "utilincludes.h"

#include "ledcontroller.h"
#include "optics.h"

using namespace std;
using namespace Poco;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics(GPIO &&lidSensePin, shared_ptr<LEDController> ledController, MUX &&photoDiodeMux)
    :_lidSensePin(move(lidSensePin)),
     _ledController(ledController),
     _photoDiodeMux(move(photoDiodeMux))
{
    _lidOpen.store(false);

    _collectData.store(false);
    _collectDataTimer = new Timer(0, kCollectDataInterval);
    _ledNumber = 1;
}

Optics::~Optics()
{
    delete _collectDataTimer;
}

void Optics::process()
{
	//read lid state
    bool oldLidState = _lidOpen.exchange(_lidSensePin.value());

    if (oldLidState != _lidOpen.load() && collectData())
    {
        if (_lidOpen.load())
        {
            _collectDataTimer->stop();
            _ledController->disableLEDs();
        }
        else
            _collectDataTimer->start(TimerCallback<Optics>(*this, &Optics::collectDataCallback));
    }

    _photoDiodeMux.setChannel(15);
}

void Optics::setCollectData(bool state)
{
    if (state != _collectData.load())
    {
        if (state)
        {
            _ledNumber = 1;

            if (!lidOpen())
                _collectDataTimer->start(TimerCallback<Optics>(*this, &Optics::collectDataCallback));
        }
        else
            _collectDataTimer->stop();

        _collectData.store(state);
    }
}

void Optics::collectDataCallback(Poco::Timer&)
{
    _ledController->activateLED(_ledNumber++);

    if (_ledNumber >= 16)
        _ledNumber = 1;
}
