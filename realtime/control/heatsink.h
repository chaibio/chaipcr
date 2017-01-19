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

#include <atomic>
#include <deque>

#include <Poco/Timer.h>
#include <Poco/Util/Timer.h>
#include <Poco/Util/TimerTask.h>

class PWMControl;

class HeatSink : public TemperatureController
{
public:
    HeatSink(Settings settings, const std::string &fanPWMPath, unsigned long fanPWMPeriod, const ADCPin &adcPin);
    ~HeatSink();

    Direction outputDirection() const;
    void setOutput(double value);

    double fanDrive() const;

    void startADCReading();

    inline int32_t adcValue() const { return _adcValue; }

protected:
    void resetOutput();
    void processOutput();

private:
    void readADCPin(Poco::Timer &timer);

    void nextFanStep(Poco::Util::TimerTask &/*task*/) { nextFanStep(); }
    void nextFanStep();

private:
    PWMControl *_fan;

    ADCPin _adcPin;
    Poco::Timer _adcTimer;
    std::atomic<uint32_t> _adcValue;

    Poco::Util::Timer _fanControlTimer;
    std::atomic<bool> _fanControlState;
    std::deque<std::pair<long, double>> _fanTransitionSteps;
};

#endif // HEATSINK_H
