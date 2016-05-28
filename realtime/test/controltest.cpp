//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#ifdef TEST_BUILD

#include "pcrincludes.h"
#include "maincontrollers.h"
#include "controltest.h"

#define RAND(min, max) ((max - min) * ( (double)rand() / (double)RAND_MAX ) + min)

ControlTest::ControlTest()
{
    srand(time(nullptr));
}

void ControlTest::testMinMaxTargetTemp()
{
    //HeatBlock testing
    std::cout << "Testing HeatBlock min/max target temp\n";

    std::shared_ptr<HeatBlock> heatBlock = HeatBlockInstance::getInstance();
    ASSERT_TRUE((bool)heatBlock) << "HeatBlock is null";

    std::cout << "Min target temp: " << kHeatBlockZonesMinTargetTemp << ", max target temp: " << kHeatBlockZonesMaxTargetTemp << '\n';

    double value = RAND(kHeatBlockZonesMinTargetTemp, kHeatBlockZonesMaxTargetTemp);

    std::cout << "Setting valid value: " << value << '\n';

    ASSERT_NO_THROW(heatBlock->setTargetTemperature(value));

    std::cout << "Setting invalid value: " << kHeatBlockZonesMaxTargetTemp + 10 << '\n';

    ASSERT_THROW(heatBlock->setTargetTemperature(kHeatBlockZonesMaxTargetTemp + 10), std::out_of_range);

    //Lid testing
    std::cout << "Testing Lid min/max target temp\n";

    std::shared_ptr<Lid> lid = LidInstance::getInstance();
    ASSERT_TRUE((bool)lid) << "Lid is null";

    std::cout << "Min target temp: " << kLidMinTargetTemp << ", max target temp: " << kLidMaxTargetTemp << '\n';

    value = RAND(kLidMinTargetTemp, kLidMaxTargetTemp);

    std::cout << "Setting valid value: " << value << '\n';

    ASSERT_NO_THROW(lid->setTargetTemperature(value));

    std::cout << "Setting invalid value: " << kLidMinTargetTemp - 5 << '\n';

    ASSERT_THROW(lid->setTargetTemperature(kLidMinTargetTemp - 5), std::out_of_range);

    //HeatSink testing
    std::cout << "Testing HeatSink min/max target temp\n";

    std::shared_ptr<HeatSink> heatSink = HeatSinkInstance::getInstance();
    ASSERT_TRUE((bool)heatSink) << "HeatSink is null";

    std::cout << "Min target temp: " << kHeatSinkMinTargetTemp << ", max target temp: " << kHeatSinkMaxTargetTemp << '\n';

    value = RAND(kHeatSinkMinTargetTemp, kHeatSinkMaxTargetTemp);

    std::cout << "Setting valid value: " << value << '\n';

    ASSERT_NO_THROW(heatSink->setTargetTemperature(value));

    std::cout << "Setting invalid value: " << kHeatSinkMaxTargetTemp + 13 << '\n';

    ASSERT_THROW(heatSink->setTargetTemperature(kHeatSinkMaxTargetTemp + 13), std::out_of_range);
}

TEST_F(ControlTest, testMinMaxTargetTemp)
{
    testMinMaxTargetTemp();
}

#endif // TEST_BUILD
