#ifndef _OPTICS_H_
#define _OPTICS_H_

#include "icontrol.h"
#include "adcconsumer.h"

#include "gpio.h"
#include "mux.h"

#include <memory>
#include <atomic>
#include <mutex>
#include <condition_variable>

class LEDController;

namespace Poco { class Timer; }

////////////////////////////////////////////////////////////////////////////////
// Class Optics
class Optics : public IControl, public ADCConsumer
{
public:
    Optics(unsigned int lidSensePin, std::shared_ptr<LEDController> ledController, MUX &&photoDiodeMux);
    ~Optics();

    void process();

    void setADCValue(unsigned int adcValue);
    inline unsigned int adcValue() const { return _adcValue; }
	
	//accessors
    inline bool lidOpen() const { return _lidOpen; }

    bool collectData() const;
    void setCollectData(bool state);

    inline std::shared_ptr<LEDController> getLedController() { return _ledController; }
    inline MUX& getPhotodiodeMux() { return _photodiodeMux; }

    std::vector<int> restartCollection();

private:
    void toggleCollectData();
    void collectDataCallback(Poco::Timer &timer);
	
private:
    std::shared_ptr<LEDController> _ledController;

    std::atomic<bool> _lidOpen;
    GPIO _lidSensePin;

    std::atomic<unsigned int> _adcValue;
    mutable std::condition_variable _adcCondition;

    bool _collectData;
    Poco::Timer *_collectDataTimer;
    mutable std::recursive_mutex _collectDataMutex;

    unsigned int _ledNumber;
    std::vector<std::vector<int>> _fluorescenceData;

    MUX _photodiodeMux;
};

#endif
