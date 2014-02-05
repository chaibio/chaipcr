#ifndef MAINCONTROLLERS_H
#define MAINCONTROLLERS_H

#include "instance.h"

#include "adccontroller.h"
#include "heatblock.h"
#include "heatsink.h"
#include "optics.h"

class ADCControllerInstance : public Instance<ADCController>
{

};

class HeatBlockInstance : public Instance<HeatBlock>
{

};

class HeatSinkInstace : public Instance<HeatSink>
{

};

class OpticsInstance : public Instance<Optics>
{

};


#endif // MAINCONTROLLERS_H
