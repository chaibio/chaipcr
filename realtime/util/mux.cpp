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

#include "gpio.h"
#include "mux.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class MUX
MUX::MUX(vector<GPIO> &&muxControlPins) :
    _muxControlPins(move(muxControlPins)) {
}

MUX::MUX(MUX &&other) {
    _muxControlPins = move(other._muxControlPins);
    _channel = other._channel;

    other._channel = 0;
}

MUX::~MUX() {

}

MUX& MUX::operator =(MUX &&other) {
    _muxControlPins = move(other._muxControlPins);
    _channel = other._channel;

    other._channel = 0;

    return *this;
}

void MUX::setChannel(int channel) {
    for(GPIO &muxControlPin : this->_muxControlPins) {
        muxControlPin.setValue(static_cast<GPIO::Value>(channel&0x1), true);
        channel>>=1;
    }
    _channel=channel;

}

int MUX::getChannel() {
    return _channel;
}
