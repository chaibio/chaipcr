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

#ifndef HEATSINK_H
#define HEATSINK_H

#include "temperaturecontroller.h"
#include "adcpin.h"

class PWMControl;

namespace Poco { class Timer; }

class HeatSink : public TemperatureController
{
public:
    HeatSink(Settings settings, const std::string &fanPWMPath, unsigned long fanPWMPeriod, const ADCPin &adcPin);
    ~HeatSink();

    Direction outputDirection() const;
    void setOutput(double value);

    double fanDrive() const;

    void startADCReading();

protected:
    void resetOutput();
    void processOutput();

private:
    void readADCPin(Poco::Timer &timer);

private:
    PWMControl *_fan;

    ADCPin _adcPin;
    Poco::Timer *_adcTimer;
};

#endif // HEATSINK_H
