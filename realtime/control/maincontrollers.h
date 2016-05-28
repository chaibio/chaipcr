/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef MAINCONTROLLERS_H
#define MAINCONTROLLERS_H

#include "instance.h"

#include "adccontroller.h"
#include "heatblock.h"
#include "heatsink.h"
#include "optics.h"
#include "lid.h"

#include "test/adccontrollermock.h"

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

class ADCControllerMockInstance : public Instance<ADCControllerMock>
{

};


#endif // MAINCONTROLLERS_H
