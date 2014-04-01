#include "pcrincludes.h"
#include "utilincludes.h"

#include "ledcontroller.h"
#include "optics.h"

//test
#include <stdlib.h>
using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
Optics::Optics(shared_ptr<SPIPort>ledSPIPort)
{
    _lidOpen.store(false);
    _lidSensePin = make_shared<GPIO>(kLidSensePinNumber, GPIO::kInput);

    //GPIO pins that are connected to MUX
    auto muxControlPin1 = make_shared<GPIO>(kMuxControlPin1,GPIO::kOutput);
    auto muxControlPin2 = make_shared<GPIO>(kMuxControlPin2,GPIO::kOutput);
    auto muxControlPin3 = make_shared<GPIO>(kMuxControlPin3,GPIO::kOutput);
    auto muxControlPin4 = make_shared<GPIO>(kMuxControlPin4,GPIO::kOutput);
    vector<shared_ptr<GPIO>> muxControlPins{muxControlPin1,muxControlPin2,muxControlPin3,muxControlPin4};
    //MUX class to control which photodiode is connected to the PLL/ADC
    _photoDiodeMux = make_shared<MUX>(muxControlPins);
    _ledController = make_shared<LEDController>(ledSPIPort, 50);
}

Optics::~Optics()
{
}

void Optics::process()
{
	//read lid state
    _lidOpen.store(_lidSensePin->value());
    _photoDiodeMux->setChannel(11);
}
