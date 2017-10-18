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

#include "pwm.h"

#include <system_error>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class PWMPin
PWMPin::PWMPin(const string& pwmDevicePath) {
    dutyFile.exceptions(ofstream::failbit | ofstream::badbit);
    periodFile.exceptions(ofstream::failbit | ofstream::badbit);
    polarityFile.exceptions(ofstream::failbit | ofstream::badbit);

    try {
#ifdef KERNEL_49
        dutyFile.open(pwmDevicePath + "/duty_cycle", ofstream::out);
#else
        dutyFile.open(pwmDevicePath + "/duty", ofstream::out);
#endif
    }
    catch (const exception&) {
#ifdef KERNEL_49
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/duty_cycle) -");
#else
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/duty) -");
#endif
    }

    try {
        periodFile.open(pwmDevicePath + "/period", ofstream::out);
    }
    catch (const exception&) {
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/period) -");
    }

    try {
        polarityFile.open(pwmDevicePath + "/polarity", ofstream::out);
    }
    catch (const exception&) {
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/polarity) -");
    }
}

PWMPin::~PWMPin() {
}

void PWMPin::setPWM(unsigned long duty, unsigned long period, unsigned int polarity) {  //should add some locks here
    //write values
    writePWMFile(dutyFile, duty);
    writePWMFile(periodFile, period);
    writePWMFile(polarityFile, polarity);
}

void PWMPin::writePWMFile(ostream &stream, unsigned long value) {
    stream << value;
    stream.flush();

    stream.seekp(0, ostream::beg);
}
