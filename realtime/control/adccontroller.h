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

#ifndef _ADCCONTROLLER_H_
#define _ADCCONTROLLER_H_

#include "icontrol.h"
#include "spi.h"
#include "lockfreesignal.h"

#include <array>
#include <vector>
#include <memory>
#include <atomic>
#include <map>

class LTC2444;
class ADCConsumer;
class BaseADCDebugLogger;

// Class ADCController
class ADCController : public IThreadControl
{
public:
    enum ADCState {
        EReadZone1Singular = 0,
        EReadZone2Singular,
        EReadLIA,
        EReadLid,
        EFinal
    };

    typedef std::array<std::shared_ptr<ADCConsumer>, EFinal> ConsumersList;

    ADCController(ConsumersList &&consumers, unsigned int csPinNumber, SPIPort &&spiPort, unsigned int busyPinNumber);
	~ADCController();
	
    void process();
    void stop();

    bool startDebugLogger(std::size_t preSamplesCount, std::size_t postSamplesCount);
    void stopDebugLogger();
    void triggetDebugLogger();

    boost::signals2::lockfree_signal<void()> loopStarted;

protected:
    ADCState calcNextState(std::size_t &nextChannel) const;
	
protected:
    std::atomic<bool> _workState;

    LTC2444 *_ltc2444;
    ADCState _currentConversionState;
    uint32_t _differentialValue;

    std::size_t _currentChannel;

    ConsumersList _consumers;

    std::shared_ptr<ADCConsumer> _liaConsumer;
    std::shared_ptr<ADCConsumer> _lidConsumer;

private:
    BaseADCDebugLogger *_debugLogger;

    bool _ignoreReading;
};

#endif
