#ifndef MAINCONTROLLERS_H
#define MAINCONTROLLERS_H

#include "instance.h"

class ADCControllerInstance : public Instance<ADCController>
{

};

class HeatBlockInstance : public Instance<HeatBlock>
{

};

class HeatSinkInstance : public Instance<HeatSink>
{

};

class OpticsInstance : public Instance<Optics>
{

};

class LidInstance : public Instance<Lid>
{

};


#endif // MAINCONTROLLERS_H
