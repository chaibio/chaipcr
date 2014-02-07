#ifndef _OPTICS_H_
#define _OPTICS_H_

#include <icontrol.h>

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

    inline std::shared_ptr<LEDController> getLedController() { return _ledController; }
	
private:
    std::atomic<bool> _lidOpen;
    std::shared_ptr<GPIO> _lidSensePin;
    std::shared_ptr<LEDController> _ledController;
};

#endif
