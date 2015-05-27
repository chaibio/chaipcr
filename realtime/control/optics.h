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
    struct MeltCurveData
    {
        MeltCurveData(int fluorescenceValue, double temperature, int wellId): fluorescenceValue(fluorescenceValue), temperature(temperature), wellId(wellId) {}

        int fluorescenceValue;
        double temperature;
        int wellId;
    };

    Optics(unsigned int lidSensePin, std::shared_ptr<LEDController> ledController, MUX &&photoDiodeMux);
    ~Optics();

    void process();

    void setADCValue(unsigned int adcValue);
    inline unsigned int adcValue() const noexcept { return _adcValue; }
	
	//accessors
    inline bool lidOpen() const noexcept { return _lidOpen; }

    inline bool collectData() const noexcept { return _collectData; }
    inline bool isMeltCurveCollection() const noexcept { return _meltCurveCollection; }
    void setCollectData(bool state, bool isMeltCurve = false);

    inline std::shared_ptr<LEDController> getLedController() noexcept { return _ledController; }
    inline MUX& getPhotodiodeMux() { return _photodiodeMux; }

    std::vector<int> getFluorescenceData();
    std::vector<MeltCurveData> getMeltCurveData();

private:
    void toggleCollectData();
    void collectDataCallback(Poco::Timer &timer);
	
private:
    std::shared_ptr<LEDController> _ledController;

    std::atomic<bool> _lidOpen;
    GPIO _lidSensePin;

    std::atomic<unsigned int> _adcValue;
    std::condition_variable _adcCondition;

    std::atomic<bool> _collectData;
    Poco::Timer *_collectDataTimer;
    mutable std::recursive_mutex _collectDataMutex;

    unsigned int _ledNumber;
    std::vector<std::vector<int>> _fluorescenceData;

    std::atomic<bool> _meltCurveCollection;
    std::vector<MeltCurveData> _meltCurveData;

    MUX _photodiodeMux;
};

#endif
