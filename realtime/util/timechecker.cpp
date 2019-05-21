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

#include "timechecker.h"
#include "logger.h"
#include "constants.h"

#include <iostream>
#include <fstream>
#include <string>
#include <cstdio>
#include <cstring>

#include <Poco/Timer.h>

TimeChecker::TimeChecker()
{
    _firstTryState = true;
    _timeState = false;

    _timer = new Poco::Timer(1000, 30 * 1000);
    _timer->start(Poco::TimerCallback<TimeChecker>(*this, &TimeChecker::timeCheckCallback));
}

TimeChecker::~TimeChecker()
{
    delete _timer;
}

void TimeChecker::timeCheckCallback(Poco::Timer &/*timer*/)
{
    if (!_timeState)
    {
        FILE *pipe = popen("ntpq -p", "r");

        if (pipe)
        {
            char buffer[1024];
            memset(buffer, 0, 1024);

            fgets(buffer, 1024, pipe);

            pclose(pipe);

            if (std::string(buffer).find("No association ID's returned") != std::string::npos)
            {
                boost::chrono::seconds savedTime = getSavedTime();

                if (savedTime > boost::chrono::duration_cast<boost::chrono::seconds>(boost::chrono::steady_clock::now().time_since_epoch()))
                    setCurrentTime(savedTime);
                else
                    saveCurrentTime();

                if (_firstTryState)
                    timeStateChanged(false);
            }
            else
            {
                _timeState = true;

                saveCurrentTime();
                timeStateChanged(true);
            }
        }
        else
            APP_LOGGER << "TimeChecker::timeCheckCallback - unable to create pipe: " << std::strerror(errno) << std::endl;
    }
    else
        saveCurrentTime();

    _firstTryState = false;
}

void TimeChecker::saveCurrentTime()
{
    std::ofstream file(kSavedTimePath, std::ofstream::out | std::ofstream::trunc);

    if (file.is_open())
        file << boost::chrono::duration_cast<boost::chrono::seconds>(boost::chrono::steady_clock::now().time_since_epoch()).count();
    else
        APP_LOGGER << "TimeChecker::saveCurrentTime - unable to open file: " << std::strerror(errno) << std::endl;
}

boost::chrono::seconds TimeChecker::getSavedTime() const
{
    boost::chrono::seconds::rep count = 0;
    std::ifstream file(kSavedTimePath);

    if (file.is_open())
        file >> count;
    else
        APP_LOGGER << "TimeChecker::getSavedTime - unable to open file: " << std::strerror(errno) << std::endl;

    return boost::chrono::seconds(count);
}

void TimeChecker::setCurrentTime(const boost::chrono::seconds &timestamp)
{
    std::stringstream stream;
    stream << "date -s @" << timestamp.count();

    system(stream.str().c_str());
}
