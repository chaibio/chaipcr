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

#include "pcrincludes.h"
#include "adcpin.h"

#include <fstream>
#include <sstream>

#define MAX_VALUE 4095

ADCPin::ADCPin(const std::string &path, unsigned int channel)
{
    _path = path;
    _channel = channel;

    changeMode();
}

ADCPin::ADCPin(const ADCPin &other)
    :ADCPin(other.path(), other.channel())
{
}

ADCPin& ADCPin::operator= (const ADCPin &other)
{
    _path = other.path();
    _channel = other.channel();

    return *this;
}

int32_t ADCPin::readValue() const {
    std::stringstream channelPath;
    channelPath << path() << "/in_voltage" << channel() << "_raw";

    std::ifstream channelFile(channelPath.str());

    int32_t value = 0;
    channelFile >> value;
    return value;
}

void ADCPin::changeMode()
{
    std::ofstream modeFile(path() + "/mode");
    modeFile << "oneshot";
}
