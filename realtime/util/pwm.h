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

#ifndef _PWM_H_
#define _PWM_H_

#include <string>
#include <atomic>
#include <memory>
#include <fstream>

////////////////////////////////////////////////////////////////////////////////
// Class PWMPin
class PWMPin {
public:
    PWMPin(const std::string& pwmDevicePath);
	~PWMPin();
	
    void setPWM(unsigned long duty, unsigned long period, unsigned int polarity);

private:
    void writePWMFile(std::ostream &stream, unsigned long value);
#ifdef KERNEL_49
    void writePWMFile(std::ostream &stream, const std::string value);
#endif

private:
    std::ofstream dutyFile;
    std::ofstream periodFile;
    std::ofstream polarityFile;
#ifdef KERNEL_49
    std::ofstream enableFile;
#endif
};

class PWMControl {
public:
    PWMControl(const std::string &devicePath, unsigned long period, unsigned int polarity = 0)
        :_pwm(devicePath) {
        _period = period;
        _polarity = polarity;
        _dutyCycle = 0;
    }

    virtual ~PWMControl() {}

    inline unsigned long pwmPeriod() const { return _period; }
    inline void setPWMPeriod(unsigned long period) { _period = period; processPWM(); }

    inline unsigned long pwmDutyCycle() const { return _dutyCycle; }
    inline void setPWMDutyCycle(unsigned long dutyCycle) { dutyCycle <= _period ? _dutyCycle = dutyCycle : _dutyCycle = _period.load(); processPWM(); }
    inline void setPWMDutyCycle(double dutyCycle) { dutyCycle *= _period.load(); dutyCycle <= _period ? _dutyCycle = dutyCycle : _dutyCycle = _period.load(); processPWM(); }

    inline unsigned int pwmPolarity() const { return _polarity; }
    inline void setPWMPolarity(unsigned int polarity) { _polarity = polarity; processPWM(); }

    inline double drive() const { return (double)pwmDutyCycle() / pwmPeriod(); }

protected:
    inline void processPWM() { _pwm.setPWM(pwmDutyCycle(), pwmPeriod(), pwmPolarity()); }

private:
    PWMPin _pwm;
    std::atomic<unsigned long> _period;
    std::atomic<unsigned long> _dutyCycle;
    std::atomic<unsigned int> _polarity;
};

#endif
