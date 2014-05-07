#include "pcrincludes.h"
#include "boostincludes.h"
#include "utilincludes.h"
#include "dbincludes.h"
#include "pocoincludes.h"
#include "qpcrapplication.h"

#include "bidirectionalpwmcontroller.h"
#include "heatblock.h"

using namespace std;
using namespace Poco;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
HeatBlock::HeatBlock(HeatBlockZoneController* zone1, HeatBlockZoneController* zone2, double beginStepTemperatureThreshold) {
    _zones = make_pair(zone1, zone2);
    _beginStepTemperatureThreshold = beginStepTemperatureThreshold;
    _step = nullptr;

    _holdStepTimer = new Timer();
}

HeatBlock::~HeatBlock() {
    delete _zones.second;
    delete _zones.first;
}

void HeatBlock::process() {
    _zones.first->process();
    _zones.second->process();

    if (qpcrApp->machineState() == QPCRApplication::Running && _beginStepTemperatureThreshold > maxTemperatureSetpointDelta())
        stepBegun();
}

void HeatBlock::setEnableMode(bool enableMode) {
    _step = QPCRApplication::getInstance()->currentExperiment()->protocol()->currentStep();

    setTargetTemperature(_step->temperature());

    _zones.first->setEnableMode(enableMode);
    _zones.second->setEnableMode(enableMode);
}

void HeatBlock::setTargetTemperature(double targetTemperature) {
    _zones.first->setTargetTemperature(targetTemperature);
    _zones.second->setTargetTemperature(targetTemperature);
}

double HeatBlock::zone1Temperature() const {
    return _zones.first->currentTemperature();
}

double HeatBlock::zone2Temperature() const {
    return _zones.second->currentTemperature();
}

double HeatBlock::maxTemperatureSetpointDelta() const {
    double zone1Abs = std::abs(_zones.first->targetTemperature() - zone1Temperature());
    double zone2Abs = std::abs(_zones.second->targetTemperature() - zone2Temperature());

    return zone1Abs > zone2Abs ? zone1Abs : zone2Abs;
}

void HeatBlock::stepBegun() {
    if (_holdStepTimer->getPeriodicInterval() == 0) {
        _holdStepTimer->setPeriodicInterval(_step->holdTime());
        _holdStepTimer->start(Poco::TimerCallback<HeatBlock>(*this, &HeatBlock::holdStepCallback));
    }
}

void HeatBlock::holdStepCallback(Timer &timer) {
    _step = QPCRApplication::getInstance()->currentExperiment()->protocol()->nextStep();

    if (_step)
        setTargetTemperature(_step->temperature());
    else
        stagesCompleted();

    timer.restart(0);
    timer.setPeriodicInterval(0);
}
