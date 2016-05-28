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

#ifndef QPCRFACTORY_H
#define QPCRFACTORY_H

#include "adccontroller.h"

class IControl;
class IThreadControl;
class SPIPort;
class ADCConsumer;

#include <memory>
#include <vector>

// Class QPCRFactory
class QPCRFactory {
public:
    static void constructMachine(std::vector<std::shared_ptr<IControl>> &controls, std::vector<std::shared_ptr<IThreadControl>> &threadControls);

private:
    static std::shared_ptr<IControl> constructOptics(std::shared_ptr<SPIPort> ledSPIPort, ADCController::ConsumersList &consumers);
    static std::shared_ptr<IControl> constructHeatBlock(ADCController::ConsumersList &consumers);
    static std::shared_ptr<IControl> constructLid(ADCController::ConsumersList &consumers);
    static std::shared_ptr<IControl> constructHeatSink();

    static void setupMachine();
};


#endif // QPCRFACTORY_H
