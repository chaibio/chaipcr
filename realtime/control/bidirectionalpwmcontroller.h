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

#ifndef BIDIRECTIONALPWMCONTROLLER_H
#define BIDIRECTIONALPWMCONTROLLER_H

#include "temperaturecontroller.h"
#include "pwm.h"

#include "gpio.h"

class BidirectionalPWMController : public TemperatureController, public PWMControl
{
public:
    BidirectionalPWMController(Settings settings, const std::string &pwmPath, unsigned long pwmPeriod, unsigned int heatIOPin, unsigned int coolIOPin);
    ~BidirectionalPWMController();

    Direction outputDirection() const;
    void setOutput(double value);

protected:
    void resetOutput();
    void processOutput();

private:
    GPIO _heatIO;
    GPIO _coolIO;
};

#endif // BIDIRECTIONALPWMCONTROLLER_H
