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
#include <iostream>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class PWMPin
PWMPin::PWMPin(const string& pwmDevicePath) {
    dutyFile.exceptions(ofstream::failbit | ofstream::badbit);
    periodFile.exceptions(ofstream::failbit | ofstream::badbit);
    polarityFile.exceptions(ofstream::failbit | ofstream::badbit);

#ifndef KERNEL_49
    try {
       dutyFile.open(pwmDevicePath + "/duty", ofstream::out);
    }
    catch (const exception&) {
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/duty) -");
   }
#else
    enableFile.exceptions(ofstream::failbit | ofstream::badbit);
    try {
        dutyFile.open(pwmDevicePath + "/duty_cycle", ofstream::out);
    }
    catch (const exception&) {
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/duty_cycle) -");
    }
    try {
        enableFile.open(pwmDevicePath + "/enable", ofstream::out);
    }
    catch (const exception&) {
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/enable) -");
    }
#endif

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

#ifdef KERNEL_49
void PWMPin::setPWM(unsigned long duty, unsigned long period, unsigned int polarity) {  //should add some locks here
    //write values
    writePWMFile(enableFile, 0);
    writePWMFile(dutyFile, 0);// to go over errors of smaller period while setting duty. Will fail if initial period is less than duty.
    writePWMFile(periodFile, period);
    writePWMFile(dutyFile, duty);
    // set the polarity to active HIGH (echo normal) or active LOW (echo inversed)- must be done before enabled
    writePWMFile(polarityFile, polarity==0?"normal":"inversed");
    writePWMFile(enableFile, 1);
}

void PWMPin::writePWMFile(ostream &stream, const string value) {
    //    	std::cout << "writePWMFile Writing string value: " << value << std::endl;
    stream << value;
    stream.flush();

    stream.seekp(0, ostream::beg);
}
#else
void PWMPin::setPWM(unsigned long duty, unsigned long period, unsigned int polarity) {  //should add some locks here
    //write values
    writePWMFile(dutyFile, duty);
    writePWMFile(periodFile, period);
    writePWMFile(polarityFile, polarity);
}
#endif

void PWMPin::writePWMFile(ostream &stream, unsigned long value) {
    stream << value;
    stream.flush();

    stream.seekp(0, ostream::beg);
}
