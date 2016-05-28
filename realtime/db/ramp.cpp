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

#include "ramp.h"
#include "constants.h"

Ramp::Ramp(int id)
{
    _id = id;
    _rate = 0;
    _collectData = true;
    _excitationIntensity = kDefaultLEDCurrent;
}

Ramp::Ramp(const Ramp &other)
    :Ramp(other.id())
{
    setRate(other.rate());
    setCollectData(other.collectData());
    setExcitationIntensity(other.excitationIntensity());
}

Ramp::Ramp(Ramp &&other)
    :Ramp(other.id())
{
    _rate = other._rate;
    _collectData = other._collectData;
    _excitationIntensity = other._excitationIntensity;

    other._id = -1;
    other._rate = 0;
    other._collectData = true;
    other._excitationIntensity = kDefaultLEDCurrent;
}

Ramp::~Ramp()
{

}

Ramp& Ramp::operator= (const Ramp &other)
{
    _id = other.id();
    setRate(other.rate());
    setCollectData(other.collectData());
    setExcitationIntensity(other.excitationIntensity());

    return *this;
}

Ramp& Ramp::operator= (Ramp &&other)
{
    _id = other._id;
    _rate = other._rate;
    _collectData = other._collectData;
    _excitationIntensity = other._excitationIntensity;

    other._id = -1;
    other._rate = 0;
    other._collectData = true;
    other._excitationIntensity = kDefaultLEDCurrent;

    return *this;
}
