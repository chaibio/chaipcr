#include "timechecker.h"

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

                if (savedTime > boost::chrono::duration_cast<boost::chrono::seconds>(boost::chrono::system_clock::now().time_since_epoch()))
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
            std::cout << "TimeChecker::timeCheckCallback - unable to create pipe: " << std::strerror(errno) << '\n';
    }
    else
        saveCurrentTime();

    _firstTryState = false;
}

void TimeChecker::saveCurrentTime()
{
    std::ofstream file("./qpcr_saved_time", std::ofstream::out | std::ofstream::trunc);

    if (file.is_open())
        file << boost::chrono::duration_cast<boost::chrono::seconds>(boost::chrono::system_clock::now().time_since_epoch()).count();
    else
        std::cout << "TimeChecker::saveCurrentTime - unable to open file: " << std::strerror(errno) << '\n';
}

boost::chrono::seconds TimeChecker::getSavedTime() const
{
    boost::chrono::seconds::rep count = 0;
    std::ifstream file("./qpcr_saved_time");

    if (file.is_open())
        file >> count;
    else
        std::cout << "TimeChecker::getSavedTime - unable to open file: " << std::strerror(errno) << '\n';

    return boost::chrono::seconds(count);
}

void TimeChecker::setCurrentTime(const boost::chrono::seconds &timestamp)
{
    std::stringstream stream;
    stream << "date -s @" << timestamp.count();

    system(stream.str().c_str());
}
