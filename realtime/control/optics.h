#ifndef _OPTICS_H_
#define _OPTICS_H_

#include <icontrol.h>

class MUX;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
class Optics : public IControl
{
public:
    Optics();
	virtual ~Optics();

    void process();
	
	//accessors
    inline bool lidOpen() const { return _lidOpen; }

    inline std::shared_ptr<LEDController> getLedController() { return _ledController; }
	
private:
    std::atomic<bool> _lidOpen;
    std::shared_ptr<GPIO> _lidSensePin;
    std::shared_ptr<LEDController> _ledController;
    std::shared_ptr<MUX> _photoDiodeMux;
};

#endif
