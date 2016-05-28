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

#ifndef TIMECHECKER_H
#define TIMECHECKER_H

#include <boost/chrono.hpp>
#include <boost/signals2.hpp>

namespace Poco { class Timer; }

class TimeChecker
{
public:
    TimeChecker();
    ~TimeChecker();

    boost::signals2::signal<void(bool)> timeStateChanged;

private:
    void timeCheckCallback(Poco::Timer &timer);

    void saveCurrentTime();
    boost::chrono::seconds getSavedTime() const;

    void setCurrentTime(const boost::chrono::seconds &timestamp);

private:
    Poco::Timer *_timer;

    bool _firstTryState;
    bool _timeState;
};

#endif // TIMECHECKER_H
