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

    void process();
	
	//accessors
    bool lidOpen() const { return _lidOpen.load(); }

    inline std::shared_ptr<LEDController> getLedController() { return _ledController; }
	
private:
    std::atomic<bool> _lidOpen;
    std::shared_ptr<GPIO> _lidSensePin;
    std::shared_ptr<LEDController> _ledController;
};

#endif
