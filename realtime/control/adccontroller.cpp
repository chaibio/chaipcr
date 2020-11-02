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

#include <cassert>
#include <cstdio>
#include <boost/chrono.hpp>

#include "pcrincludes.h"
#include "ltc2444.h"
#include "adcconsumer.h"
#include "adccontroller.h"
#include "qpcrapplication.h"
#include "experimentcontroller.h"
#include "logger.h"
#include "adcdebuglogger.h"

using namespace std;

const LTC2444::OversamplingRatio kThermistorOversamplingRate = LTC2444::kOversamplingRatio512;
const LTC2444::OversamplingRatio kLIAOversamplingRate = LTC2444::kOversamplingRatio512;

////////////////////////////////////////////////////////////////////////////////
// Class ADCController
ADCController::ADCController(ConsumersList &&consumers, unsigned int csPinNumber, SPIPort &&spiPort, unsigned int busyPinNumber):
    Watchdog::Watchable("ADCController"), _consumers(std::move(consumers)) {
    _currentConversionState = static_cast<ADCState>(0);
    _currentChannel = 0;
    _workState = false;
    _ignoreReading = false;

    if (qpcrApp.settings().device.opticsChannels == 1)
        _debugLogger = new ADCDebugLogger<1>(kADCDebugReaderSamplesPath);
    else
        _debugLogger = new ADCDebugLogger<2>(kADCDebugReaderSamplesPath);

    _ltc2444 = new LTC2444(csPinNumber, std::move(spiPort), busyPinNumber);
}

ADCController::~ADCController() {
    stop();

    if (joinable())
        join();

    delete _ltc2444;
    delete _debugLogger;
}

void ADCController::process() {
    Poco::LogStream logStream(Logger::get());

    setThreadName("ADCController");
    setMaxRealtimePriority();

    {
        bool readyFlag = false;
        _ltc2444->readSingleEndedChannel(0, kThermistorOversamplingRate, readyFlag); //start first read
    }

    static const boost::chrono::nanoseconds repeatFrequencyInterval((boost::chrono::nanoseconds::rep)round(1.0 / kADCRepeatFrequency * 1000 * 1000 * 1000));
    boost::chrono::steady_clock::time_point repeatFrequencyLastTime = boost::chrono::steady_clock::now();

    try {
        _workState = true;

        while (_workState) {
            checkin();

            bool wait = _ltc2444->waitBusy();

            if (!_workState)
                break;
            else if (wait)
                continue;

            if (ExperimentController::getInstance()->machineState() == ExperimentController::IdleMachineState && _debugLogger->workState() != BaseADCDebugLogger::WorkingState) {
                timespec time;
                time.tv_sec = 0;
                time.tv_nsec = 5 * 1000 * 1000;

                nanosleep(&time, nullptr);
            }

            std::size_t channel = 0;
            ADCState nextState = calcNextState(channel);

            //ensure ADC loop runs at regular interval without jitter
            if (nextState == 0) {
                try {
                    loopStarted();
                }
                catch (const TemperatureLimitError &ex) {
                    logStream << "ADCController::process - loop start exception: " << ex.what() << std::endl;

                    qpcrApp.stopExperiment(ex.what());
                }

                boost::chrono::steady_clock::time_point previousTime = repeatFrequencyLastTime;
                repeatFrequencyLastTime = boost::chrono::steady_clock::now();

                boost::chrono::nanoseconds executionTime = repeatFrequencyLastTime - previousTime;

                if (executionTime < repeatFrequencyInterval) {
                    timespec time;
                    time.tv_sec = 0;
                    time.tv_nsec = (repeatFrequencyInterval - executionTime).count();

                    nanosleep(&time, nullptr);

                    repeatFrequencyLastTime = boost::chrono::steady_clock::now();
                }
                //else
                //    logStream << "ADCController::process - ADC measurements could not be completed in scheduled time" << std::endl;
            }

            //schedule conversion for next state, retrieve previous conversion value
            int32_t value = 0;
            bool readyFlag = false;

            switch (nextState) {
            case EReadZone1Singular:
                value = _ltc2444->readSingleEndedChannel(0, kThermistorOversamplingRate, readyFlag);
                break;

            case EReadZone2Singular:
                value = _ltc2444->readSingleEndedChannel(1, kThermistorOversamplingRate, readyFlag);
                break;

            case EReadLIA:
                if (_currentConversionState == EReadZone2Singular && nextState == EReadLIA && !_ignoreReading)
                    //sample unused ADC input before the optical channels
                    value = _ltc2444->readSingleEndedChannel(kADCOpticsChannels.at(0), kLIAOversamplingRate, readyFlag);
                else
                    value = _ltc2444->readSingleEndedChannel(kADCOpticsChannels.at(channel), kLIAOversamplingRate, readyFlag);

                break;

            case EReadLid:
                value = _ltc2444->readSingleEndedChannel(7, kThermistorOversamplingRate, readyFlag);
                break;

            default:
                throw std::logic_error("Unexpected error: ADCController::process - unknown adc state");
            }

            if (!readyFlag)
            {
                logStream << "ADCController::process - 31 bit is set, skipping this read" << std::endl;
                continue;
            }
            else if (!_ignoreReading)
                _debugLogger->store(_currentConversionState, value, _currentChannel);

            try {
                if (!_ignoreReading) {
                    //process previous conversion value
                    if (_currentConversionState != EReadLIA)
                        _consumers[_currentConversionState]->setADCValue(value);
                    else
                        _consumers[_currentConversionState]->setADCValue(value, _currentChannel);
                }
            }
            catch (const TemperatureLimitError &ex) {
                logStream << "ADCController::process - consumer exception: " << ex.what() << std::endl;

                qpcrApp.stopExperiment(ex.what());
            }

            if (_currentConversionState == EReadZone2Singular && nextState == EReadLIA && !_ignoreReading) {
                _ignoreReading = true;
                continue;
            }
            else
                _ignoreReading = false;

            _currentConversionState = nextState;
            _currentChannel = channel;
        }
    }
    catch (const std::exception &ex) {
        logStream << "ADCController::process - exception: " << ex.what() << std::endl;

        qpcrApp.setException(std::current_exception());
    }
    catch (...) {
        logStream << "ADCController::process - unknown exception" << std::endl;

        qpcrApp.setException(std::current_exception());
    }
}

void ADCController::stop() {
    _workState = false;
    _ltc2444->stopWaitinigBusy();
}

bool ADCController::startDebugLogger(std::size_t preSamplesCount, std::size_t postSamplesCount) {
    return _debugLogger->start(preSamplesCount, postSamplesCount);
}

void ADCController::stopDebugLogger() {
    _debugLogger->stop();
}

void ADCController::triggetDebugLogger() {
    _debugLogger->trigger();
}

ADCController::ADCState ADCController::calcNextState(size_t &nextChannel) const {
    if (_currentConversionState == EReadLIA) {
        nextChannel = _currentChannel + 1;

        if (nextChannel < qpcrApp.settings().device.opticsChannels)
            return _currentConversionState;
    }

    nextChannel = 0;

    ADCController::ADCState nextState = static_cast<ADCController::ADCState>(static_cast<int>(_currentConversionState) + 1);
    return nextState == EFinal ? static_cast<ADCController::ADCState>(0) : nextState;
}
