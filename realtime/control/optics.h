#ifndef _OPTICS_H_
#define _OPTICS_H_

#include <icontrol.h>

class GPIO;
class LEDController;

////////////////////////////////////////////////////////////////////////////////
// Class Optics
class Optics : public IControl
{
public:
    Optics(SPIPort ledSPIPort);
    ~Optics();

    void process();
	
	//accessors
    inline bool lidOpen() const { return _lidOpen; }

    inline std::shared_ptr<LEDController> getLedController() { return _ledController; }
	
private:
    std::vector<GPIO> initMux() const;

    std::atomic<bool> _lidOpen;
    GPIO _lidSensePin;
    std::shared_ptr<LEDController> _ledController;
    MUX _photoDiodeMux;
};

#endif
