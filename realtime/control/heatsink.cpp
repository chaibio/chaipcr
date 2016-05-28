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

#include <Poco/Timer.h>

HeatSink::HeatSink(Settings settings, const std::string &fanPWMPath, unsigned long fanPWMPeriod, const ADCPin &adcPin)
    :TemperatureController(settings), _adcPin(adcPin)
{
    _fan = new PWMControl(fanPWMPath, fanPWMPeriod);
    _adcTimer = new Poco::Timer;

    _fan->setPWMDutyCycle((unsigned long)0);

    resetOutput();
}

HeatSink::~HeatSink()
{
    _adcTimer->stop();

    resetOutput();

    delete _fan;
    delete _adcTimer;
}


HeatSink::Direction HeatSink::outputDirection() const
{
    return ECool;
}

double HeatSink::fanDrive() const
{
    return _fan->drive();
}

void HeatSink::startADCReading()
{
    _adcTimer->setPeriodicInterval(kHeatSinkADCInterval);
    _adcTimer->start(Poco::TimerCallback<HeatSink>(*this, &HeatSink::readADCPin));
}

void HeatSink::setOutput(double value)
{
    _fan->setPWMDutyCycle(value * -1);
}

void HeatSink::resetOutput()
{
    setOutput(0);
}

void HeatSink::processOutput()
{
}

void HeatSink::readADCPin(Poco::Timer &/*timer*/)
{
    try
    {
        _thermistor->setADCValue(_adcPin.readValue());
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
