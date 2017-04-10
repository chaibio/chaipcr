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
#include "heatsink.h"
#include "pwm.h"
#include "thermistor.h"
#include "qpcrapplication.h"
#include "maincontrollers.h"

#include <Poco/Util/TimerTaskAdapter.h>

HeatSink::HeatSink(Settings settings, const std::string &fanPWMPath, unsigned long fanPWMPeriod, const ADCPin &adcPin)
    :TemperatureController(settings), Watchdog::Watchable("Heat sink", boost::chrono::seconds(30)), _adcPin(adcPin)
{
    _fan = new PWMControl(fanPWMPath, fanPWMPeriod);
    _fanControlState = false;

    _fan->setPWMDutyCycle(static_cast<unsigned long>(0));

    resetOutput();
}

HeatSink::~HeatSink()
{
    _adcTimer.stop();
    _fanControlTimer.cancel(true);

    resetOutput();
}

HeatSink::Direction HeatSink::outputDirection() const
{
    return ECool;
}

void HeatSink::setOutput(double value)
{
    _fan->setPWMDutyCycle(value * -1);
}

double HeatSink::fanDrive() const
{
    return _fan->drive();
}

void HeatSink::startADCReading()
{
    _adcTimer.setPeriodicInterval(kHeatSinkADCInterval);
    _adcTimer.start(Poco::TimerCallback<HeatSink>(*this, &HeatSink::readADCPin));
}

void HeatSink::resetOutput()
{
    _fanControlTimer.cancel(true);
    _fanTransitionSteps.clear();
    _fanControlState = false;

    setOutput(0);
}

void HeatSink::processOutput()
{
    if (!pidState() && !_fanControlState)
    {
        double targetTemp = HeatBlockInstance::getInstance()->targetTemperature();
        double nextDrive = 0.0;

        if (targetTemp < 30.0)
            nextDrive = 0.5;
        else
            nextDrive = qpcrApp.settings().device.fanChange ? 0.2 : 0.3;

        double currentDrive = fanDrive();

        if (currentDrive != nextDrive)
        {
            if (currentDrive == 0.0)
                _fanTransitionSteps.emplace_back(2 * 1000 * 1000, -1.0);
            else if (currentDrive == 0.3)
                _fanTransitionSteps.emplace_back(1 * 1000 * 1000, -1.0);
            else //0.5
            {
                _fanTransitionSteps.emplace_back(20 * 1000 * 1000, 0.0);
                _fanTransitionSteps.emplace_back(2 * 1000 * 1000, -1.0);
            }

            _fanTransitionSteps.emplace_back(0, -nextDrive);

            nextFanStep();
        }
    }
}

void HeatSink::readADCPin(Poco::Timer &/*timer*/)
{
    checkin();

    try
    {
        _adcValue = _adcPin.readValue();
        _thermistor->setADCValue(_adcValue);
    }
    catch (const std::exception &ex)
    {
        if (std::string("basic_filebuf::underflow error reading the file") == ex.what())
            return;

        qpcrApp.stopExperiment(ex.what());
    }
    catch (...)
    {
        qpcrApp.setException(std::current_exception());
    }
}

void HeatSink::nextFanStep()
{
    if (!_fanTransitionSteps.empty())
    {
        std::pair<long, double> step = _fanTransitionSteps.front();
        _fanTransitionSteps.pop_front();

        setOutput(step.second);

        if (step.first > 0)
        {
            _fanControlState = true;
            _fanControlTimer.schedule(Poco::Util::TimerTask::Ptr(new Poco::Util::TimerTaskAdapter<HeatSink>(*this, static_cast<void(HeatSink::*)(Poco::Util::TimerTask&)>(&HeatSink::nextFanStep))),
                                      Poco::Timestamp() + step.first);
        }
        else
            _fanControlState = false;
    }
    else
        _fanControlState = false;
}
