#ifndef _OPTICS_H_
#define _OPTICS_H_

#include "pwm.h"
#include "gpio.h"

class LEDController;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
class Optics : public IControl
{
public:
    Optics();
	virtual ~Optics();
	
	//accessors
    bool lidOpen() { return _lidOpen.load(); }
    void process();

    inline boost::shared_ptr<LEDController> getLedController() { return _ledController; }
	
private:
    boost::atomic<bool> _lidOpen;
    boost::shared_ptr<GPIO> _lidSensePin;
    boost::shared_ptr<LEDController> _ledController;
};

#endif
